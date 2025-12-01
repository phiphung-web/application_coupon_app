import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode, $message)';
}

class ApiClient {
  ApiClient({
    HttpClient? httpClient,
  }) : _client = httpClient ?? HttpClient();

  final HttpClient _client;

  String get _base =>
      AppConfig.baseUrl.endsWith('/') ? AppConfig.baseUrl : '${AppConfig.baseUrl}/';

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final baseUri = Uri.parse(_base);
    final resolved = baseUri.resolve(normalizedPath);

    if (query == null || query.isEmpty) return resolved;

    final qp = <String, String>{};
    query.forEach((key, value) {
      if (value == null) return;
      qp[key] = value.toString();
    });
    return resolved.replace(queryParameters: qp);
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final uri = _buildUri(path, query);
    try {
      final request = await _client.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(timeout);
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode >= 400) {
        throw ApiException(response.statusCode, body);
      }
      if (body.isEmpty) return {};
      return jsonDecode(body);
    } on ApiException {
      rethrow;
    } on TimeoutException catch (e) {
      throw ApiException(408, e.message ?? 'Request timeout');
    } catch (e) {
      debugPrint('ApiClient error: $e');
      rethrow;
    }
  }
}
