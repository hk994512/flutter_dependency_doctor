/// Represents a dependency declared in a project's `pubspec.yaml`.
class Dependency {
  /// Creates a dependency description.
  const Dependency({
    required this.name,
    required this.version,
    required this.type,
  });

  /// The name of the dependency package.
  final String name;

  /// The version constraint declared in `pubspec.yaml`.
  final String version;

  /// The type of dependency.
  final DependencyType type;

  /// Whether this is a production dependency.
  bool get isDirect => type == DependencyType.direct;

  /// Whether this is a development dependency.
  bool get isDev => type == DependencyType.dev;

  /// Whether this is a transitive dependency.
  bool get isTransitive => type == DependencyType.transitive;

  @override
  String toString() {
    return '$name $version [$type]';
  }
}

/// Defines the classification of a dependency.
enum DependencyType {
  /// A dependency required by the application at runtime.
  direct,

  /// A dependency used during development, testing, or tooling.
  dev,

  /// A dependency resolved indirectly through another dependency.
  transitive,
}
