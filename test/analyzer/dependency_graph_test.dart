import 'package:flutter_dependency_doctor/analyzer/dependency_graph.dart';
import 'package:flutter_dependency_doctor/models/locked_dependency.dart';
import 'package:test/test.dart';

void main() {
  group('DependencyGraph', () {
    late DependencyGraph graph;

    setUp(() {
      final dependencies = [
        const LockedDependency(
          name: 'http',
          version: '1.6.0',
          source: 'hosted',
          kind: 'direct',
          dependencies: ['async', 'meta'],
          directDependencies: ['http'],
          devDependencies: [],
        ),
        const LockedDependency(
          name: 'test',
          version: '1.31.2',
          source: 'hosted',
          kind: 'dev',
          dependencies: ['async'],
          directDependencies: [],
          devDependencies: ['test'],
        ),
        const LockedDependency(
          name: 'async',
          version: '2.13.1',
          source: 'hosted',
          kind: 'transitive',
          dependencies: [],
          directDependencies: [],
          devDependencies: [],
        ),
        const LockedDependency(
          name: 'meta',
          version: '1.19.0',
          source: 'hosted',
          kind: 'transitive',
          dependencies: [],
          directDependencies: [],
          devDependencies: [],
        ),
      ];

      graph = DependencyGraph(dependencies: dependencies);
    });

    test('should contain all packages', () {
      expect(graph.packageCount, 4);

      expect(graph.contains('http'), isTrue);
      expect(graph.contains('test'), isTrue);
      expect(graph.contains('async'), isTrue);
      expect(graph.contains('meta'), isTrue);
    });

    test('should return false for missing package', () {
      expect(graph.contains('unknown_package'), isFalse);
    });

    test('should return package dependencies', () {
      expect(graph.getDependencies('http'), equals(['async', 'meta']));
    });

    test('should return empty dependencies for unknown package', () {
      expect(graph.getDependencies('unknown_package'), isEmpty);
    });

    test('should find dependents correctly', () {
      expect(graph.findDependents('async'), containsAll(['http', 'test']));
    });

    test('should find dependents of meta', () {
      expect(graph.findDependents('meta'), equals(['http']));
    });

    test('should return direct packages', () {
      final directPackages = graph.directPackages;

      expect(directPackages.length, 1);
      expect(directPackages.first.name, 'http');
    });

    test('should return development packages', () {
      final devPackages = graph.devPackages;

      expect(devPackages.length, 1);
      expect(devPackages.first.name, 'test');
    });

    test('should return transitive packages', () {
      final transitivePackages = graph.transitivePackages;

      expect(transitivePackages.length, 2);

      expect(
        transitivePackages.map((package) => package.name),
        containsAll(['async', 'meta']),
      );
    });

    test(
      'should return empty dependencies for package with no dependencies',
      () {
        expect(graph.getDependencies('async'), isEmpty);
      },
    );
  });
}
