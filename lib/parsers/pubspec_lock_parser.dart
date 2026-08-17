import 'dart:io';

import 'package:yaml/yaml.dart';

import '../models/locked_dependency.dart';

class PubspecLockParser {
  final String projectPath;

  const PubspecLockParser({required this.projectPath});

  List<LockedDependency> parse() {
    final file = File('$projectPath/pubspec.lock');

    if (!file.existsSync()) {
      throw Exception('pubspec.lock not found at: ${file.path}');
    }

    final content = file.readAsStringSync();

    final yaml = loadYaml(content);

    if (yaml is! YamlMap) {
      throw Exception('Invalid pubspec.lock format.');
    }

    final packages = yaml['packages'];

    if (packages is! YamlMap) {
      throw Exception('No packages section found in pubspec.lock.');
    }

    final dependencies = <LockedDependency>[];

    for (final entry in packages.entries) {
      final name = entry.key.toString();

      final package = entry.value;

      if (package is! YamlMap) {
        continue;
      }

      final version = package['version']?.toString() ?? 'unknown';

      final source = package['source']?.toString() ?? 'unknown';

      /*
       * pubspec.lock does not give us the complete
       * dependency classification that we need.
       *
       * Therefore, packages parsed directly from the
       * lock file are initially treated as transitive.
       *
       * The PubDepsParser will later provide the correct
       * kind: direct / dev / transitive.
       */
      const kind = 'transitive';

      final packageDependencies = <String>[];

      final dependencyList = package['dependencies'];

      if (dependencyList is YamlList) {
        for (final dependency in dependencyList) {
          packageDependencies.add(dependency.toString());
        }
      }

      dependencies.add(
        LockedDependency(
          name: name,
          version: version,
          source: source,
          kind: kind,
          dependencies: packageDependencies,
          directDependencies: const [],
          devDependencies: const [],
        ),
      );
    }

    return dependencies;
  }
}
