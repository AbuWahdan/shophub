class ForgetPasswordRequestModel {
  final String username;
  final String newPassword;
  final String? oldPassword;

  const ForgetPasswordRequestModel({
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
