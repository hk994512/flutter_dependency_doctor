import 'dart:io';

import 'package:yaml/yaml.dart';

import '../models/dependency.dart';

class PubspecParser {
  final String projectPath;

  const PubspecParser({required this.projectPath});

  List<Dependency> parse() {
    final file = File('$projectPath/pubspec.yaml');

    if (!file.existsSync()) {
      throw FileSystemException('pubspec.yaml not found', file.path);
    }

    final content = file.readAsStringSync();

    final dynamic yaml;

    try {
      yaml = loadYaml(content);
    } on YamlException catch (e) {
      throw FormatException('Invalid pubspec.yaml: ${e.message}');
    }

    if (yaml is! YamlMap) {
      throw const FormatException(
        'Invalid pubspec.yaml format. Expected a YAML map.',
      );
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

    return List.unmodifiable(dependencies);
  }

  void _parseDependencySection(
    dynamic section,
    DependencyType type,
    List<Dependency> dependencies,
  ) {
    if (section == null) {
      return;
    }

    if (section is! YamlMap) {
      throw FormatException(
        'Invalid dependency section for ${type.name}. '
        'Expected a YAML map.',
      );
    }

    for (final entry in section.entries) {
      final name = entry.key.toString();
      final value = entry.value;

      final version = _parseDependencyValue(value);

      dependencies.add(Dependency(name: name, version: version, type: type));
    }
  }

  String _parseDependencyValue(dynamic value) {
    if (value is String) {
      return value;
    }

    if (value is YamlMap) {
      return _parseMapDependency(value);
    }

    return 'unknown';
  }

  String _parseMapDependency(YamlMap value) {
    if (value.containsKey('sdk')) {
      return 'sdk:${value['sdk']}';
    }

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
