import '../models/dependency.dart';
import '../models/locked_dependency.dart';
import '../models/package_health.dart';
import '../models/pub_package_info.dart';
import '../parsers/pub_deps_parser.dart';
import '../parsers/pubspec_parser.dart';
import '../services/pub_dev_service.dart';
import 'dependency_graph.dart';
import 'health_analyzer.dart';

/// Contains the complete result of dependency analysis.
///
/// This includes declared dependencies, resolved dependencies,
/// the dependency graph, and package health information.
class DependencyAnalysisResult {
  /// Creates a dependency analysis result.
  const DependencyAnalysisResult({
    required this.directDependencies,
    required this.lockedDependencies,
    required this.graph,
    required this.health,
  });

  /// Dependencies declared directly in pubspec.yaml.
  final List<Dependency> directDependencies;

  /// All resolved dependencies from `dart pub deps --json`.
  final List<LockedDependency> lockedDependencies;

  /// Complete dependency graph.
  final DependencyGraph graph;

  /// Health analysis for direct and development dependencies.
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
  /// The root package is included by `dart pub deps --json`
  /// in the resolved package list, so it is counted separately
  /// from direct, development, and transitive dependencies.
  int get rootPackageCount {
    return lockedDependencies.where((dependency) => dependency.isRoot).length;
  }

  /// Total number of resolved packages.
  ///
  /// This includes the root package.
  int get totalDependencyCount {
    return lockedDependencies.length;
  }
}

/// Analyzes a Dart or Flutter project's dependencies.
///
/// The analyzer reads `pubspec.yaml`, resolves the dependency graph,
/// retrieves available package information from pub.dev, and produces
/// package health results.
class DependencyAnalyzer {
  /// Creates a dependency analyzer for the specified project.
  const DependencyAnalyzer({required this.projectPath});

  /// Absolute or relative path to the Dart or Flutter project.
  final String projectPath;

  /// Analyzes the project's dependencies and returns the results.
  ///
  /// This method:
  ///
  /// 1. Parses `pubspec.yaml`.
  /// 2. Resolves dependencies using `dart pub deps --json`.
  /// 3. Builds the dependency graph.
  /// 4. Checks eligible packages against pub.dev.
  /// 5. Calculates package health information.
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
    // 7. Return analysis result
    // --------------------------------------------------

    return DependencyAnalysisResult(
      directDependencies: List.unmodifiable(directDependencies),
      lockedDependencies: List.unmodifiable(lockedDependencies),
      graph: graph,
      health: List.unmodifiable(health),
    );
  }

  /// Returns `true` when the package comes from a pub.dev/hosted source.
  ///
  /// Git and path dependencies are intentionally skipped because
  /// they cannot be reliably checked through the pub.dev package API.
  bool _canCheckOnPubDev(LockedDependency package) {
    return package.source == 'hosted';
  }
}
