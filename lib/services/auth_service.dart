import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

/// Service de gestion de l'authentification
/// Gère la connexion, l'inscription, la déconnexion et le rafraîchissement du token
class AuthService {
  // Configuration de l'API
  final String baseUrl = ApiConfig.devBaseUrl; // Utilise l'URL de développement par défaut
  final String loginEndpoint = ApiConfig.loginEndpoint;
  final String registerEndpoint = ApiConfig.registerEndpoint;
  final String refreshEndpoint = ApiConfig.refreshEndpoint;
  final String logoutEndpoint = ApiConfig.logoutEndpoint;

  // Clés pour le stockage local
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  
  // Contrôleurs pour les streams
  final _authStateController = StreamController<User?>.broadcast();
  final _isLoadingController = StreamController<bool>.broadcast();

  // Getters pour les streams
  Stream<User?> get authStateChanges => _authStateController.stream;
  Stream<bool> get isLoading => _isLoadingController.stream;

  // État actuel
  User? _currentUser;
  String? _currentToken;
  String? _refreshToken;
  Timer? _tokenRefreshTimer;

  // Configuration
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration tokenExpiration = Duration(hours: 1);
  
  // Headers pour les requêtes API
  Map<String, String> get _headers => {
        ...ApiConfig.defaultHeaders,
      };

  // Headers pour les requêtes authentifiées
  Future<Map<String, String>> get _authHeaders async {
    final token = await getToken();
    return {
      ..._headers,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Constructeur
  AuthService() {
    _init();
  }
  
  // Initialisation
  Future<void> _init() async {
    await _loadAuthFromPrefs();
    _setupTokenRefresh();
  }

  // Charger l'état d'authentification depuis les préférences
  Future<void> _loadAuthFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);
      final refreshToken = prefs.getString(refreshTokenKey);
      final userJson = prefs.getString(userKey);

      if (token != null && userJson != null) {
        _currentToken = token;
        _refreshToken = refreshToken;
        _currentUser = User.fromJson(jsonDecode(userJson));
        _authStateController.add(_currentUser);
      }
    } catch (e) {
      developer.log('Erreur lors du chargement de l\'authentification: $e',
          name: 'AuthService');
      await _clearAuthData();
    }
  }

  // Sauvegarder l'état d'authentification dans les préférences
  Future<void> _saveAuthData(
      String token, String? refreshToken, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
      if (refreshToken != null) {
        await prefs.setString(refreshTokenKey, refreshToken);
      }
      await prefs.setString(userKey, jsonEncode(user.toJson()));

      _currentToken = token;
      _refreshToken = refreshToken;
      _currentUser = user;
      _authStateController.add(user);
    } catch (e) {
      developer.log('Erreur lors de la sauvegarde de l\'authentification: $e',
          name: 'AuthService');
      rethrow;
    }
  }

  // Effacer les données d'authentification
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(refreshTokenKey);
      await prefs.remove(userKey);

      _currentToken = null;
      _refreshToken = null;
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      developer.log(
          'Erreur lors de la suppression des données d\'authentification: $e',
          name: 'AuthService');
      rethrow;
    }
  }

  // Configurer le rafraîchissement automatique du token
  void _setupTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    if (_currentToken != null) {
      // Rafraîchir le token 5 minutes avant son expiration
      // Note: Vous devrez ajuster cette logique en fonction de votre implémentation de token
      _tokenRefreshTimer = Timer.periodic(
        const Duration(minutes: 25),
        (timer) => _refreshAuthToken(),
      );
    }
  }

  // Rafraîchir le token d'authentification
  Future<bool> _refreshAuthToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$refreshEndpoint'),
        headers: _headers,
        body: jsonEncode({'refresh_token': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final refreshToken = data['refresh_token'] ?? _refreshToken;
        
        if (token != null) {
          await _saveAuthData(token, refreshToken, _currentUser!);
          return true;
        }
      }
    } catch (e) {
      developer.log('Erreur lors du rafraîchissement du token: $e',
          name: 'AuthService');
    }
    
    // En cas d'échec, déconnecter l'utilisateur
    await logout();
    return false;
  }

  // Connexion utilisateur
  Future<AuthResult> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return const AuthResult(
          success: false, message: 'Veuillez remplir tous les champs');
    }

    _isLoadingController.add(true);

    try {
      if (AppConfig.useMockData) {
        return _testLogin(email, password);
      }

      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData['token'] == null) {
          return const AuthResult(
              success: false, 
              message: 'Token manquant dans la réponse du serveur');
        }

        final token = responseData['token'] as String;
        final refreshToken = responseData['refresh_token'] as String?;
        final userData = responseData['user'] as Map<String, dynamic>?;
        
        if (userData == null) {
          return const AuthResult(
              success: false,
              message: 'Données utilisateur manquantes dans la réponse');
        }
        
        // Sauvegarder les tokens et les données utilisateur
        await _saveTokens(token, refreshToken ?? '');
        await _saveUser(userData);
        
        // Mettre à jour l'état de l'utilisateur
        _currentUser = User.fromJson(userData);
        _currentToken = token;
        _refreshToken = refreshToken;
        _authStateController.add(_currentUser);
        
        // Démarrer le timer de rafraîchissement du token
        _startTokenRefreshTimer();
        
        return AuthResult(
          success: true,
          message: 'Connexion réussie',
          user: _currentUser,
          token: token,
        );
      } else {
        // Gestion des erreurs HTTP
        final errorMessage = responseData['message'] ?? 'Erreur de connexion';
        return AuthResult(
          success: false,
          message: 'Échec de la connexion: $errorMessage',
        );
      }
    } on TimeoutException {
      return const AuthResult(
        success: false,
        message: 'La connexion a expiré. Veuillez réessayer.',
      );
    } catch (e) {
      developer.log('Erreur lors de la connexion: $e', 
          name: 'AuthService',
          error: e,
          stackTrace: StackTrace.current);
      
      // En cas d'erreur réseau, essayer le mode test si activé
      if (AppConfig.useMockData) {
        return _testLogin(email, password);
      }
      
      return AuthResult(
        success: false,
        message: 'Une erreur est survenue. Veuillez réessayer plus tard.',
      );
    } finally {
      _isLoadingController.add(false);
    }
  }

  // Mode test pour développement
  Future<AuthResult> _testLogin(String email, String password) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 1));

    // Test avec des credentials spécifiques
    if (email == 'test@example.com' && password == 'password123') {
      final testUser = {
        'id': '1',
        'name': 'Utilisateur Test',
        'email': email,
        'avatar': null,
        'created_at': DateTime.now().toIso8601String(),
        'role': 'user',
      };

      await _saveTokens('test_access_token', 'test_refresh_token');
      await _saveUser(testUser);

      return AuthResult.success(User.fromJson(testUser), 'test_access_token');
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

      return AuthResult.success(User.fromJson(adminUser), 'admin_access_token');
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

        return AuthResult.success(
          User.fromJson(data['user']),
          data['access_token'] ?? data['token'],
        );
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
      _stopTokenRefreshTimer();
      await _clearTokens();
    }
  }

  // Forcer la déconnexion (nettoyer toutes les données)
  Future<void> forceLogout() async {
    _stopTokenRefreshTimer();
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

  // Démarrer le timer de rafraîchissement du token
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(
      const Duration(minutes: 50), // Rafraîchir le token avant qu'il n'expire
      (timer) async {
        if (_refreshToken != null) {
          try {
            await refreshToken();
          } catch (e) {
            developer.log('Erreur lors du rafraîchissement automatique du token: $e',
                name: 'AuthService');
          }
        }
      },
    );
  }

  // Arrêter le timer de rafraîchissement du token
  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
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
  final String? message;
  final User? user;
  final String? token;

  const AuthResult({required this.success, this.message, this.user, this.token});

  // Constructeur pour un succès
  factory AuthResult.success(User user, String token) {
    return AuthResult(success: true, user: user, token: token);
  }

  // Constructeur pour une erreur
  factory AuthResult.error(String message) {
    return AuthResult(success: false, message: message);
  }

  // Getter pour l'erreur
  String? get error => success ? null : message;
}
