import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static String get baseUrl => ApiConfig.baseUrlForEnvironment;
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  // Clés pour SharedPreferences
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Headers communs
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers avec token d'authentification
  Future<Map<String, String>> get _authHeaders async {
    final token = await getToken();
    return {..._headers, if (token != null) 'Authorization': 'Bearer $token'};
  }

  // Connexion utilisateur
  Future<AuthResult> login(String email, String password) async {
    try {
      // Utiliser l'API mock configurée
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': 'Utilisateur Mock',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simuler une réponse d'authentification réussie
        final mockUser = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'name': 'Utilisateur Mock',
          'email': email,
          'avatar': null,
          'created_at': DateTime.now().toIso8601String(),
          'role': 'user',
        };

        final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        await _saveTokens(mockToken, 'mock_refresh_token');
        await _saveUser(mockUser);

        return AuthResult.success(mockUser);
      } else {
        return AuthResult.error('Erreur de connexion à l\'API');
      }
    } catch (e) {
      // Fallback vers le mode test si l'API mock échoue
      return _testLogin(email, password);
    }
  }

  // Mode test pour développement
  Future<AuthResult> _testLogin(String email, String password) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 1));

    // Test avec des credentials spécifiques
    if (email == 'test@example.com' && password == 'password123') {
      final testUser = {
        'id': 1,
        'name': 'Utilisateur Test',
        'email': email,
        'avatar': null,
        'created_at': DateTime.now().toIso8601String(),
        'role': 'user',
      };

      await _saveTokens('test_access_token', 'test_refresh_token');
      await _saveUser(testUser);

      return AuthResult.success(testUser);
    } else if (email == 'admin@neo.com' && password == 'admin123') {
      final adminUser = {
        'id': 2,
        'name': 'Administrateur',
        'email': email,
        'avatar': null,
        'created_at': DateTime.now().toIso8601String(),
        'role': 'admin',
      };

      await _saveTokens('admin_access_token', 'admin_refresh_token');
      await _saveUser(adminUser);

      return AuthResult.success(adminUser);
    } else {
      return AuthResult.error('Email ou mot de passe incorrect');
    }
  }

  // Inscription utilisateur
  Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$registerEndpoint'),
        headers: _headers,
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['access_token'], data['refresh_token']);
        await _saveUser(data['user']);

        return AuthResult.success(data['user']);
      } else {
        final error = jsonDecode(response.body);
        return AuthResult.error(error['message'] ?? 'Erreur d\'inscription');
      }
    } catch (e) {
      return AuthResult.error('Erreur d\'inscription: ${e.toString()}');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      final headers = await _authHeaders;
      await http.post(Uri.parse('$baseUrl$logoutEndpoint'), headers: headers);
    } catch (e) {
      // Ignorer les erreurs lors de la déconnexion
    } finally {
      await _clearTokens();
    }
  }

  // Forcer la déconnexion (nettoyer toutes les données)
  Future<void> forceLogout() async {
    await _clearTokens();
  }

  // Rafraîchir le token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl$refreshEndpoint'),
        headers: _headers,
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['access_token'], data['refresh_token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Obtenir les informations de l'utilisateur
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Obtenir le token d'accès
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Obtenir le token de rafraîchissement
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  // Sauvegarder les tokens
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, accessToken);
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  // Sauvegarder les données utilisateur
  Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(user));
  }

  // Supprimer les tokens
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(refreshTokenKey);
    await prefs.remove(userKey);
  }

  // Faire une requête authentifiée avec gestion automatique du refresh
  Future<http.Response> authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _authHeaders;
    final uri = Uri.parse('$baseUrl$endpoint');

    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Méthode HTTP non supportée');
    }

    // Si le token a expiré, essayer de le rafraîchir
    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        // Réessayer la requête avec le nouveau token
        final newHeaders = await _authHeaders;
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: newHeaders);
            break;
          case 'POST':
            response = await http.post(
              uri,
              headers: newHeaders,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'PUT':
            response = await http.put(
              uri,
              headers: newHeaders,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: newHeaders);
            break;
        }
      }
    }

    return response;
  }
}

// Classe pour gérer les résultats d'authentification
class AuthResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? user;

  AuthResult.success(this.user) : success = true, error = null;

  AuthResult.error(this.error) : success = false, user = null;
}

// Modèle utilisateur
class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
