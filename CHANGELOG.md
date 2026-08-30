# Changelog

## 0.1.4

- Improved `pubspec.lock` parsing.
- Added specific `FileSystemException` handling when `pubspec.lock` is missing.
- Added `FormatException` handling for invalid lockfile structures.
- Gracefully handles lockfiles without a `packages` section.
- Improved parsing of package versions and sources.
- Improved parsing of transitive dependency relationships.
- Parser now returns an unmodifiable dependency list.
- Expanded parser test coverage for valid and invalid lockfile scenarios.

## 0.1.3

- Improved `example/example.dart` with argument support and better error handling.

## 0.1.2

- Fixed incomplete LICENSE file (now properly recognized as MIT).

## 0.1.1

- Added usage example (`example/example.dart`).

## 0.1.0

- Initial release.
