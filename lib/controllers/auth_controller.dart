// import 'package:get/get.dart';
// import 'package:flutter/foundation.dart';
//
// /// Auth controller for managing authentication-related operations
// /// This controller works alongside the existing AuthState Provider
// /// and provides a GetX-based interface for auth data and operations
// class AuthController extends GetxController {
//   // Username and user ID
//   final username = ''.obs;
//   final userId = 0.obs;
//   final isLoggedIn = false.obs;
//
//   /// Initialize auth controller from existing auth state
//   /// Called from the AuthState provider when credentials change
//   void setUser({
//     required String username,
//     required int userId,
//     required bool isLoggedIn,
//   }) {
//     this.username.value = username.trim();
//     this.userId.value = userId;
//     this.isLoggedIn.value = isLoggedIn;
//
//     if (kDebugMode) {
//       debugPrint('[AuthController] User updated: username=$username, userId=$userId, loggedIn=$isLoggedIn');
//     }
//   }
//
//   /// Clear auth data (on logout)
//   void clearAuth() {
//     username.value = '';
//     userId.value = 0;
//     isLoggedIn.value = false;
//
//     if (kDebugMode) {
//       debugPrint('[AuthController] Auth cleared');
//     }
//   }
//
//   /// Check if user is authenticated
//   bool get isAuthenticated => isLoggedIn.value && username.value.isNotEmpty;
//
//   /// Get current username or empty string if not logged in
//   String getCurrentUsername() => username.value;
//
//   /// Get current user ID or 0 if not logged in
//   int getCurrentUserId() => userId.value;
// }
