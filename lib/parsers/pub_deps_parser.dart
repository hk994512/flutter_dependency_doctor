import 'dart:convert';
import 'dart:io';

import '../models/locked_dependency.dart';

class PubDepsParser {
  const PubDepsParser({required this.projectPath});

  final String projectPath;

  List<LockedDependency> parse() {
    final result = Process.runSync(
      'dart',
      const ['pub', 'deps', '--json'],
      workingDirectory: projectPath,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      final stderr = result.stderr.toString().trim();

      throw ProcessException(
        'dart',
        const ['pub', 'deps', '--json'],
        stderr.isEmpty ? 'Failed to resolve project dependencies.' : stderr,
        result.exitCode,
      );
    }

    final output = result.stdout.toString().trim();

    if (output.isEmpty) {
      throw const FormatException(
        'No output received from "dart pub deps --json".',
      );
    }

    final dynamic json;

    try {
      json = jsonDecode(output);
    } on FormatException catch (e) {
      throw FormatException(
        'Invalid JSON returned by '
        '"dart pub deps --json": ${e.message}',
      );
    }

    if (json is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid JSON structure returned by '
        '"dart pub deps --json".',
      );
    }

    final packages = json['packages'];

    if (packages == null) {
      return const [];
    }

    if (packages is! List) {
      throw const FormatException(
        'Invalid dependency output: '
        '"packages" must be a list.',
      );
    }

    final dependencies = <LockedDependency>[];

    for (final package in packages) {
      if (package is! Map<String, dynamic>) {
        continue;
      }

      dependencies.add(_parsePackage(package));
    }

    return List.unmodifiable(dependencies);
  }

  LockedDependency _parsePackage(Map<String, dynamic> package) {
    final name = package['name']?.toString();

    if (name == null || name.isEmpty) {
      throw const FormatException(
        'Dependency entry is missing a package name.',
      );
    }

    return LockedDependency(
      name: name,
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
      return const [];
    }

    return List.unmodifiable(value.map((item) => item.toString()));
  }
}
