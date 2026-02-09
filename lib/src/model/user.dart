class User {
  final String username;
  final String password;
  final String fullname;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String country;

  const User({
    required this.username,
    required this.password,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.country,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: (json['username'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      fullname: (json['fullname'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'country': country,
    };
  }
}
