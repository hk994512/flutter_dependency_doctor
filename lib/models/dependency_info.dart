class DependencyInfo {
  const DependencyInfo({
    required this.name,
    required this.version,
    required this.isDirect,
    required this.isDevDependency,
    this.constraint,
    this.dependencies = const [],
  });

  /// Package name.
  final String name;

  /// Resolved version from pubspec.lock.
  final String version;

  /// Version constraint from pubspec.yaml.
  ///
  /// Example:
  /// ^3.0.0
  final String? constraint;

  /// Whether this package is directly declared
  /// in pubspec.yaml.
  final bool isDirect;

  /// Whether this package is a dev dependency.
  final bool isDevDependency;

  /// Packages required by this dependency.
  final List<String> dependencies;

  /// Whether this is a transitive dependency.
  bool get isTransitive => !isDirect;

  /// Creates a copy with modified fields.
  DependencyInfo copyWith({
    String? name,
    String? version,
    String? constraint,
    bool? isDirect,
    bool? isDevDependency,
    List<String>? dependencies,
  }) {
    return DependencyInfo(
      name: name ?? this.name,
      version: version ?? this.version,
      constraint: constraint ?? this.constraint,
      isDirect: isDirect ?? this.isDirect,
      isDevDependency: isDevDependency ?? this.isDevDependency,
      dependencies: dependencies ?? this.dependencies,
    );
  }

  @override
  String toString() {
    return 'DependencyInfo('
        'name: $name, '
        'version: $version, '
        'constraint: $constraint, '
        'isDirect: $isDirect, '
        'isDevDependency: $isDevDependency, '
        'dependencies: $dependencies'
        ')';
  }
}
