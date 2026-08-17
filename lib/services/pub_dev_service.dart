import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pub_package_info.dart';

class PubDevService {
  final http.Client client;

  PubDevService({http.Client? client}) : client = client ?? http.Client();

  Future<PubPackageInfo?> getPackageInfo(String packageName) async {
    final uri = Uri.parse('https://pub.dev/api/packages/$packageName');

    try {
      final response = await client.get(uri);

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        return null;
      }

      final latest = data['latest'];

      if (latest is! Map<String, dynamic>) {
        return null;
      }

      final version = latest['version']?.toString();

      if (version == null) {
        return null;
      }

      final pubspec = latest['pubspec'];

      String? publisher;
      String? repository;

      if (pubspec is Map) {
        publisher = pubspec['publisher']?.toString();
        repository = pubspec['repository']?.toString();
      }

      return PubPackageInfo(
        name: packageName,
        latestVersion: version,
        discontinued: latest['discontinued'] == true,
        publisher: publisher,
        repository: repository,
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    client.close();
  }
}
