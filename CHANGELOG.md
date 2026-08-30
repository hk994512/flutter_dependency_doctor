# Changelog

## 0.1.4

### Improved

- Improved dependency resolution and package metadata parsing.
- Improved parsing of `pubspec.lock` and resolved dependency information.
- Improved dependency classification for root, production, development, and transitive packages.
- Added root package detection through `LockedDependency.isRoot`.
- Added dependency count reporting for root, production, development, and transitive dependencies.
- Improved validation of dependency data returned by `dart pub deps --json`.
- Improved handling of missing, malformed, and incomplete dependency information.
- Improved parsing of package versions and dependency sources.
- Improved dependency relationship parsing.
- Improved analyzer integration between declared and resolved dependencies.
- Parser results are now returned as unmodifiable lists.

### Error Handling

- Added dedicated `FileSystemException` handling for missing lockfiles.
- Added `FormatException` handling for invalid dependency and lockfile structures.
- Improved error messages for invalid or incomplete dependency data.

### Testing

- Expanded parser test coverage.
- Added tests for valid dependency structures.
- Added tests for invalid and incomplete dependency data.
- Added tests for root, direct, development, and transitive dependency classification.

## 0.1.3

### Improved

- Improved `example/example.dart` with command-line argument support.
- Improved process execution and error handling.
- Improved stdout and stderr handling.
- Improved example usability for local development, CI, and automation.

## 0.1.2

### Fixed

- Fixed the incomplete `LICENSE` file.
- Restored the complete MIT license text so the package is correctly recognized as MIT licensed.

## 0.1.1

### Added

- Added `example/example.dart`.
- Added a runnable example demonstrating how to invoke Flutter Dependency Doctor programmatically.

## 0.1.0

### Added

- Initial release of Flutter Dependency Doctor.
- Added dependency analysis for Dart and Flutter projects.
- Added dependency graph inspection.
- Added package health analysis.
- Added pub.dev package information lookup.
- Added command-line dependency inspection.
