class UserModel {
  final int? id;
  final String firebaseUid;
  final String email;
  final String role;
  final String fullName;
  final String? phone;
  final String? address;
  final String? createdAt;

  UserModel({
    this.id,
    required this.firebaseUid,
    required this.email,
    required this.role,
    required this.fullName,
    this.phone,
    this.address,
    this.createdAt,
  });

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle id as both int and string (JSON may return numbers as strings)
    int? parseId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed;
      }
      return null;
    }

    return UserModel(
      id: parseId(json['id']),
      firebaseUid: json['firebase_uid'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'email': email,
      'role': role,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'created_at': createdAt,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    int? id,
    String? firebaseUid,
    String? email,
    String? role,
    String? fullName,
    String? phone,
    String? address,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';

  // Role capabilities:
  // - Admin: Full admin dashboard access
  // - User: Can act as both buyer (browse, cart, checkout) and seller (manage products, view orders)
  bool get canBuy => role == 'user' || role == 'admin';
  bool get canSell => role == 'user' || role == 'admin';
}
