import 'dart:io';

import 'package:flutter_dependency_doctor/models/locked_dependency.dart';
import 'package:flutter_dependency_doctor/parsers/pubspec_lock_parser.dart';

import 'package:test/test.dart';

void main() {
  late Directory tempDirectory;

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync(
      'flutter_dependency_doctor_lock_test_',
    );
  });

  tearDown(() {
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  void createLockfile(String content) {
    File('${tempDirectory.path}/pubspec.lock').writeAsStringSync(content);
  }

  PubspecLockParser createParser() {
    return PubspecLockParser(projectPath: tempDirectory.path);
  }

  group('PubspecLockParser', () {
    test('parses hosted package', () {
      createLockfile('''
packages:
  dio:
    dependency: "direct main"
    description:
      name: dio
      url: "https://pub.dev"
    source: hosted
    version: "5.8.0"
''');

      final dependencies = createParser().parse();

      expect(dependencies.length, 1);

      final dio = dependencies.first;

      expect(dio.name, 'dio');
      expect(dio.version, '5.8.0');
      expect(dio.source, 'hosted');
      expect(dio.kind, 'transitive');
      expect(dio.dependencies, isEmpty);
      expect(dio.directDependencies, isEmpty);
      expect(dio.devDependencies, isEmpty);
    });

    test('parses package dependencies', () {
      createLockfile('''
packages:
  dio:
    dependency: "direct main"
    description:
      name: dio
      url: "https://pub.dev"
    source: hosted
    version: "5.8.0"
    dependencies:
      - async
      - collection
      - http_parser

  collection:
    dependency: transitive
    description:
      name: collection
      url: "https://pub.dev"
    source: hosted
    version: "1.19.0"
''');

      final dependencies = createParser().parse();

      expect(dependencies.length, 2);

      final dio = dependencies.firstWhere(
        (dependency) => dependency.name == 'dio',
      );

      expect(
        dio.dependencies,
        containsAll(['async', 'collection', 'http_parser']),
      );
    });

    test('parses git package', () {
      createLockfile('''
packages:
  my_package:
    dependency: "direct main"
    description:
      path: "."
      ref: main
      resolved-ref: abc123
      url: "https://github.com/example/my_package.git"
    source: git
    version: "1.0.0"
''');

      final dependencies = createParser().parse();

      expect(dependencies.length, 1);

      final dependency = dependencies.first;

      expect(dependency.name, 'my_package');
      expect(dependency.version, '1.0.0');
      expect(dependency.source, 'git');
      expect(dependency.kind, 'transitive');
    });

    test('parses path package', () {
      createLockfile('''
packages:
  local_package:
    dependency: "direct main"
    description:
      path: "../local_package"
    source: path
    version: "1.0.0"
''');

      final dependencies = createParser().parse();

      expect(dependencies.length, 1);

      final dependency = dependencies.first;

      expect(dependency.name, 'local_package');
      expect(dependency.version, '1.0.0');
      expect(dependency.source, 'path');
    });

    test('parses sdk package', () {
      createLockfile('''
packages:
  flutter:
    dependency: "direct main"
    description: flutter
    source: sdk
    version: "0.0.0"
''');

      final dependencies = createParser().parse();

      expect(dependencies.length, 1);

      final dependency = dependencies.first;

      expect(dependency.name, 'flutter');
      expect(dependency.version, '0.0.0');
      expect(dependency.source, 'sdk');
    });

    test('parses multiple packages', () {
      createLockfile('''
packages:
  dio:
    dependency: "direct main"
    description:
      name: dio
      url: "https://pub.dev"
    source: hosted
    version: "5.8.0"

  provider:
    dependency: "direct main"
    description:
      name: provider
      url: "https://pub.dev"
    source: hosted
    version: "6.1.2"

  collection:
    dependency: transitive
    description:
      name: collection
      url: "https://pub.dev"
    source: hosted
    version: "1.19.0"
''');

      final dependencies = createParser().parse();

      expect(dependencies.length, 3);

      expect(
        dependencies.map((dependency) => dependency.name),
        containsAll(['dio', 'provider', 'collection']),
      );
    });

    test('handles package without version', () {
      createLockfile('''
packages:
  custom_package:
    dependency: transitive
    description:
      name: custom_package
    source: hosted
''');

      final dependencies = createParser().parse();

      expect(dependencies.length, 1);
      expect(dependencies.first.version, 'unknown');
    });

    test('handles package without source', () {
      createLockfile('''
packages:
  custom_package:
    dependency: transitive
    description:
      name: custom_package
    version: "1.0.0"
''');

      final dependencies = createParser().parse();

      expect(dependencies.length, 1);
      expect(dependencies.first.source, 'unknown');
    });

    test('handles package without dependencies', () {
      createLockfile('''
packages:
  dio:
    dependency: transitive
    description:
      name: dio
    source: hosted
    version: "5.8.0"
''');

      final dependencies = createParser().parse();

      expect(dependencies.first.dependencies, isEmpty);
    });

    test('handles missing packages section', () {
      createLockfile('''
sdks:
  dart: "3.10.3"
  flutter: "3.38.4"
''');

      final dependencies = createParser().parse();

      expect(dependencies, isEmpty);
    });

    test('throws when pubspec.lock does not exist', () {
      final parser = createParser();

      expect(parser.parse, throwsA(isA<FileSystemException>()));
    });

    test('throws when lockfile is not a YAML map', () {
      createLockfile('''
- dio
- provider
''');

      final parser = createParser();

      expect(parser.parse, throwsA(isA<FormatException>()));
    });

    test('throws when packages is not a YAML map', () {
      createLockfile('''
packages:
  - dio
  - provider
''');

      final parser = createParser();

      expect(parser.parse, throwsA(isA<FormatException>()));
    });

    test('ignores invalid package entries', () {
      createLockfile('''
packages:
  dio:
    source: hosted
    version: "5.8.0"

  invalid_package:
    - invalid
''');

      final dependencies = createParser().parse();

      expect(dependencies.length, 1);
      expect(dependencies.first.name, 'dio');
    });

    test('returns an unmodifiable list', () {
      createLockfile('''
packages:
  dio:
    source: hosted
    version: "5.8.0"
''');

      final dependencies = createParser().parse();

      expect(
        () => dependencies.add(
          const LockedDependency(
            name: 'test',
            version: '1.0.0',
            source: 'hosted',
            kind: 'transitive',
            dependencies: [],
            directDependencies: [],
            devDependencies: [],
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
