import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  // Get base URL based on platform
  static String getBaseUrl() {
    // For web, use the configured base URL
    if (kIsWeb) {
      return ApiConstants.baseUrl;
    }

    // For Android, use 10.0.2.2 to access host machine's localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2/ecommercephp-api';
    }

    // For iOS simulator, localhost works
    if (Platform.isIOS) {
      return 'http://localhost/ecommercephp-api';
    }

    // For physical devices (Android/iOS), you may need to use your computer's IP
    // Example: 'http://192.168.1.xxx/ecommercephp-api'
    // This can be configured via environment variable or settings
    return ApiConstants.baseUrl;
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('${getBaseUrl()}$endpoint');
      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out after 30 seconds');
            },
          );

      return _handleResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Network error: Request timed out. The server may be slow or unavailable.',
      };
    } on SocketException {
      return {
        'success': false,
        'message':
            'Network error: Unable to connect to server. Please check your internet connection and ensure the server is running.',
      };
    } on HttpException catch (e) {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      String errorMsg = 'Network error: ${e.toString()}';
      if (e.toString().contains('timeout') ||
          e.toString().contains('Timeout')) {
        errorMsg =
            'Network error: Request timed out. The server may be slow or unavailable.';
      }
      return {'success': false, 'message': errorMsg};
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('${getBaseUrl()}$endpoint');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out after 30 seconds');
            },
          );

      return _handleResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Network error: Request timed out. The server may be slow or unavailable.',
      };
    } on SocketException {
      return {
        'success': false,
        'message':
            'Network error: Unable to connect to server. Please check your internet connection and ensure the server is running.',
      };
    } on HttpException catch (e) {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      String errorMsg = 'Network error: ${e.toString()}';
      if (e.toString().contains('timeout') ||
          e.toString().contains('Timeout')) {
        errorMsg =
            'Network error: Request timed out. The server may be slow or unavailable.';
      }
      return {'success': false, 'message': errorMsg};
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('${getBaseUrl()}$endpoint');
      final response = await http
          .put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out after 30 seconds');
            },
          );

      return _handleResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Network error: Request timed out. The server may be slow or unavailable.',
      };
    } on SocketException {
      return {
        'success': false,
        'message':
            'Network error: Unable to connect to server. Please check your internet connection and ensure the server is running.',
      };
    } on HttpException catch (e) {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      String errorMsg = 'Network error: ${e.toString()}';
      if (e.toString().contains('timeout') ||
          e.toString().contains('Timeout')) {
        errorMsg =
            'Network error: Request timed out. The server may be slow or unavailable.';
      }
      return {'success': false, 'message': errorMsg};
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('${getBaseUrl()}$endpoint');
      final response = await http
          .delete(url)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out after 30 seconds');
            },
          );

      return _handleResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Network error: Request timed out. The server may be slow or unavailable.',
      };
    } on SocketException {
      return {
        'success': false,
        'message':
            'Network error: Unable to connect to server. Please check your internet connection and ensure the server is running.',
      };
    } on HttpException catch (e) {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      String errorMsg = 'Network error: ${e.toString()}';
      if (e.toString().contains('timeout') ||
          e.toString().contains('Timeout')) {
        errorMsg =
            'Network error: Request timed out. The server may be slow or unavailable.';
      }
      return {'success': false, 'message': errorMsg};
    }
  }

  // POST with multipart (for file uploads)
  static Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    String fieldName,
    List<int> fileBytes,
    String fileName,
  ) async {
    try {
      final url = Uri.parse('${getBaseUrl()}$endpoint');
      var request = http.MultipartRequest('POST', url);

      request.files.add(
        http.MultipartFile.fromBytes(fieldName, fileBytes, filename: fileName),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Longer timeout for file uploads
        onTimeout: () {
          throw TimeoutException('Upload timed out after 60 seconds');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Network error: Upload timed out. The file may be too large or the server is slow.',
      };
    } on SocketException {
      return {
        'success': false,
        'message':
            'Network error: Unable to connect to server. Please check your internet connection and ensure the server is running.',
      };
    } on HttpException catch (e) {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      String errorMsg = 'Network error: ${e.toString()}';
      if (e.toString().contains('timeout') ||
          e.toString().contains('Timeout')) {
        errorMsg =
            'Network error: Upload timed out. The file may be too large or the server is slow.';
      }
      return {'success': false, 'message': errorMsg};
    }
  }

  // Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    // Handle empty responses
    if (response.body.isEmpty || response.body.trim().isEmpty) {
      if (response.statusCode == 404) {
        return {
          'success': false,
          'message':
              'API endpoint not found (404). Please verify the server is running and the API path is correct.',
          'statusCode': 404,
        };
      }
      return {
        'success': false,
        'message':
            'Empty response from server. The server may not be configured correctly.',
        'statusCode': response.statusCode,
      };
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        // Handle specific HTTP status codes
        String errorMessage = data['message'] ?? 'Request failed';

        if (response.statusCode == 404) {
          errorMessage =
              'API endpoint not found (404). Please verify the server is running and the API path is correct.';
        } else if (response.statusCode == 500) {
          errorMessage =
              data['message'] ??
              'Server error (500). Please try again later or contact support.';
        } else if (response.statusCode == 400) {
          errorMessage =
              data['message'] ??
              'Invalid request. Please check your input and try again.';
        } else if (response.statusCode == 401) {
          errorMessage = 'Unauthorized. Please log in again.';
        } else if (response.statusCode == 403) {
          errorMessage =
              'Access forbidden. You do not have permission to perform this action.';
        }

        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on FormatException {
      // Handle malformed JSON
      final preview = response.body.length > 200
          ? response.body.substring(0, 200) + '...'
          : response.body;
      return {
        'success': false,
        'message':
            'Invalid response from server. The server may not be configured correctly. Response: $preview',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response: $e',
        'statusCode': response.statusCode,
      };
    }
  }
}
