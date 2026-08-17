import 'package:flutter_dependency_doctor/models/package_health.dart';
import 'package:test/test.dart';

void main() {
  group('PackageHealth', () {
    test('healthy package should have score 100', () {
      const health = PackageHealth(
        packageName: 'http',
        currentVersion: '1.6.0',
        latestVersion: '1.6.0',
        status: HealthStatus.healthy,
        issues: [],
        recommendations: [],
      );

      expect(health.score, 100);
    });

    test('warning package should have score 70', () {
      const health = PackageHealth(
        packageName: 'http',
        currentVersion: '1.5.0',
        latestVersion: '1.6.0',
        status: HealthStatus.warning,
        issues: ['Package is outdated'],
        recommendations: ['Update to the latest version'],
      );

      expect(health.score, 70);
    });

    test('critical package should have score 40', () {
      const health = PackageHealth(
        packageName: 'old_package',
        currentVersion: '1.0.0',
        latestVersion: null,
        status: HealthStatus.critical,
        issues: ['Package may be discontinued'],
        recommendations: ['Find an alternative package'],
      );

      expect(health.score, 40);
    });

    test('package should be outdated when versions differ', () {
      const health = PackageHealth(
        packageName: 'http',
        currentVersion: '1.5.0',
        latestVersion: '1.6.0',
        status: HealthStatus.warning,
        issues: [],
        recommendations: [],
      );

      expect(health.isOutdated, isTrue);
    });

    test('package should not be outdated when versions are equal', () {
      const health = PackageHealth(
        packageName: 'http',
        currentVersion: '1.6.0',
        latestVersion: '1.6.0',
        status: HealthStatus.healthy,
        issues: [],
        recommendations: [],
      );

      expect(health.isOutdated, isFalse);
    });

    test('package should not be outdated when latest version is unknown', () {
      const health = PackageHealth(
        packageName: 'http',
        currentVersion: '1.6.0',
        latestVersion: null,
        status: HealthStatus.healthy,
        issues: [],
        recommendations: [],
      );

      expect(health.isOutdated, isFalse);
    });

    test('toString should contain package name and version', () {
      const health = PackageHealth(
        packageName: 'http',
        currentVersion: '1.6.0',
        latestVersion: '1.6.0',
        status: HealthStatus.healthy,
        issues: [],
        recommendations: [],
      );

      expect(health.toString(), contains('http'));
      expect(health.toString(), contains('1.6.0'));
    });
  });
}
