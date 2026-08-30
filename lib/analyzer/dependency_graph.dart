import '../models/locked_dependency.dart';

/// Represents the resolved dependency graph of a Dart or Flutter project.
///
/// Provides methods for looking up packages, inspecting dependencies,
/// finding dependents, and separating direct, development, and transitive
/// dependencies.
class DependencyGraph {
  /// Creates a dependency graph from the resolved dependencies.
  DependencyGraph({required List<LockedDependency> dependencies})
    : packages = {
        for (final dependency in dependencies) dependency.name: dependency,
      };

  /// All resolved packages indexed by package name.
  final Map<String, LockedDependency> packages;

  /// Returns the total number of resolved packages in the graph.
  int get packageCount => packages.length;

  /// Returns whether a package with [packageName] exists in the graph.
  bool contains(String packageName) {
    return packages.containsKey(packageName);
  }

  /// Returns the resolved package with [packageName], if available.
  LockedDependency? getPackage(String packageName) {
    return packages[packageName];
  }

  /// Returns the direct dependencies required by [packageName].
  ///
  /// Returns an empty list when the package is not present in the graph.
  List<String> getDependencies(String packageName) {
    final package = packages[packageName];

    if (package == null) {
      return const [];
    }

    return List.unmodifiable(package.dependencies);
  }

  /// Finds packages that directly depend on [packageName].
  ///
  /// The returned list contains package names rather than dependency
  /// objects and is unmodifiable.
  List<String> findDependents(String packageName) {
    final dependents = <String>[];

    for (final package in packages.values) {
      if (package.dependencies.contains(packageName)) {
        dependents.add(package.name);
      }
    }

    return List.unmodifiable(dependents);
  }

  /// Returns all production/direct packages in the graph.
  List<LockedDependency> get directPackages {
    return List.unmodifiable(
      packages.values.where((package) => package.isDirect),
    );
  }

  /// Returns all development packages in the graph.
  List<LockedDependency> get devPackages {
    return List.unmodifiable(packages.values.where((package) => package.isDev));
  }

  /// Returns all transitive packages in the graph.
  List<LockedDependency> get transitivePackages {
    return List.unmodifiable(
      packages.values.where((package) => package.isTransitive),
    );
  }

  /// Finds all transitive dependencies reachable from [packageName].
  ///
  /// The starting package itself is excluded from the returned set.
  /// The traversal uses breadth-first search and safely handles dependency
  /// cycles.
  Set<String> findTransitiveDependencies(String packageName) {
    final visited = <String>{};
    final queue = <String>[packageName];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      if (!visited.add(current)) {
        continue;
      }

      final package = packages[current];

      if (package == null) {
        continue;
      }

      queue.addAll(package.dependencies);
    }

    visited.remove(packageName);

    return Set.unmodifiable(visited);
  }
}
