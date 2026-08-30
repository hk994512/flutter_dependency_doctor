import 'dart:io';

/// Programmatic example for Flutter Dependency Doctor.
///
/// This example demonstrates how to invoke Flutter Dependency Doctor
/// from another Dart script.
///
/// Usage:
///
///   dart run example/example.dart
///   dart run example/example.dart /path/to/flutter/project
///
/// The project path defaults to the current working directory.
///
/// This is useful for:
/// - CI/CD pipelines
/// - custom build scripts
/// - local automation
/// - dependency checks before deployment
Future<void> main(List<String> args) async {
  if (_showHelp(args)) {
    _printUsage();
    return;
  }

  if (args.length > 1) {
    stderr.writeln('Error: Too many arguments.\n');
    _printUsage();
    exitCode = 64;
    return;
  }

  final projectPath = args.isEmpty ? Directory.current.path : args.first;

  final projectDirectory = Directory(projectPath);

  if (!projectDirectory.existsSync()) {
    stderr.writeln('Error: Project directory does not exist:');
    stderr.writeln('  $projectPath');
    exitCode = 66;
    return;
  }

  final pubspecFile = File(
    '${projectDirectory.path}${Platform.pathSeparator}pubspec.yaml',
  );

  if (!pubspecFile.existsSync()) {
    stderr.writeln('Error: No pubspec.yaml found in:');
    stderr.writeln('  ${projectDirectory.path}');
    stderr.writeln('Please provide the path to a Flutter/Dart project.');
    exitCode = 66;
    return;
  }

  stdout.writeln('🩺 Running Flutter Dependency Doctor...');
  stdout.writeln('📁 Project: ${projectDirectory.path}\n');

  final result = await _runDoctor(projectDirectory.path);

  if (result.stdout.isNotEmpty) {
    stdout.write(result.stdout);
  }

  if (result.stderr.isNotEmpty) {
    stderr.write(result.stderr);
  }

  if (result.exitCode == 0) {
    stdout.writeln('\n✅ Dependency check completed successfully.');
    exitCode = 0;
    return;
  }

  stderr.writeln(
    '\n⚠️ Dependency Doctor exited with code '
    '${result.exitCode}.',
  );

  stderr.writeln('Review the output above for dependency issues.');

  exitCode = result.exitCode;
}

/// Runs Flutter Dependency Doctor in the target project.
Future<ProcessResult> _runDoctor(String projectPath) async {
  return Process.run(
    'dart',
    ['run', 'flutter_dependency_doctor'],
    workingDirectory: projectPath,
    runInShell: true,
  );
}

/// Checks whether the user requested help.
bool _showHelp(List<String> args) {
  return args.length == 1 && (args.first == '--help' || args.first == '-h');
}

/// Prints command usage information.
void _printUsage() {
  stdout.writeln('''
Flutter Dependency Doctor - Dart Example

Usage:
  dart run example/example.dart
  dart run example/example.dart <project-path>

Options:
  -h, --help    Show this help message

Examples:
  dart run example/example.dart
  dart run example/example.dart ../my_flutter_app

The project path defaults to the current working directory.
''');
}
