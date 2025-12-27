class AuthUser {
  final int userId;
  final String phoneNumber;
  final String profileName;
  final String accessToken;
  final String refreshToken;

  const AuthUser({
    required this.userId,
    required this.phoneNumber,
    this.profileName = 'Player',
    required this.accessToken,
    required this.refreshToken,
  });

  bool get isAuthenticated => accessToken.isNotEmpty;
  
  AuthUser copyWith({
    int? userId,
    String? phoneNumber,
    String? profileName,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthUser(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileName: profileName ?? this.profileName,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}






