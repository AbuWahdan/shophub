class ForgetPasswordRequest {
  final String username;
  final String newPassword;
  final String? oldPassword;

  const ForgetPasswordRequest({
    required this.username,
    required this.newPassword,
    this.oldPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'new_password': newPassword,
      if (oldPassword != null) 'old_password': oldPassword,
    };
  }
}
