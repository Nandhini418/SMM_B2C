import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginApiService {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';
  static const String _cid = '44555666';

  // ─────────────────────────────────────────────
  //  STEP 1 – SEND OTP  (type:5001)
  // ─────────────────────────────────────────────

  /// Sends OTP to [mobile]. Returns the decoded response body map.
  /// Throws on network / timeout errors.
  static Future<Map<String, dynamic>> sendOtp({
    required String mobile,
    required String latitude,
    required String longitude,
    required String deviceId,
    required String appSignature,
  }) async {
    final requestBody = {
      'cid': _cid,
      'type': '5001',
      'ln': longitude,
      'lt': latitude,
      'device_id': deviceId,
      'mobile': mobile,
      'app_signature': appSignature,
    };

    debugPrint('========== OTP API REQUEST ==========');
    debugPrint(requestBody.toString());
    debugPrint('=====================================');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: requestBody,
    );

    debugPrint('========== OTP API RESPONSE ==========');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body  : ${response.body}');
    debugPrint('======================================');

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ─────────────────────────────────────────────
  //  STEP 2 – VERIFY OTP  (type:5002)
  // ─────────────────────────────────────────────

  /// Verifies [otp] for [mobile]. Returns the decoded response body map.
  /// Throws on network / timeout errors.
  static Future<Map<String, dynamic>> verifyOtp({
    required String mobile,
    required String otp,
    required String token,
    required String latitude,
    required String longitude,
    required String deviceId,
  }) async {
    final requestBody = {
      'type': '5002',
      'cid': _cid,
      'ln': longitude,
      'lt': latitude,
      'device_id': deviceId,
      'mobile': mobile,
      'otp': otp,
      'token': token,
    };

    debugPrint('========== VERIFY API REQUEST ==========');
    debugPrint(requestBody.toString());
    debugPrint('========================================');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: requestBody,
    );

    debugPrint('========== VERIFY API RESPONSE ==========');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body  : ${response.body}');
    debugPrint('=========================================');

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

// ignore: avoid_print
void debugPrint(String message) => print(message);