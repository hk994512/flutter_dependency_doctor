/// Contains package metadata retrieved from pub.dev.
class PubPackageInfo {
  /// Creates pub.dev package information.
  const PubPackageInfo({
    required this.name,
    required this.latestVersion,
    required this.discontinued,
    this.publisher,
    this.repository,
  });

  /// Name of the package.
  final String name;

  /// Latest version reported by pub.dev.
  final String latestVersion;

  /// Whether the package has been marked as discontinued.
  final bool discontinued;

  /// Publisher associated with the package, if available.
  final String? publisher;

  /// Repository URL associated with the package, if available.
  final String? repository;
}
