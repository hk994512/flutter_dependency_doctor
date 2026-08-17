class PubPackageInfo {
  final String name;
  final String latestVersion;
  final bool discontinued;
  final String? publisher;
  final String? repository;

  const PubPackageInfo({
    required this.name,
    required this.latestVersion,
    required this.discontinued,
    this.publisher,
    this.repository,
  });
}
