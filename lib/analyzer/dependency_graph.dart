import '../models/locked_dependency.dart';

class DependencyGraph {
  final Map<String, LockedDependency> packages;

  DependencyGraph({required List<LockedDependency> dependencies})
    : packages = {
        for (final dependency in dependencies) dependency.name: dependency,
      };

  List<String> getDependencies(String packageName) {
    return packages[packageName]?.dependencies ?? [];
  }

  List<String> findDependents(String packageName) {
    final dependents = <String>[];

    for (final package in packages.values) {
      if (package.dependencies.contains(packageName)) {
        dependents.add(package.name);
      }
    }

    return dependents;
  }

  bool contains(String packageName) {
    return packages.containsKey(packageName);
  }

  int get packageCount => packages.length;

  List<LockedDependency> get directPackages {
    return packages.values.where((package) => package.isDirect).toList();
  }

  List<LockedDependency> get devPackages {
    return packages.values.where((package) => package.isDev).toList();
  }

  List<LockedDependency> get transitivePackages {
    return packages.values.where((package) => package.isTransitive).toList();
  }
}
