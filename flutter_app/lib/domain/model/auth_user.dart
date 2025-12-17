class AuthUser {
  final int userId;
  final String phoneNumber;
  final String accessToken;
  final String refreshToken;

  const AuthUser({
    required this.userId,
    required this.phoneNumber,
    required this.accessToken,
    required this.refreshToken,
  });

  bool get isAuthenticated => accessToken.isNotEmpty;
  
  AuthUser copyWith({
    int? userId,
    String? phoneNumber,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthUser(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}






