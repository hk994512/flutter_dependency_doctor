import 'dart:io';

import 'package:yaml/yaml.dart';

import '../models/dependency.dart';

class PubspecParser {
  final String projectPath;

  const PubspecParser({required this.projectPath});

  List<Dependency> parse() {
    final file = File('$projectPath/pubspec.yaml');

    if (!file.existsSync()) {
      throw Exception('pubspec.yaml not found at: ${file.path}');
    }

    final content = file.readAsStringSync();
    final yaml = loadYaml(content);

    if (yaml is! YamlMap) {
      throw Exception('Invalid pubspec.yaml format.');
    }

    final dependencies = <Dependency>[];

    _parseDependencySection(
      yaml['dependencies'],
      DependencyType.direct,
      dependencies,
    );

    _parseDependencySection(
      yaml['dev_dependencies'],
      DependencyType.dev,
      dependencies,
    );

    return dependencies;
  }

  void _parseDependencySection(
    dynamic section,
    DependencyType type,
    List<Dependency> dependencies,
  ) {
    if (section is! YamlMap) {
      return;
    }

    for (final entry in section.entries) {
      final name = entry.key.toString();
      final value = entry.value;

      String version;

      if (value is String) {
        version = value;
      } else if (value is YamlMap) {
        version = _parseMapDependency(value);
      } else {
        version = 'unknown';
      }

      dependencies.add(Dependency(name: name, version: version, type: type));
    }
  }

  String _parseMapDependency(YamlMap value) {
    if (value.containsKey('version')) {
      return value['version'].toString();
    }

    if (value.containsKey('git')) {
      return 'git';
    }

    if (value.containsKey('path')) {
      return 'path';
    }

    if (value.containsKey('hosted')) {
      return 'hosted';
    }

    return 'unknown';
  }
}
