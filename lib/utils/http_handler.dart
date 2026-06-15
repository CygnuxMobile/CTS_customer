import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../configs/app_shared_key.dart';
import '../main.dart';

/// 🌐 Centralized HTTP Handler
class HttpHandler {
  /// 🔑 Generate Headers
  static Future<Map<String, String>> getHeaders() async {
    final String? token = Pref.getData(LocalStorageKey.token);
    debugPrint("🔑 Token: $token");

    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = "Bearer $token";
    }

    return headers;
  }

  /// 🌐 GET Request
  static Future<http.Response> getRequest({required String url, Map<String, String>? queryParams}) async {
    final headers = await getHeaders();

    final uri = queryParams != null ? Uri.parse(url).replace(queryParameters: queryParams) : Uri.parse(url);

    logger.d("➡️ GET $uri");
    logger.d("Headers: $headers");

    final response = await http.get(uri, headers: headers);

    _logResponse(response);
    return response;
  }

  /// 🌐 POST Request
  static Future<http.Response> postRequest({required String url, required Map<String, dynamic>? body}) async {
    final headers = await getHeaders();

    logger.d("➡️ POST $url");
    logger.d("Headers: $headers");
    logger.d("Body: $body");

    final response = await http.post(Uri.parse(url), headers: headers, body: body != null ? jsonEncode(body) : null);

    _logResponse(response);
    return response;
  }

  /// 🌐 PUT Request
  static Future<http.Response> putRequest({required String url, required Map<String, dynamic>? body}) async {
    final headers = await getHeaders();

    logger.d("➡️ PUT $url");
    logger.d("Headers: $headers");
    logger.d("Body: $body");

    final response = await http.put(Uri.parse(url), headers: headers, body: body != null ? jsonEncode(body) : null);

    _logResponse(response);
    return response;
  }

  /// 🌐 DELETE Request
  static Future<http.Response> deleteRequest({required String url, Map<String, dynamic>? body}) async {
    final headers = await getHeaders();

    logger.d("➡️ DELETE $url");
    logger.d("Headers: $headers");
    logger.d("Body: $body");

    final response = await http.delete(Uri.parse(url), headers: headers, body: body != null ? jsonEncode(body) : null);

    _logResponse(response);
    return response;
  }

  /// 📝 Common Response Logger
  static void _logResponse(http.Response response) {
    logger.d("⬅️ Status Code: ${response.statusCode}");

    if (response.body.isEmpty) {
      logger.d("Response Body: <EMPTY>");
      return;
    }

    try {
      final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body));
      logger.d("Response Body:\n$prettyJson");
    } catch (_) {
      logger.d("Response Body: ${response.body}");
    }
  }
}
