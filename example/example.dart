import 'dart:io';

/// Example: Using Flutter Dependency Doctor programmatically.
///
/// Flutter Dependency Doctor is primarily a command-line tool — it does not
/// currently expose a public Dart library API. This example shows how to
/// invoke the CLI from within a Dart script and handle its output/exit code,
/// which is useful if you want to run it as part of a custom build script,
/// CI pipeline, or automation tool.
Future<void> main(List<String> args) async {
  final projectPath = args.isNotEmpty ? args[0] : Directory.current.path;

  print('🩺 Running Flutter Dependency Doctor on: $projectPath\n');

  final result = await Process.run(
    'dart',
    ['run', 'flutter_dependency_doctor'],
    workingDirectory: projectPath,
    runInShell: true,
  );

  if (result.stdout.toString().isNotEmpty) {
    stdout.write(result.stdout);
  }

  if (result.stderr.toString().isNotEmpty) {
    stderr.write(result.stderr);
  }

  switch (result.exitCode) {
    case 0:
      print('\n✅ Dependency check complete — no critical issues found.');
      break;
    default:
      print('\n⚠️ Dependency Doctor exited with code ${result.exitCode}.');
      print('Review the output above for details.');
  }

  exit(result.exitCode);
}
