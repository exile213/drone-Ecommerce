import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class UserService {
  // Register user in MySQL after Firebase authentication
  static Future<Map<String, dynamic>> registerUser({
    required String firebaseUid,
    required String email,
    required String fullName,
    required String role,
    String? phone,
    String? address,
  }) async {
    final response = await ApiService.post(ApiConstants.authRegister, {
      'firebase_uid': firebaseUid,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'address': address,
    });

    if (response['success'] == true && response['user'] != null) {
      return {
        'success': true,
        'user': UserModel.fromJson(response['user']),
        'message': response['message'] ?? 'User registered successfully',
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Registration failed',
    };
  }

  // Login user (get user data from MySQL)
  static Future<Map<String, dynamic>> loginUser(String firebaseUid) async {
    final response = await ApiService.post(ApiConstants.authLogin, {
      'firebase_uid': firebaseUid,
    });

    if (response['success'] == true && response['user'] != null) {
      return {
        'success': true,
        'user': UserModel.fromJson(response['user']),
        'message': response['message'] ?? 'Login successful',
      };
    }

    return {'success': false, 'message': response['message'] ?? 'Login failed'};
  }

  // Get user by Firebase UID
  static Future<Map<String, dynamic>> getUser(String firebaseUid) async {
    final response = await ApiService.get(
      '${ApiConstants.authUser}&firebase_uid=$firebaseUid',
    );

    if (response['success'] == true && response['user'] != null) {
      return {'success': true, 'user': UserModel.fromJson(response['user'])};
    }

    return {
      'success': false,
      'message': response['message'] ?? 'User not found',
    };
  }
}
