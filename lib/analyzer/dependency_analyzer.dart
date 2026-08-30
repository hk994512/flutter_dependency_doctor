import '../models/dependency.dart';
import '../models/locked_dependency.dart';
import '../models/package_health.dart';
import '../models/pub_package_info.dart';
import '../parsers/pub_deps_parser.dart';

import '../parsers/pubspec_lock_parser.dart';
import '../services/pub_dev_service.dart';
import 'dependency_graph.dart';
import 'health_analyzer.dart';

class DependencyAnalysisResult {
  const DependencyAnalysisResult({
    required this.directDependencies,
    required this.lockedDependencies,
    required this.graph,
    required this.health,
  });

  /// Dependencies declared in pubspec.yaml.
  final List<Dependency> directDependencies;

  /// Dependencies resolved from pubspec.lock / pub deps.
  final List<LockedDependency> lockedDependencies;

  /// Complete dependency graph.
  final DependencyGraph graph;

  /// Health analysis for relevant packages.
  final List<PackageHealth> health;

  /// Number of production/direct dependencies.
  int get productionDependencyCount {
    return lockedDependencies.where((dependency) => dependency.isDirect).length;
  }

  /// Number of development dependencies.
  int get devDependencyCount {
    return lockedDependencies.where((dependency) => dependency.isDev).length;
  }

  /// Number of transitive dependencies.
  int get transitiveDependencyCount {
    return lockedDependencies
        .where((dependency) => dependency.isTransitive)
        .length;
  }

  /// Total resolved dependencies.
  int get totalDependencyCount {
    return lockedDependencies.length;
  }
}

class DependencyAnalyzer {
  const DependencyAnalyzer({required this.projectPath});

  final String projectPath;

  Future<DependencyAnalysisResult> analyze() async {
    // --------------------------------------------------
    // 1. Parse pubspec.yaml
    // --------------------------------------------------

    final pubspecParser = PubspecLockParser(projectPath: projectPath);

    final directDependencies = pubspecParser.parse();

    // --------------------------------------------------
    // 2. Parse resolved/classified dependencies
    // --------------------------------------------------

    final depsParser = PubDepsParser(projectPath: projectPath);

    final lockedDependencies = depsParser.parse();

    // --------------------------------------------------
    // 3. Build dependency graph
    // --------------------------------------------------

    final graph = DependencyGraph(dependencies: lockedDependencies);

    // --------------------------------------------------
    // 4. Fetch Pub.dev information
    // --------------------------------------------------

    final packageInfo = <String, PubPackageInfo>{};

    final packagesToCheck = lockedDependencies.where(
      (package) =>
          (package.isDirect || package.isDev) && _canCheckOnPubDev(package),
    );

    final service = PubDevService();

    try {
      for (final package in packagesToCheck) {
        final info = await service.getPackageInfo(package.name);

        if (info != null) {
          packageInfo[package.name] = info;
        }
      }
    } finally {
      service.dispose();
    }

    // --------------------------------------------------
    // 5. Analyze package health
    // --------------------------------------------------

    final healthAnalyzer = HealthAnalyzer();

    final health = healthAnalyzer.analyze(
      packagesToCheck.toList(growable: false),
      packageInfo,
    );

    // --------------------------------------------------
    // 6. Return analysis result
    // --------------------------------------------------

    return DependencyAnalysisResult(
      directDependencies: List.unmodifiable(directDependencies),
      lockedDependencies: List.unmodifiable(lockedDependencies),
      graph: graph,
      health: List.unmodifiable(health),
    );
  }

  /// Returns true when the package should be queried
  /// against pub.dev.
  ///
  /// SDK, path and git dependencies should not be
  /// treated as normal pub.dev packages.
  bool _canCheckOnPubDev(LockedDependency package) {
    switch (package.source) {
      case 'hosted':
        return true;

      default:
        return false;
    }
  }
}
