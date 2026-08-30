# Changelog

## 0.1.4

- Improved dependency parsing and validation.
- Improved `pubspec.lock` parsing and package metadata handling.
- Added dedicated `FileSystemException` handling when `pubspec.lock` is missing.
- Added `FormatException` handling for invalid lockfile structures and malformed dependency data.
- Improved handling of missing or invalid package information.
- Improved parsing of package versions and dependency sources.
- Improved parsing of dependency relationships, including direct, development, transitive, and root packages.
- Added root package detection through `isRoot`.
- Added dependency count reporting for root, production, development, and transitive dependencies.
- Parser results are now returned as unmodifiable lists.
- Improved analyzer integration between `pubspec.yaml` declarations and resolved dependencies.
- Expanded parser and model test coverage for valid, invalid, and edge-case dependency scenarios.

## 0.1.3

- Improved `example/example.dart` with command-line argument support.
- Added improved process execution and error handling to the example.
- Improved output handling for stdout and stderr.
- Improved example usability for local development, CI, and automation.

## 0.1.2

- Fixed the incomplete `LICENSE` file.
- Updated the license file so the package is correctly recognized as MIT licensed.

## 0.1.1

- Added a programmatic usage example in `example/example.dart`.
- Added basic guidance for running Flutter Dependency Doctor from a Dart script.

## 0.1.0

- Initial release of Flutter Dependency Doctor.
- Added dependency analysis for Dart and Flutter projects.
- Added dependency graph generation.
- Added package health analysis.
- Added pub.dev package information lookup.
- Added CLI support for dependency inspection.
