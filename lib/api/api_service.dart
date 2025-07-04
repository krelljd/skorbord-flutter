import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';

/// ApiService: REST client with error handling and retry logic.
class ApiService {
  final String baseUrl;
  final int maxRetries;
  final Duration retryDelay;
  final Duration timeout;

  ApiService({
    required this.baseUrl,
    this.maxRetries = 3,
    this.retryDelay = const Duration(milliseconds: 500),
    this.timeout = const Duration(seconds: 10),
  });

  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    return _retry(() => http
        .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
        .timeout(timeout));
  }

  Future<http.Response> post(String endpoint,
      {Object? body, Map<String, String>? headers}) async {
    return _retry(() => http
        .post(Uri.parse('$baseUrl$endpoint'),
            headers: headers, body: jsonEncode(body))
        .timeout(timeout));
  }

  Future<http.Response> put(String endpoint,
      {Object? body, Map<String, String>? headers}) async {
    return _retry(() => http
        .put(Uri.parse('$baseUrl$endpoint'),
            headers: headers, body: jsonEncode(body))
        .timeout(timeout));
  }

  Future<http.Response> delete(String endpoint,
      {Map<String, String>? headers}) async {
    return _retry(() => http
        .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
        .timeout(timeout));
  }

  /// GET /games/:id
  Future<Game> getGame(String id) async {
    final response = await get('/games/$id');
    final data = jsonDecode(response.body);
    return Game.fromJson(data);
  }

  Future<T> _retry<T>(Future<T> Function() fn) async {
    int attempt = 0;
    while (true) {
      try {
        final result = await fn();
        if (result is http.Response &&
            (result.statusCode < 200 || result.statusCode >= 300)) {
          throw ApiException('HTTP ${result.statusCode}: ${result.body}');
        }
        return result;
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          // Optionally log the error here
          rethrow;
        }
        await Future.delayed(retryDelay);
      }
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}
