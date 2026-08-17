import 'package:flutter_dependency_doctor/models/locked_dependency.dart';
import 'package:test/test.dart';

void main() {
  group('LockedDependency', () {
    test('direct dependency should be identified correctly', () {
      const dependency = LockedDependency(
        name: 'http',
        version: '1.6.0',
        source: 'hosted',
        kind: 'direct',
        dependencies: ['async', 'meta'],
        directDependencies: ['http'],
        devDependencies: [],
      );

      expect(dependency.isDirect, isTrue);
      expect(dependency.isDev, isFalse);
      expect(dependency.isTransitive, isFalse);
    });

    test('dev dependency should be identified correctly', () {
      const dependency = LockedDependency(
        name: 'test',
        version: '1.31.2',
        source: 'hosted',
        kind: 'dev',
        dependencies: ['async'],
        directDependencies: [],
        devDependencies: ['test'],
      );

      expect(dependency.isDirect, isFalse);
      expect(dependency.isDev, isTrue);
      expect(dependency.isTransitive, isFalse);
    });

    test('transitive dependency should be identified correctly', () {
      const dependency = LockedDependency(
        name: 'async',
        version: '2.13.1',
        source: 'hosted',
        kind: 'transitive',
        dependencies: [],
        directDependencies: [],
        devDependencies: [],
      );

      expect(dependency.isDirect, isFalse);
      expect(dependency.isDev, isFalse);
      expect(dependency.isTransitive, isTrue);
    });

    test('dependencies should be stored correctly', () {
      const dependency = LockedDependency(
        name: 'http',
        version: '1.6.0',
        source: 'hosted',
        kind: 'direct',
        dependencies: ['async', 'meta', 'web'],
        directDependencies: ['http'],
        devDependencies: [],
      );

      expect(dependency.dependencies, equals(['async', 'meta', 'web']));
    });

    test('toString should contain package information', () {
      const dependency = LockedDependency(
        name: 'http',
        version: '1.6.0',
        source: 'hosted',
        kind: 'direct',
        dependencies: [],
        directDependencies: ['http'],
        devDependencies: [],
      );

      expect(dependency.toString(), equals('http 1.6.0 [direct]'));
    });
  });
}
