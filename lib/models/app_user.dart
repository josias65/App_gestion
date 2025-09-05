import 'package:hive/hive.dart';

part 'app_user.g.dart';

@HiveType(typeId: 0)
class AppUser extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String? avatarUrl;
  
  @HiveField(4)
  final String role;
  
  @HiveField(5)
  final String? authToken;
  
  @HiveField(6)
  final String? refreshToken;
  
  @HiveField(7)
  final DateTime? tokenExpiry;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.authToken,
    this.refreshToken,
    this.tokenExpiry,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar'] as String?,
      role: json['role'] as String? ?? 'user',
      authToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      tokenExpiry: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (avatarUrl != null) 'avatar': avatarUrl,
      'role': role,
      if (authToken != null) 'access_token': authToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (tokenExpiry != null) 'expires_at': tokenExpiry!.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? role,
    String? authToken,
    String? refreshToken,
    DateTime? tokenExpiry,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      authToken: authToken ?? this.authToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
    );
  }

  bool get isAuthenticated => authToken != null && authToken!.isNotEmpty;
  
  bool get isTokenExpired {
    if (tokenExpiry == null) return true;
    return DateTime.now().isAfter(tokenExpiry!);
  }
}
