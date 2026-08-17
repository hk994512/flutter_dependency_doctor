# 🩺 Flutter Dependency Doctor

[![pub package](https://img.shields.io/pub/v/flutter_dependency_doctor.svg)](https://pub.dev/packages/flutter_dependency_doctor)
[![pub points](https://img.shields.io/pub/points/flutter_dependency_doctor)](https://pub.dev/packages/flutter_dependency_doctor/score)
[![likes](https://img.shields.io/pub/likes/flutter_dependency_doctor)](https://pub.dev/packages/flutter_dependency_doctor/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/hk994512/flutter_dependency_doctor?style=social)](https://github.com/hk994512/flutter_dependency_doctor/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/hk994512/flutter_dependency_doctor)](https://github.com/hk994512/flutter_dependency_doctor/issues)

A command-line tool built with Dart to help Flutter and Dart developers understand and maintain their project's dependencies.

It analyzes `pubspec.yaml` and `pubspec.lock`, builds a dependency graph, checks package health, detects outdated packages, and identifies packages requiring attention — all from your terminal.

---

## 🚀 Features

| | |
|---|---|
| 📦 | Analyze direct and dev dependencies |
| 🌳 | Build and display dependency graphs |
| 🔗 | Inspect transitive dependencies |
| ❤️ | Package health scoring |
| ⚠️ | Detect packages requiring attention |
| 🔄 | Check versions against the latest release |
| 🗑️ | Detect critical/deprecated packages |
| 🖥️ | Clean, readable CLI output |
| 📋 | Multiple CLI commands |
| 🧩 | Built entirely in Dart |

---

## 📥 Installation

Activate globally via pub:

```bash
dart pub global activate flutter_dependency_doctor
```

---

## 🛠️ Usage

Run inside the root of any Flutter or Dart project (where `pubspec.yaml` lives):

```bash
dart run flutter_dependency_doctor
```

Or, if activated globally:

```bash
flutter_dependency_doctor
```

View all available flags:

```bash
dart run flutter_dependency_doctor --help
```

---

## 📊 Sample Output

```
📦 Analyzing dependencies...

✅ http: up to date (1.5.0)
⚠️ provider: outdated (current 6.0.0, latest 6.1.2)
🌳 Dependency graph built successfully
🗑️ old_package: deprecated, consider removing
❤️ Overall project health: Good
```

---

## 🧭 Roadmap

- [ ] JSON/HTML report export
- [ ] Auto-fix suggestions for outdated packages
- [ ] CI/CD integration mode
- [ ] Custom rule configuration

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
Feel free to check the [issues page](https://github.com/hk994512/flutter_dependency_doctor/issues) or open a pull request.

1. Fork the repo
2. Create your branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Push and open a PR

---

## ⭐ Support

If this tool helped you, consider giving it a **star** ⭐ on [GitHub](https://github.com/hk994512/flutter_dependency_doctor) and a **like** 👍 on [pub.dev](https://pub.dev/packages/flutter_dependency_doctor) — it helps a lot!

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 👤 Author

**Muhammad Ameer Hamza**
Flutter Developer | Cross-Platform Mobile Applications
🔗 [Portfolio](https://engrhamzadev.netlify.app) • [GitHub](https://github.com/hk994512)
