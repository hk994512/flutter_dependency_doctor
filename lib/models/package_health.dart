enum HealthStatus { healthy, warning, critical }

class PackageHealth {
  final String packageName;
  final String currentVersion;
  final String? latestVersion;

  final HealthStatus status;

  final List<String> issues;
  final List<String> recommendations;

  const PackageHealth({
    required this.packageName,
    required this.currentVersion,
    required this.latestVersion,
    required this.status,
    required this.issues,
    required this.recommendations,
  });

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

  bool get isOutdated {
    if (latestVersion == null) {
      return false;
    }

    return currentVersion != latestVersion;
  }

  @override
  String toString() {
    return '$packageName $currentVersion '
        '[$status]';
  }
}
