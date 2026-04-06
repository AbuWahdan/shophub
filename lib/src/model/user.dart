class User {
  final int userId;
  final String username;
  final String passwordHash;
  final String fullname;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String country;
  final int? gender;
  final String createdAt;
  final String updatedAt;
  final int isActive;

  const User({
    required this.userId,
    required this.username,
    required this.passwordHash,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.country,
    this.gender,
    this.createdAt = '',
    this.updatedAt = '',
    this.isActive = 1,
  });

  String get fullName => fullname;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: _asInt(_pick(json, const ['user_id', 'USER_ID', 'userId'])),
      username: _asString(json, const ['username', 'USERNAME']),
      passwordHash: _asString(json, const [
        'password_hash',
        'PASSWORD_HASH',
        'password',
        'PASSWORD',
      ]),
      fullname: _asString(json, const ['fullname', 'FULL_NAME', 'full_name']),
      email: _asString(json, const ['email', 'EMAIL']),
      phone: _asString(json, const ['phone', 'PHONE']),
      address: _asString(json, const ['address', 'ADDRESS']),
      role: _asString(json, const ['role', 'ROLE']),
      country: _asString(json, const ['country', 'COUNTRY']),
      gender: _asNullableInt(_pick(json, const ['gender', 'GENDER'])),
      createdAt: _asString(json, const [
        'created_at',
        'CREATED_AT',
        'createdAt',
      ]),
      updatedAt: _asString(json, const [
        'updated_at',
        'UPDATED_AT',
        'updatedAt',
      ]),
      isActive: _asInt(
        _pick(json, const ['is_active', 'IS_ACTIVE', 'isActive']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'USER_ID': userId,
      'USERNAME': username,
      'PASSWORD_HASH': passwordHash,
      'FULL_NAME': fullname,
      'EMAIL': email,
      'PHONE': phone,
      'ADDRESS': address,
      'ROLE': role,
      'COUNTRY': country,
      if (gender != null) 'GENDER': gender,
      'CREATED_AT': createdAt,
      'UPDATED_AT': updatedAt,
      'IS_ACTIVE': isActive,
    };
  }

  User copyWith({
    int? userId,
    String? username,
    String? passwordHash,
    String? fullname,
    String? email,
    String? phone,
    String? address,
    String? role,
    String? country,
    int? gender,
    String? createdAt,
    String? updatedAt,
    int? isActive,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key];
    }
    return null;
  }

  static String _asString(Map<String, dynamic> json, List<String> keys) {
    final value = _pick(json, keys);
    return (value ?? '').toString();
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
