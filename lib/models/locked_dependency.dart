class LockedDependency {
  final String name;
  final String version;
  final String source;
  final String kind;

  final List<String> dependencies;
  final List<String> directDependencies;
  final List<String> devDependencies;

  const LockedDependency({
    required this.name,
    required this.version,
    required this.source,
    required this.kind,
    required this.dependencies,
    required this.directDependencies,
    required this.devDependencies,
  });

  bool get isDirect => kind == 'direct';

  bool get isDev => kind == 'dev';

  bool get isTransitive => kind == 'transitive';

  @override
  String toString() {
    return '$name $version [$kind]';
  }
}
