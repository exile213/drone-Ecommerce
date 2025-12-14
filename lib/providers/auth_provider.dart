import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Initialize auth state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final firebaseUid = _authService.getFirebaseUid();
    if (firebaseUid != null) {
      await loadUser(firebaseUid);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load user from API
  Future<void> loadUser(String firebaseUid) async {
    final result = await UserService.getUser(firebaseUid);
    if (result['success'] && result['user'] != null) {
      _user = result['user'] as UserModel;
      notifyListeners();
    }
  }

  // Set user (after login/register)
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  // Clear user (logout)
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}

