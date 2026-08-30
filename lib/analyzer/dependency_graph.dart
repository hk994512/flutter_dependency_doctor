import '../models/locked_dependency.dart';

class DependencyGraph {
  DependencyGraph({required List<LockedDependency> dependencies})
    : packages = {
        for (final dependency in dependencies) dependency.name: dependency,
      };

  final Map<String, LockedDependency> packages;

  /// Number of packages in the graph.
  int get packageCount => packages.length;

  /// Returns a package by name.
  LockedDependency? getPackage(String packageName) {
    return packages[packageName];
  }

  /// Whether a package exists in the graph.
  bool contains(String packageName) {
    return packages.containsKey(packageName);
  }

  /// Direct dependencies.
  List<LockedDependency> get directPackages {
    return List.unmodifiable(
      packages.values.where((package) => package.isDirect),
    );
  }

  /// Development dependencies.
  List<LockedDependency> get devPackages {
    return List.unmodifiable(packages.values.where((package) => package.isDev));
  }

  /// Transitive dependencies.
  List<LockedDependency> get transitivePackages {
    return List.unmodifiable(
      packages.values.where((package) => package.isTransitive),
    );
  }

  /// Returns the packages directly required by [packageName].
  List<String> getDependencies(String packageName) {
    final package = packages[packageName];

    if (package == null) {
      return const [];
    }

    return List.unmodifiable(package.dependencies);
  }

  /// Finds packages that directly depend on [packageName].
  List<String> findDependents(String packageName) {
    final dependents = <String>[];

    for (final package in packages.values) {
      if (package.dependencies.contains(packageName)) {
        dependents.add(package.name);
      }
    }

    return List.unmodifiable(dependents);
  }

  /// Finds the dependency chain from [packageName] to
  /// all reachable dependencies.
  ///
  /// This is useful later for "why is this package installed?"
  /// and impact analysis.
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
