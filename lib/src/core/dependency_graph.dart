import '../../models/dependency_info.dart';

class DependencyGraph {
  DependencyGraph({List<DependencyInfo> dependencies = const []})
    : _dependencies = {
        for (final dependency in dependencies) dependency.name: dependency,
      };

  final Map<String, DependencyInfo> _dependencies;

  /// All dependencies in the graph.
  List<DependencyInfo> get dependencies =>
      List.unmodifiable(_dependencies.values);

  /// Number of dependencies.
  int get length => _dependencies.length;

  /// Adds or replaces a dependency.
  void add(DependencyInfo dependency) {
    _dependencies[dependency.name] = dependency;
  }

  /// Gets a dependency by name.
  DependencyInfo? get(String name) {
    return _dependencies[name];
  }

  /// Whether the graph contains a package.
  bool contains(String name) {
    return _dependencies.containsKey(name);
  }

  /// Direct dependencies.
  List<DependencyInfo> get directDependencies {
    return dependencies
        .where((dependency) => dependency.isDirect)
        .toList(growable: false);
  }

  /// Transitive dependencies.
  List<DependencyInfo> get transitiveDependencies {
    return dependencies
        .where((dependency) => dependency.isTransitive)
        .toList(growable: false);
  }

  /// Dev dependencies.
  List<DependencyInfo> get devDependencies {
    return dependencies
        .where((dependency) => dependency.isDevDependency)
        .toList(growable: false);
  }

  /// Packages that depend on [packageName].
  List<DependencyInfo> dependentsOf(String packageName) {
    return dependencies
        .where((dependency) => dependency.dependencies.contains(packageName))
        .toList(growable: false);
  }

  /// Packages required by [packageName].
  List<Object> dependenciesOf(String packageName) {
    return get(packageName)?.dependencies ?? const [];
  }

  /// Removes all dependencies.
  void clear() {
    _dependencies.clear();
  }
}
