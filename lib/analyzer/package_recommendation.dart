/// Represents a recommendation for replacing or addressing a package.
class PackageRecommendation {
  /// Creates a package recommendation.
  const PackageRecommendation({
    required this.packageName,
    required this.alternative,
    required this.reason,
  });

  /// Name of the package that needs attention.
  final String packageName;

  /// Suggested alternative package name, if one is known.
  final String? alternative;

  /// Explanation describing why the recommendation was made.
  final String reason;
}

/// Generates recommendations for dependency health issues.
///
/// The engine can provide known alternatives for discontinued packages
/// while falling back to a generic recommendation when no verified
/// alternative is available.
class PackageRecommendationEngine {
  /// Creates a package recommendation engine.
  const PackageRecommendationEngine();

  /// Maps discontinued package names to known maintained alternatives.
  ///
  /// Only verified package mappings should be added to this map.
  static const Map<String, String> knownAlternatives = {};

  /// Generates a recommendation for [packageName].
  ///
  /// Returns `null` when the package is not discontinued.
  ///
  /// If a verified alternative is available, it is included in the
  /// recommendation. Otherwise, the result advises the user to search
  /// for a maintained alternative.
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
