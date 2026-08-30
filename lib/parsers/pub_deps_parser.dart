import 'dart:convert';
import 'dart:io';

import '../models/locked_dependency.dart';

/// Parses the resolved dependency information produced by
/// `dart pub deps --json`.
class PubDepsParser {
  /// Creates a dependency parser for the project at [projectPath].
  const PubDepsParser({required this.projectPath});

  /// Path to the Dart or Flutter project being analyzed.
  final String projectPath;

  /// Resolves and parses all dependencies in the project.
  ///
  /// Returns an unmodifiable list of [LockedDependency] objects.
  ///
  /// Throws:
  /// - [ProcessException] when `dart pub deps --json` fails.
  /// - [FormatException] when the command returns invalid data.
  List<LockedDependency> parse() {
    final result = Process.runSync(
      'dart',
      const <String>['pub', 'deps', '--json'],
      workingDirectory: projectPath,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      final stderr = result.stderr.toString().trim();

      throw ProcessException(
        'dart',
        const <String>['pub', 'deps', '--json'],
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

    final dynamic decoded;

    try {
      decoded = jsonDecode(output);
    } on FormatException catch (error) {
      throw FormatException(
        'Invalid JSON returned by '
        '"dart pub deps --json": ${error.message}',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid JSON structure returned by '
        '"dart pub deps --json".',
      );
    }

    final packages = decoded['packages'];

    if (packages == null) {
      throw const FormatException(
        'Invalid dependency output: '
        '"packages" field is missing.',
      );
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
    final name = package['name']?.toString().trim();

    if (name == null || name.isEmpty) {
      throw const FormatException(
        'Dependency entry is missing a package name.',
      );
    }

    final version = package['version']?.toString().trim();
    final source = package['source']?.toString().trim();
    final kind = package['kind']?.toString().trim();

    return LockedDependency(
      name: name,
      version: version == null || version.isEmpty ? 'unknown' : version,
      source: source == null || source.isEmpty ? 'unknown' : source,
      kind: kind == null || kind.isEmpty ? 'unknown' : kind,
      dependencies: _parseStringList(package['dependencies']),
      directDependencies: _parseStringList(package['directDependencies']),
      devDependencies: _parseStringList(package['devDependencies']),
    );
  }

  List<String> _parseStringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return List.unmodifiable(
      value.map((item) => item.toString()).where((item) => item.isNotEmpty),
    );
  }
}
