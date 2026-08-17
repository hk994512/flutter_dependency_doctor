import 'dart:convert';
import 'dart:io';

import '../models/locked_dependency.dart';

class PubDepsParser {
  final String projectPath;

  const PubDepsParser({required this.projectPath});

  List<LockedDependency> parse() {
    final result = Process.runSync(
      'dart',
      ['pub', 'deps', '--json'],
      workingDirectory: projectPath,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw Exception(
        'Failed to run "dart pub deps --json".\n'
        '${result.stderr}',
      );
    }

    final output = result.stdout.toString();

    if (output.trim().isEmpty) {
      throw Exception('No output received from "dart pub deps --json".');
    }

    final json = jsonDecode(output);

    if (json is! Map<String, dynamic>) {
      throw Exception(
        'Invalid JSON returned by '
        '"dart pub deps --json".',
      );
    }

    final packages = json['packages'];

    if (packages is! List) {
      throw Exception('No packages found in dependency output.');
    }

    return packages
        .whereType<Map<String, dynamic>>()
        .map(_parsePackage)
        .toList();
  }

  LockedDependency _parsePackage(Map<String, dynamic> package) {
    return LockedDependency(
      name: package['name']?.toString() ?? 'unknown',
      version: package['version']?.toString() ?? 'unknown',
      source: package['source']?.toString() ?? 'unknown',
      kind: package['kind']?.toString() ?? 'unknown',
      dependencies: _parseStringList(package['dependencies']),
      directDependencies: _parseStringList(package['directDependencies']),
      devDependencies: _parseStringList(package['devDependencies']),
    );
  }

  List<String> _parseStringList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value.map((item) => item.toString()).toList();
  }
}
