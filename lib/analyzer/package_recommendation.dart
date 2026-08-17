class PackageRecommendation {
  final String packageName;
  final String? alternative;
  final String reason;

  const PackageRecommendation({
    required this.packageName,
    required this.alternative,
    required this.reason,
  });
}

class PackageRecommendationEngine {
  static const Map<String, String> knownAlternatives = {
    // We'll add verified package mappings here.
  };

  PackageRecommendation? recommend({
    required String packageName,
    required bool discontinued,
  }) {
    if (!discontinued) {
      return null;
    }

    final alternative = knownAlternatives[packageName];

    if (alternative == null) {
      return PackageRecommendation(
        packageName: packageName,
        alternative: null,
        reason:
            'Package is discontinued. '
            'Search for a maintained alternative.',
      );
    }

    return PackageRecommendation(
      packageName: packageName,
      alternative: alternative,
      reason:
          'Package is discontinued. '
          'Consider using $alternative.',
    );
  }
}
