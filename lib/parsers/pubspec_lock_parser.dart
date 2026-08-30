import 'dart:io';

import 'package:yaml/yaml.dart';

import '../models/locked_dependency.dart';

class PubspecLockParser {
  final String projectPath;

  const PubspecLockParser({required this.projectPath});

  List<LockedDependency> parse() {
    final file = File('$projectPath/pubspec.lock');

    if (!file.existsSync()) {
      throw FileSystemException('pubspec.lock not found', file.path);
    }

    final content = file.readAsStringSync();

    final dynamic yaml;

    try {
      yaml = loadYaml(content);
    } on YamlException catch (e) {
      throw FormatException('Invalid pubspec.lock: ${e.message}');
    }

    if (yaml is! YamlMap) {
      throw const FormatException(
        'Invalid pubspec.lock format. Expected a YAML map.',
      );
    }

    final packages = yaml['packages'];

    if (packages == null) {
      return const [];
    }

    if (packages is! YamlMap) {
      throw const FormatException(
        'Invalid pubspec.lock: packages must be a YAML map.',
      );
    }

    final dependencies = <LockedDependency>[];

    for (final entry in packages.entries) {
      final name = entry.key.toString();
      final package = entry.value;

      if (package is! YamlMap) {
        continue;
      }

      final version = _parseVersion(package);
      final source = _parseSource(package);
      final packageDependencies = _parseDependencies(package['dependencies']);

      dependencies.add(
        LockedDependency(
          name: name,
          version: version,
          source: source,
          kind: 'transitive',
          dependencies: packageDependencies,
          directDependencies: const [],
          devDependencies: const [],
        ),
      );
    }

    return List.unmodifiable(dependencies);
  }

  String _parseVersion(YamlMap package) {
    return package['version']?.toString() ?? 'unknown';
  }

  String _parseSource(YamlMap package) {
    return package['source']?.toString() ?? 'unknown';
  }

  List<String> _parseDependencies(dynamic value) {
    if (value is! YamlList) {
      return const [];
    }

    return List.unmodifiable(value.map((dependency) => dependency.toString()));
  }
}
