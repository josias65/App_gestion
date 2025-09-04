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
  AuthService._internal() {
    // Initialisation
    _init();
  }

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

  // Getters pour l'état actuel
  User? get currentUser => _currentUser;
  String? get token => _currentToken;
  bool get isLoggedIn => _currentToken != null && _currentUser != null;

  // Configuration de l'API
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration tokenExpiration = Duration(hours: 1);
  
  // Headers communs
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };
    
    if (_currentToken != null) {
      headers['Authorization'] = 'Bearer $_currentToken';
    }
    
    return headers;
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
      _setupTokenRefresh();
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
      _tokenRefreshTimer?.cancel();
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
      _tokenRefreshTimer = Timer.periodic(
        tokenExpiration - tokenRefreshThreshold,
        (timer) async {
          try {
            await _refreshAuthToken();
          } catch (e) {
            developer.log('Erreur lors du rafraîchissement automatique du token: $e',
                name: 'AuthService');
            // En cas d'échec, on force la déconnexion
            if (e is http.ClientException || e is TimeoutException) {
              await logout();
            }
          }
        },
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
        
        if (token != null && _currentUser != null) {
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
        success: false,
        message: 'Veuillez remplir tous les champs',
      );
    }

    _isLoadingController.add(true);
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: _headers,
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'device_name': '${AppConfig.appName} ${AppConfig.version}',
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => http.Response(
          jsonEncode({
            'success': false,
            'message': 'La connexion a pris trop de temps. Veuillez réessayer.',
          }),
          408,
        ),
      );

      if (AppConfig.enableLogging) {
        developer.log(
          'Connexion - Status: ${response.statusCode}, Body: ${response.body}',
          name: 'AuthService',
        );
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        final user = User.fromJson(data['user']);
        await _saveAuthData(
          data['token'],
          data['refresh_token'],
          user,
        );
        return AuthResult(
          success: true,
          message: 'Connexion réussie',
          user: user,
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Échec de la connexion',
        );
      }
    } catch (e) {
      developer.log('Erreur lors de la connexion: $e', name: 'AuthService');
      return AuthResult(
        success: false,
        message: 'Une erreur est survenue lors de la connexion',
      );
    } finally {
      _isLoadingController.add(false);
    }
  }

  // Inscription utilisateur
  Future<AuthResult> register(String name, String email, String password) async {
    _isLoadingController.add(true);
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$registerEndpoint'),
        headers: _headers,
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'password_confirmation': password,
        }),
      );

      if (AppConfig.enableLogging) {
        developer.log(
          'Inscription - Status: ${response.statusCode}, Body: ${response.body}',
          name: 'AuthService',
        );
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['token'] != null) {
        final user = User.fromJson(data['user']);
        await _saveAuthData(
          data['token'],
          data['refresh_token'],
          user,
        );
        return AuthResult(
          success: true,
          message: 'Inscription réussie',
          user: user,
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Échec de l\'inscription',
        );
      }
    } catch (e) {
      developer.log('Erreur lors de l\'inscription: $e', name: 'AuthService');
      return AuthResult(
        success: false,
        message: 'Une erreur est survenue lors de l\'inscription',
      );
    } finally {
      _isLoadingController.add(false);
    }
  }

  // Déconnexion utilisateur
  Future<void> logout() async {
    try {
      // Appeler l'API de déconnexion si l'utilisateur est connecté
      if (_currentToken != null) {
        await http.post(
          Uri.parse('$baseUrl$logoutEndpoint'),
          headers: _headers,
        );
      }
    } catch (e) {
      developer.log('Erreur lors de la déconnexion: $e', name: 'AuthService');
    } finally {
      // Toujours effacer les données locales
      await _clearAuthData();
    }
  }

  // Forcer la déconnexion (sans appeler l'API)
  Future<void> forceLogout() async {
    await _clearAuthData();
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> checkAuth() async {
    if (_currentUser != null && _currentToken != null) {
      return true;
    }
    await _loadAuthFromPrefs();
    return _currentUser != null && _currentToken != null;
  }

  // Obtenir le token d'authentification
  Future<String?> getToken() async {
    if (_currentToken == null) {
      await _loadAuthFromPrefs();
    }
    return _currentToken;
  }

  // Obtenir l'utilisateur actuel
  Future<User?> getUser() async {
    if (_currentUser == null) {
      await _loadAuthFromPrefs();
    }
    return _currentUser;
  }

  // Rafraîchir le token
  Future<bool> refreshToken() async {
    return await _refreshAuthToken();
  }

  // Nettoyage des ressources
  void dispose() {
    try {
      _tokenRefreshTimer?.cancel();
      _tokenRefreshTimer = null;
      
      if (!_authStateController.isClosed) {
        _authStateController.close();
      }
      
      if (!_isLoadingController.isClosed) {
        _isLoadingController.close();
      }
    } catch (e) {
      developer.log('Erreur lors de la libération des ressources: $e', 
          name: 'AuthService');
    }
  }
}

/// Classe pour gérer les résultats d'authentification
class AuthResult {
  final bool success;
  final String? message;
  final User? user;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
  });

  @override
  String toString() => 'AuthResult(success: $success, message: $message, user: $user)';
}
