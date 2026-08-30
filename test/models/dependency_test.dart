import 'package:flutter_dependency_doctor/models/dependency.dart';
import 'package:test/test.dart';

void main() {
  group('Dependency', () {
    test('creates a direct production dependency', () {
      const dependency = Dependency(
        name: 'dio',
        version: '^5.8.0',
        type: DependencyType.direct,
      );

      expect(dependency.name, 'dio');
      expect(dependency.version, '^5.8.0');
      expect(dependency.type, DependencyType.direct);
    });

    test('creates a dev dependency', () {
      const dependency = Dependency(
        name: 'mocktail',
        version: '^1.0.0',
        type: DependencyType.dev,
      );

      expect(dependency.name, 'mocktail');
      expect(dependency.version, '^1.0.0');
      expect(dependency.type, DependencyType.dev);
    });

    test('identifies direct dependency type', () {
      const dependency = Dependency(
        name: 'dio',
        version: '^5.8.0',
        type: DependencyType.direct,
      );

      expect(dependency.type, DependencyType.direct);
    });

    test('identifies dev dependency type', () {
      const dependency = Dependency(
        name: 'test',
        version: '^1.25.0',
        type: DependencyType.dev,
      );

      expect(dependency.type, DependencyType.dev);
    });
  });
}
