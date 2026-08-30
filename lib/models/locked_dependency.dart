class LockedDependency {
  const LockedDependency({
    required this.name,
    required this.version,
    required this.source,
    required this.kind,
    required this.dependencies,
    required this.directDependencies,
    required this.devDependencies,
  });

  /// Package name.
  final String name;

  /// Resolved package version.
  final String version;

  /// Dependency source, such as `hosted`, `git`, or `path`.
  final String source;

  /// Dependency classification:
  /// `root`, `direct`, `dev`, or `transitive`.
  final String kind;

  /// All dependencies required by this package.
  final List<String> dependencies;

  /// Direct dependencies associated with this package.
  final List<String> directDependencies;

  /// Development dependencies associated with this package.
  final List<String> devDependencies;

  /// Whether this is a production/direct dependency.
  bool get isDirect => kind == 'direct';

  /// Whether this is a development dependency.
  bool get isDev => kind == 'dev';

  /// Whether this is a transitive dependency.
  bool get isTransitive => kind == 'transitive';

  /// Whether this is the root project package.
  bool get isRoot => kind == 'root';

  @override
  String toString() {
    return '$name $version [$kind]';
  }
}
