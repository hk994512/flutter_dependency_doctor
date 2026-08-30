import '../models/dependency.dart';
import '../models/locked_dependency.dart';
import '../models/package_health.dart';
import '../models/pub_package_info.dart';
import '../parsers/pub_deps_parser.dart';
import '../parsers/pubspec_parser.dart';
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

  /// Resolved dependencies from `dart pub deps --json`.
  final List<LockedDependency> lockedDependencies;

  /// Complete dependency graph.
  final DependencyGraph graph;

  /// Health analysis for direct and dev dependencies.
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

  /// Number of root packages.
  ///
  /// `dart pub deps --json` includes the root package in the
  /// resolved package list. It is therefore counted separately
  /// from direct, dev, and transitive dependencies.
  int get rootPackageCount {
    return lockedDependencies
        .where((dependency) => dependency.kind == 'root')
        .length;
  }

  /// Total number of resolved packages, including the root package.
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

    final pubspecParser = PubspecParser(projectPath: projectPath);

    final directDependencies = pubspecParser.parse();

    // --------------------------------------------------
    // 2. Resolve dependencies
    // --------------------------------------------------

    final depsParser = PubDepsParser(projectPath: projectPath);

    final lockedDependencies = depsParser.parse();

    // --------------------------------------------------
    // 3. Build dependency graph
    // --------------------------------------------------

    final graph = DependencyGraph(dependencies: lockedDependencies);

    // --------------------------------------------------
    // 4. Select packages that can be checked on pub.dev
    // --------------------------------------------------

    final packagesToCheck = lockedDependencies
        .where(
          (package) =>
              (package.isDirect || package.isDev) && _canCheckOnPubDev(package),
        )
        .toList(growable: false);

    final packageInfo = <String, PubPackageInfo>{};

    // --------------------------------------------------
    // 5. Fetch pub.dev information
    // --------------------------------------------------

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
    // 6. Analyze package health
    // --------------------------------------------------

    final healthAnalyzer = HealthAnalyzer();

    final health = healthAnalyzer.analyze(packagesToCheck, packageInfo);

    // --------------------------------------------------
    // 7. Return result
    // --------------------------------------------------

    return DependencyAnalysisResult(
      directDependencies: List.unmodifiable(directDependencies),
      lockedDependencies: List.unmodifiable(lockedDependencies),
      graph: graph,
      health: List.unmodifiable(health),
    );
  }

  bool _canCheckOnPubDev(LockedDependency package) {
    return package.source == 'hosted';
  }
}
