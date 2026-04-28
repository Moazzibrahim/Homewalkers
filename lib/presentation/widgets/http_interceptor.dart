// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:homewalkers_app/main.dart';
import 'package:homewalkers_app/presentation/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homewalkers_app/data/data_sources/login_api_service.dart';

class HttpClientWithInterceptor {
  static final HttpClientWithInterceptor _instance =
      HttpClientWithInterceptor._internal();
  factory HttpClientWithInterceptor() => _instance;
  HttpClientWithInterceptor._internal();

  bool _isRefreshing = false;
  final List<_QueuedRequest> _queuedRequests = [];

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return _request(
      () async => http.get(url, headers: await _addAuthHeader(headers)),
      url.toString(),
    );
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _request(
      () async => http.post(
        url,
        headers: await _addAuthHeader(headers),
        body: body,
        encoding: encoding,
      ),
      url.toString(),
    );
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _request(
      () async => http.put(
        url,
        headers: await _addAuthHeader(headers),
        body: body,
        encoding: encoding,
      ),
      url.toString(),
    );
  }

  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _request(
      () async => http.delete(
        url,
        headers: await _addAuthHeader(headers),
        body: body,
        encoding: encoding,
      ),
      url.toString(),
    );
  }

  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _request(
      () async => http.patch(
        url,
        headers: await _addAuthHeader(headers),
        body: body,
        encoding: encoding,
      ),
      url.toString(),
    );
  }

  Future<Map<String, String>> _addAuthHeader(
    Map<String, String>? existingHeaders,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = Map<String, String>.from(existingHeaders ?? {});
    headers['Content-Type'] = 'application/json';

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<http.Response> _request(
    Future<http.Response> Function() requestFn,
    String url,
  ) async {
    try {
      var response = await requestFn();

      // If 401, try to refresh token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // ✅ اعمل refresh بس لو فيه token أصلاً
      if (response.statusCode == 401 && token != null && token.isNotEmpty) {
        log("🔑 401 Unauthorized for: $url");

        // If not refreshing, try to refresh token
        if (!_isRefreshing) {
          _isRefreshing = true;

          try {
            final newToken = await LoginApiService.refreshToken();

            if (newToken != null && newToken.isNotEmpty) {
              log("✅ Token refreshed, retrying request");

              // Update token in storage
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('token', newToken);

              // Retry all queued requests
              _isRefreshing = false;
              _retryQueuedRequests();

              // Retry current request
              response = await requestFn();
            } else {
              _isRefreshing = false;
              await _forceLogout();
              return response;
            }
          } catch (e) {
            _isRefreshing = false;
            await _forceLogout();
            return response;
          }
        } else {
          // Queue this request for later
          log("⏳ Token refresh in progress, queuing request");
          final completer = Completer<http.Response>();
          _queuedRequests.add(_QueuedRequest(completer, requestFn));
          return await completer.future;
        }
      }

      return response;
    } catch (e) {
      log("❌ HTTP Request error: $e");
      rethrow;
    }
  }

  void _retryQueuedRequests() async {
    if (_queuedRequests.isEmpty) return;

    log("🔄 Retrying ${_queuedRequests.length} queued requests");

    for (final queued in _queuedRequests) {
      try {
        final response = await queued.requestFn();
        queued.completer.complete(response);
      } catch (e) {
        queued.completer.completeError(e);
      }
    }

    _queuedRequests.clear();
  }

  Future<void> _forceLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to login screen
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );

      log("👋 User logged out due to authentication failure");
    } catch (e) {
      log("❌ Error during force logout: $e");
    }
  }
}

class _QueuedRequest {
  final Completer<http.Response> completer;
  final Future<http.Response> Function() requestFn;

  _QueuedRequest(this.completer, this.requestFn);
}

class HttpClient {
  static final HttpClientWithInterceptor _client = HttpClientWithInterceptor();

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    return _client.get(url, headers: headers);
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _client.post(url, headers: headers, body: body, encoding: encoding);
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _client.put(url, headers: headers, body: body, encoding: encoding);
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _client.delete(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _client.patch(url, headers: headers, body: body, encoding: encoding);
  }
}
