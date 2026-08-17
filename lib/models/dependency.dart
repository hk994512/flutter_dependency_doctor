class Dependency {
  final String name;
  final String version;
  final DependencyType type;

  const Dependency({
    required this.name,
    required this.version,
    required this.type,
  });

  @override
  String toString() {
    return '$name $version (${type.name})';
  }
}

enum DependencyType { direct, dev, transitive }
