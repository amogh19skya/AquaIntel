import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Interface for AquaBot AI Service (DIP).
abstract class IAquaBotService {
  Future<AquaBotResponse> sendMessage(
    String message, {
    List<Map<String, String>> history = const [],
    String? sessionId,
    String? userId,
  });

  Future<String> getActiveBaseUrl();
  Future<void> setCustomBaseUrl(String url);
}

/// Holds both the AI reply text and the persisted session ID.
class AquaBotResponse {
  final String reply;
  final String? sessionId;
  final bool success;

  const AquaBotResponse({
    required this.reply,
    required this.success,
    this.sessionId,
  });
}

/// Production implementation connecting Flutter to FastAPI AquaBot backend.
/// Automatically detects and supports:
/// - Real physical Android phones via USB (adb reverse 127.0.0.1:8000)
/// - Real physical Android phones via Wi-Fi LAN (192.168.0.101:8000)
/// - Android Emulators (10.0.2.2:8000)
/// - Web / iOS / Desktop (localhost:8000)
/// - User-configured custom IP / URL saved in SharedPreferences
class AquaBotService implements IAquaBotService {
  static const String _kCustomUrlKey = 'aquabot_backend_url';

  // Known candidate URLs in priority order
  static const List<String> _defaultCandidates = [
    'http://127.0.0.1:8000',      // Physical device via adb reverse
    'http://192.168.0.101:8000',  // Physical device via local Wi-Fi LAN
    'http://10.0.2.2:8000',       // Android emulator host loopback
    'http://localhost:8000',      // Localhost / Web / Desktop
  ];

  static String? _cachedWorkingUrl;
  final String? _explicitBaseUrl;
  final http.Client _client;

  AquaBotService({
    String? baseUrl,
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _explicitBaseUrl = baseUrl;

  @override
  Future<String> getActiveBaseUrl() async {
    if (_explicitBaseUrl != null && _explicitBaseUrl.isNotEmpty) {
      return _explicitBaseUrl;
    }
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getString(_kCustomUrlKey);
    if (custom != null && custom.trim().isNotEmpty) {
      return custom.trim();
    }
    return _cachedWorkingUrl ?? _defaultCandidates.first;
  }

  @override
  Future<void> setCustomBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final clean = url.trim().replaceAll(RegExp(r'/+$'), '');
    await prefs.setString(_kCustomUrlKey, clean);
    _cachedWorkingUrl = clean;
  }

  /// Returns the ordered list of URLs to try.
  Future<List<String>> _resolveCandidates() async {
    if (_explicitBaseUrl != null && _explicitBaseUrl.isNotEmpty) {
      return [_explicitBaseUrl];
    }
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getString(_kCustomUrlKey);

    final list = <String>[];
    if (custom != null && custom.trim().isNotEmpty) {
      list.add(custom.trim());
    }
    if (_cachedWorkingUrl != null && !list.contains(_cachedWorkingUrl)) {
      list.add(_cachedWorkingUrl!);
    }

    if (kIsWeb) {
      if (!list.contains('http://localhost:8000')) {
        list.add('http://localhost:8000');
      }
      return list;
    }

    for (final candidate in _defaultCandidates) {
      if (!list.contains(candidate)) {
        list.add(candidate);
      }
    }
    return list;
  }

  @override
  Future<AquaBotResponse> sendMessage(
    String message, {
    List<Map<String, String>> history = const [],
    String? sessionId,
    String? userId,
  }) async {
    final candidates = await _resolveCandidates();
    String attemptedUrls = '';

    for (final candidate in candidates) {
      final endpoint = Uri.parse('$candidate/api/chat');
      attemptedUrls += (attemptedUrls.isEmpty ? '' : ', ') + candidate;
      debugPrint('[AquaBotService] Trying $endpoint (session: $sessionId)');

      try {
        final body = jsonEncode({
          'message': message,
          'history': history,
          if (sessionId != null) 'session_id': sessionId,
          if (userId != null) 'user_id': userId,
        });

        final response = await _client
            .post(
              endpoint,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: body,
            )
            .timeout(const Duration(seconds: 25));

        debugPrint('[AquaBotService] Status ${response.statusCode} from $candidate');

        if (response.statusCode == 200) {
          // Success! Cache this working URL so future requests go straight here
          _cachedWorkingUrl = candidate;

          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final reply = data['reply'] as String? ?? '';
          final newSessionId = data['session_id'] as String?;
          return AquaBotResponse(
            reply: reply.isNotEmpty
                ? reply
                : 'I received an empty response. Please try again.',
            sessionId: newSessionId,
            success: true,
          );
        } else {
          debugPrint('[AquaBotService] Server returned error (${response.statusCode}) from $candidate');
        }
      } on SocketException catch (e) {
        debugPrint('[AquaBotService] SocketException on $candidate: $e');
        // Continue loop to try next candidate (e.g. Wi-Fi IP or adb reverse)
        continue;
      } on TimeoutException {
        debugPrint('[AquaBotService] Timeout on $candidate');
        continue;
      } catch (e) {
        debugPrint('[AquaBotService] Error on $candidate: $e');
        continue;
      }
    }

    return AquaBotResponse(
      reply: 'Could not connect to backend server ($attemptedUrls).\n\n'
          'Please ensure:\n'
          '1. The Python FastAPI backend is started (running on port 8000).\n'
          '2. If using USB, run: adb reverse tcp:8000 tcp:8000\n'
          '3. Or configure your PC Wi-Fi IP in AquaBot settings.',
      success: false,
    );
  }
}
