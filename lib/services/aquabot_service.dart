import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Interface for AquaBot AI Service (DIP).
abstract class IAquaBotService {
  Future<AquaBotResponse> sendMessage(
    String message, {
    List<Map<String, String>> history = const [],
    String? sessionId,
    String? userId,
  });
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
class AquaBotService implements IAquaBotService {
  final String baseUrl;
  final http.Client _client;

  AquaBotService({
    String? baseUrl,
    http.Client? client,
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? _defaultBaseUrl();

  /// Automatically resolves host URL for Android Emulator vs Desktop/Web/iOS.
  static String _defaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    try {
      if (Platform.isAndroid) {
        // Android emulator maps 10.0.2.2 to the host machine localhost
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {}
    return 'http://localhost:8000';
  }

  @override
  Future<AquaBotResponse> sendMessage(
    String message, {
    List<Map<String, String>> history = const [],
    String? sessionId,
    String? userId,
  }) async {
    final endpoint = Uri.parse('$baseUrl/api/chat');

    debugPrint('[AquaBotService] POST $endpoint (session: $sessionId)');

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
          .timeout(const Duration(seconds: 40));

      debugPrint('[AquaBotService] Status ${response.statusCode}');

      if (response.statusCode == 200) {
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
        debugPrint('[AquaBotService] Error body: ${response.body}');
        return AquaBotResponse(
          reply:
              'AquaBot server returned error (${response.statusCode}). Please ensure the Python backend is running.',
          success: false,
        );
      }
    } on TimeoutException {
      return AquaBotResponse(
        reply:
            'Request timed out. Please check if the backend server is running on $baseUrl.',
        success: false,
      );
    } on SocketException {
      return AquaBotResponse(
        reply:
            'Could not connect to backend ($baseUrl). Make sure the Python FastAPI server is started.',
        success: false,
      );
    } catch (e) {
      return AquaBotResponse(
        reply: 'An unexpected error occurred communicating with AquaBot: $e',
        success: false,
      );
    }
  }
}
