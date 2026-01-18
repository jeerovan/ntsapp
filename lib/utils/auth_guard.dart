class AuthGuard {
  /// Global flag to prevent lifecycle loops during biometric prompts
  static bool isAuthenticating = false;
  static DateTime lastActiveAt = DateTime.now();
}
