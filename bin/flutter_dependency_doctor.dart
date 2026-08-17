import 'dart:io';

import 'package:flutter_dependency_doctor/analyzer/dependency_analyzer.dart';
import 'package:flutter_dependency_doctor/analyzer/dependency_graph.dart';
import 'package:flutter_dependency_doctor/models/package_health.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    await runAnalyze();
    return;
  }

  final command = arguments.first.toLowerCase();

  switch (command) {
    case 'analyze':
      await runAnalyze();
      break;

    case 'outdated':
      await runOutdated();
      break;

    case 'deprecated':
      await runDeprecated();
      break;

    case 'graph':
      await runGraph();
      break;

    case 'help':
    case '--help':
    case '-h':
      _printHelp();
      break;

    case '--version':
    case '-v':
      _printVersion();
      break;

    default:
      print('');
      print('❌ Unknown command: $command');
      print('');
      _printHelp();
      exitCode = 1;
  }
}

// ============================================================
// ANALYZE PROJECT
// ============================================================

Future<DependencyAnalysisResult?> _analyzeProject() async {
  try {
    final analyzer = DependencyAnalyzer(projectPath: Directory.current.path);

    return await analyzer.analyze();
  } catch (e) {
    print('');
    print('❌ Analysis failed');
    print('────────────────────────────────────');
    print(e);
    print('');

    return null;
  }
}

// ============================================================
// ANALYZE COMMAND
// ============================================================

Future<void> runAnalyze() async {
  final result = await _analyzeProject();

  if (result == null) {
    exitCode = 1;
    return;
  }

  print('');
  print('Flutter Dependency Doctor');
  print('════════════════════════════════════');
  print('');

  _printDependencySummary(result);

  _printProductionDependencies(result.graph);

  _printDevelopmentDependencies(result.graph);

  _printHealthSummary(result.health);

  _printPackageDetails(result.health);

  print('');
}

// ============================================================
// DEPENDENCY SUMMARY
// ============================================================

void _printDependencySummary(DependencyAnalysisResult result) {
  print('Dependency Summary');
  print('────────────────────────────────────');

  print(
    'Production dependencies:  '
    '${result.productionDependencyCount}',
  );

  print(
    'Development dependencies: '
    '${result.devDependencyCount}',
  );

  print(
    'Transitive dependencies:  '
    '${result.transitiveDependencyCount}',
  );

  print(
    'Total resolved packages:   '
    '${result.graph.packageCount}',
  );

  print('');
}

// ============================================================
// OUTDATED COMMAND
// ============================================================

Future<void> runOutdated() async {
  final result = await _analyzeProject();

  if (result == null) {
    exitCode = 1;
    return;
  }

  print('');
  print('Outdated Packages');
  print('════════════════════════════════════');
  print('');

  final outdated = result.health
      .where((package) => package.isOutdated)
      .toList();

  if (outdated.isEmpty) {
    print('✓ All checked packages are up to date.');
    print('');
    return;
  }

  print(
    'Found ${outdated.length} outdated package'
    '${outdated.length == 1 ? '' : 's'}:',
  );

  print('');

  for (final package in outdated) {
    print('⚠ ${package.packageName}');

    print('  Current: ${package.currentVersion}');

    print('  Latest:  ${package.latestVersion}');

    if (package.recommendations.isNotEmpty) {
      print('  Recommendations:');

      for (final recommendation in package.recommendations) {
        print('  → $recommendation');
      }
    }

    print('');
  }
}

// ============================================================
// DEPRECATED / CRITICAL COMMAND
// ============================================================

Future<void> runDeprecated() async {
  final result = await _analyzeProject();

  if (result == null) {
    exitCode = 1;
    return;
  }

  print('');
  print('Deprecated / Critical Packages');
  print('════════════════════════════════════');
  print('');

  final criticalPackages = result.health
      .where((package) => package.status == HealthStatus.critical)
      .toList();

  if (criticalPackages.isEmpty) {
    print('✓ No critical packages detected.');
    print('');
    return;
  }

  print(
    'Found ${criticalPackages.length} critical package'
    '${criticalPackages.length == 1 ? '' : 's'}:',
  );

  print('');

  for (final package in criticalPackages) {
    print(
      '✗ ${package.packageName} '
      '${package.currentVersion}',
    );

    if (package.issues.isNotEmpty) {
      print('  Issues:');

      for (final issue in package.issues) {
        print('  • $issue');
      }
    }

    if (package.recommendations.isNotEmpty) {
      print('  Recommendations:');

      for (final recommendation in package.recommendations) {
        print('  → $recommendation');
      }
    }

    print('');
  }
}

// ============================================================
// GRAPH COMMAND
// ============================================================

Future<void> runGraph() async {
  final result = await _analyzeProject();

  if (result == null) {
    exitCode = 1;
    return;
  }

  print('');
  print('Dependency Graph');
  print('════════════════════════════════════');
  print('');

  _printProductionDependencies(result.graph);

  _printDevelopmentDependencies(result.graph);

  print('');
}

// ============================================================
// PRODUCTION DEPENDENCY GRAPH
// ============================================================

void _printProductionDependencies(DependencyGraph graph) {
  print('Production Dependency Graph');
  print('────────────────────────────────────');

  final packages = graph.directPackages;

  if (packages.isEmpty) {
    print('');
    print('No production dependencies found.');
    print('');
    return;
  }

  for (final package in packages) {
    print('');

    print('📦 ${package.name} ${package.version}');

    if (package.dependencies.isEmpty) {
      continue;
    }

    for (final dependency in package.dependencies) {
      final child = graph.packages[dependency];

      if (child == null) {
        print('├── $dependency');
      } else {
        print(
          '├── ${child.name} '
          '${child.version}',
        );
      }
    }
  }

  print('');
}

// ============================================================
// DEVELOPMENT DEPENDENCY GRAPH
// ============================================================

void _printDevelopmentDependencies(DependencyGraph graph) {
  print('Development Dependencies');
  print('────────────────────────────────────');

  final packages = graph.devPackages;

  if (packages.isEmpty) {
    print('');
    print('No development dependencies found.');
    print('');
    return;
  }

  for (final package in packages) {
    print('');

    print('🛠 ${package.name} ${package.version}');

    if (package.dependencies.isEmpty) {
      continue;
    }

    for (final dependency in package.dependencies) {
      final child = graph.packages[dependency];

      if (child == null) {
        print('├── $dependency');
      } else {
        print(
          '├── ${child.name} '
          '${child.version}',
        );
      }
    }
  }

  print('');
}

// ============================================================
// HEALTH SUMMARY
// ============================================================

void _printHealthSummary(List<PackageHealth> health) {
  print('Package Health');
  print('────────────────────────────────────');

  if (health.isEmpty) {
    print('Health Score: 100/100');
    print('Healthy:  0');
    print('Warnings: 0');
    print('Critical: 0');
    print('');

    return;
  }

  final totalScore =
      health.map((package) => package.score).reduce((a, b) => a + b) ~/
      health.length;

  final healthy = health
      .where((package) => package.status == HealthStatus.healthy)
      .length;

  final warnings = health
      .where((package) => package.status == HealthStatus.warning)
      .length;

  final critical = health
      .where((package) => package.status == HealthStatus.critical)
      .length;

  print('Health Score: $totalScore/100');

  print('Healthy:  $healthy');

  print('Warnings: $warnings');

  print('Critical: $critical');

  print('');
}

// ============================================================
// PACKAGE DETAILS
// ============================================================

void _printPackageDetails(List<PackageHealth> health) {
  print('Package Details');
  print('────────────────────────────────────');

  if (health.isEmpty) {
    print('');
    print('No package health information available.');
    print('');

    return;
  }

  for (final package in health) {
    final symbol = switch (package.status) {
      HealthStatus.healthy => '✓',
      HealthStatus.warning => '⚠',
      HealthStatus.critical => '✗',
    };

    print('');

    print(
      '$symbol ${package.packageName} '
      '${package.currentVersion}',
    );

    if (package.latestVersion != null) {
      print('  Latest: ${package.latestVersion}');
    }

    if (package.issues.isNotEmpty) {
      for (final issue in package.issues) {
        print('  Issue: $issue');
      }
    }

    if (package.recommendations.isNotEmpty) {
      for (final recommendation in package.recommendations) {
        print('  → $recommendation');
      }
    }
  }
}

// ============================================================
// HELP
// ============================================================

void _printHelp() {
  print('');
  print('Flutter Dependency Doctor');
  print('');

  print('Usage:');
  print('  dart run flutter_dependency_doctor <command>');

  print('');

  print('Commands:');

  print('  analyze       Analyze project dependencies');

  print('  outdated      Show outdated packages');

  print('  deprecated    Show deprecated/critical packages');

  print('  graph         Show dependency graph');

  print('  help          Show this help message');

  print('');

  print('Options:');

  print('  -h, --help    Show help');

  print('  -v, --version Show version');

  print('');
}

// ============================================================
// VERSION
// ============================================================

void _printVersion() {
  print('Flutter Dependency Doctor 0.1.0');
}
