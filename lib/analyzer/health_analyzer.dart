import 'package:pub_semver/pub_semver.dart';

import '../models/locked_dependency.dart';
import '../models/package_health.dart';
import '../models/pub_package_info.dart';
import 'package_recommendation.dart';

/// Analyzes dependency health using resolved package and pub.dev data.
///
/// Detects discontinued packages, available updates, and version
/// comparison problems, then generates recommendations where possible.
class HealthAnalyzer {
  /// Creates a health analyzer with a package recommendation engine.
  HealthAnalyzer({PackageRecommendationEngine? recommendationEngine})
    : recommendationEngine =
          recommendationEngine ?? PackageRecommendationEngine();

  /// Engine used to generate recommendations for unhealthy packages.
  final PackageRecommendationEngine recommendationEngine;

  /// Analyzes [packages] using information retrieved from pub.dev.
  ///
  /// Packages without available pub.dev information are reported with
  /// a warning status. Discontinued packages are reported as critical,
  /// while packages with newer available versions are reported as warnings.
  List<PackageHealth> analyze(
    List<LockedDependency> packages,
    Map<String, PubPackageInfo> packageInfo,
  ) {
    return packages.map((package) {
      final info = packageInfo[package.name];

      // Pub.dev information unavailable.
      if (info == null) {
        return PackageHealth(
          packageName: package.name,
          currentVersion: package.version,
          latestVersion: null,
          status: HealthStatus.warning,
          issues: const ['Package information unavailable.'],
          recommendations: const [],
        );
      }

      final issues = <String>[];
      final recommendations = <String>[];

      var status = HealthStatus.healthy;

      // --------------------------------------------------
      // Discontinued package
      // --------------------------------------------------

      if (info.discontinued) {
        status = HealthStatus.critical;

        issues.add('Package has been discontinued.');

        final recommendation = recommendationEngine.recommend(
          packageName: package.name,
          discontinued: true,
        );

        if (recommendation != null) {
          if (recommendation.alternative != null) {
            recommendations.add(
              'Recommended alternative: '
              '${recommendation.alternative}',
            );
          } else {
            recommendations.add(recommendation.reason);
          }
        }
      }

      // --------------------------------------------------
      // Version comparison
      // --------------------------------------------------

      try {
        final currentVersion = Version.parse(package.version);
        final latestVersion = Version.parse(info.latestVersion);

        if (latestVersion > currentVersion) {
          if (status != HealthStatus.critical) {
            status = HealthStatus.warning;
          }

          issues.add(
            'Newer version available: '
            '${info.latestVersion}',
          );

          recommendations.add(
            'Consider upgrading from '
            '${package.version} to '
            '${info.latestVersion}.',
          );
        }
      } catch (_) {
        issues.add('Unable to compare package versions.');
      }

      return PackageHealth(
        packageName: package.name,
        currentVersion: package.version,
        latestVersion: info.latestVersion,
        status: status,
        issues: issues,
        recommendations: recommendations,
      );
    }).toList();
  }
}
