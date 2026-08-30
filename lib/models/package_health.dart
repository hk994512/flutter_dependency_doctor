/// Represents the health status of a dependency.
enum HealthStatus {
  /// The package is healthy and has no detected issues.
  healthy,

  /// The package has issues that should be reviewed.
  warning,

  /// The package has a critical issue requiring attention.
  critical,
}

/// Contains health and maintenance information for a package.
class PackageHealth {
  /// Creates a package health result.
  const PackageHealth({
    required this.packageName,
    required this.currentVersion,
    required this.latestVersion,
    required this.status,
    required this.issues,
    required this.recommendations,
  });

  /// Name of the analyzed package.
  final String packageName;

  /// Version currently resolved by the project.
  final String currentVersion;

  /// Latest version reported by pub.dev, if available.
  final String? latestVersion;

  /// Overall health status of the package.
  final HealthStatus status;

  /// Issues detected during dependency health analysis.
  final List<String> issues;

  /// Recommended actions for addressing detected issues.
  final List<String> recommendations;

  /// Returns a numeric health score based on [status].
  ///
  /// Healthy packages receive 100 points, packages with warnings
  /// receive 70 points, and critical packages receive 40 points.
  int get score {
    switch (status) {
      case HealthStatus.healthy:
        return 100;

      case HealthStatus.warning:
        return 70;

      case HealthStatus.critical:
        return 40;
    }
  }

  /// Returns whether the resolved version differs from the latest
  /// available version.
  ///
  /// Returns `false` when the latest version is unavailable.
  bool get isOutdated {
    if (latestVersion == null) {
      return false;
    }

    return currentVersion != latestVersion;
  }

  /// Returns a readable representation of the package health result.
  @override
  String toString() {
    return '$packageName $currentVersion '
        '[$status]';
  }
}
