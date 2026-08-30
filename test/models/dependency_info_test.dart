
import 'package:flutter_dependency_doctor/models/dependency_info.dart';
import 'package:test/test.dart';

void main() {
  group('DependencyInfo', () {
    test('identifies direct dependency', () {
      const dependency = DependencyInfo(
        name: 'dio',
        version: '5.8.0',
        constraint: '^5.8.0',
        isDirect: true,
        isDevDependency: false,
      );

      expect(dependency.isDirect, isTrue);
      expect(dependency.isTransitive, isFalse);
    });

    test('identifies transitive dependency', () {
      const dependency = DependencyInfo(
        name: 'http_parser',
        version: '4.1.2',
        isDirect: false,
        isDevDependency: false,
      );

      expect(dependency.isDirect, isFalse);
      expect(dependency.isTransitive, isTrue);
    });

    test('copyWith preserves existing values', () {
      const dependency = DependencyInfo(
        name: 'dio',
        version: '5.8.0',
        isDirect: true,
        isDevDependency: false,
      );

      final updated = dependency.copyWith(version: '5.9.0');

      expect(updated.name, 'dio');
      expect(updated.version, '5.9.0');
      expect(updated.isDirect, isTrue);
    });
  });
}
