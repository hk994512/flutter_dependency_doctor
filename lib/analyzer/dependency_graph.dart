import '../models/locked_dependency.dart';

class DependencyGraph {
  DependencyGraph({required List<LockedDependency> dependencies})
    : packages = {
        for (final dependency in dependencies) dependency.name: dependency,
      };

  final Map<String, LockedDependency> packages;

  int get packageCount => packages.length;

  bool contains(String packageName) {
    return packages.containsKey(packageName);
  }

  LockedDependency? getPackage(String packageName) {
    return packages[packageName];
  }

  List<String> getDependencies(String packageName) {
    final package = packages[packageName];

    if (package == null) {
      return const [];
    }

    return List.unmodifiable(package.dependencies);
  }

  List<String> findDependents(String packageName) {
    final dependents = <String>[];

    for (final package in packages.values) {
      if (package.dependencies.contains(packageName)) {
        dependents.add(package.name);
      }
    }

    return List.unmodifiable(dependents);
  }

  List<LockedDependency> get directPackages {
    return List.unmodifiable(
      packages.values.where((package) => package.isDirect),
    );
  }

  List<LockedDependency> get devPackages {
    return List.unmodifiable(packages.values.where((package) => package.isDev));
  }

  List<LockedDependency> get transitivePackages {
    return List.unmodifiable(
      packages.values.where((package) => package.isTransitive),
    );
  }

  /// Returns all packages reachable from [packageName].
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
