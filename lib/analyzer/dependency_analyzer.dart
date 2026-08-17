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
  final List<Dependency> directDependencies;
  final List<LockedDependency> lockedDependencies;
  final DependencyGraph graph;
  final List<PackageHealth> health;

  const DependencyAnalysisResult({
    required this.directDependencies,
    required this.lockedDependencies,
    required this.graph,
    required this.health,
  });

  int get productionDependencyCount {
    return lockedDependencies.where((dependency) => dependency.isDirect).length;
  }

  int get devDependencyCount {
    return lockedDependencies.where((dependency) => dependency.isDev).length;
  }

  int get transitiveDependencyCount {
    return lockedDependencies
        .where((dependency) => dependency.isTransitive)
        .length;
  }
}

class DependencyAnalyzer {
  final String projectPath;

  const DependencyAnalyzer({required this.projectPath});

  Future<DependencyAnalysisResult> analyze() async {
    // -----------------------------------------------
    // Parse pubspec.yaml
    // -----------------------------------------------

    final pubspecParser = PubspecParser(projectPath: projectPath);

    final directDependencies = pubspecParser.parse();

    // -----------------------------------------------
    // Parse resolved dependencies
    // -----------------------------------------------

    final depsParser = PubDepsParser(projectPath: projectPath);

    final lockedDependencies = depsParser.parse();

    // -----------------------------------------------
    // Build dependency graph
    // -----------------------------------------------

    final graph = DependencyGraph(dependencies: lockedDependencies);

    // -----------------------------------------------
    // Fetch Pub.dev information
    // -----------------------------------------------

    final packageInfo = <String, PubPackageInfo>{};

    final service = PubDevService();

    final packagesToCheck = lockedDependencies.where(
      (package) => package.isDirect || package.isDev,
    );

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

    // -----------------------------------------------
    // Analyze health
    // -----------------------------------------------

    final healthAnalyzer = HealthAnalyzer();

    final health = healthAnalyzer.analyze(
      packagesToCheck.toList(),
      packageInfo,
    );

    // -----------------------------------------------
    // Return result
    // -----------------------------------------------

    return DependencyAnalysisResult(
      directDependencies: directDependencies,
      lockedDependencies: lockedDependencies,
      graph: graph,
      health: health,
    );
  }
}
