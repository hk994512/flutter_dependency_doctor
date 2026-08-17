import 'dart:io';

Future<void> main() async {
  print('Running Flutter Dependency Doctor...\n');

  final result = await Process.run('dart', [
    'run',
    'flutter_dependency_doctor',
  ], runInShell: true);

  stdout.write(result.stdout);

  if (result.stderr.toString().isNotEmpty) {
    stderr.write(result.stderr);
  }

  if (result.exitCode != 0) {
    print('\nDependency Doctor exited with code ${result.exitCode}');
  } else {
    print('\n✅ Dependency check complete.');
  }
}
