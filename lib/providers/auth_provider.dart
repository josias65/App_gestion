import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service_new.dart';

/// Fournisseur d'état pour la gestion de l'authentification
/// Gère l'état de l'authentification et expose des méthodes pour interagir avec le service d'authentification

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isInitialized = false;
  User? _user;
  String _error = '';
  StreamSubscription<User?>? _authSubscription;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  User? get user => _user;
  String? get error => _error;

  AuthProvider() {
    _init();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _authService.dispose();
    super.dispose();
  }

  // Initialisation du fournisseur
  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Écouter les changements d'état d'authentification
      _authSubscription = _authService.authStateChanges.listen((user) {
        _user = user;
        _isInitialized = true;
        notifyListeners();
      });

      // Vérifier l'état d'authentification actuel
      await _checkAuthStatus();
    } catch (e) {
      _error = 'Erreur lors de l\'initialisation: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vérifier le statut d'authentification
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.checkAuth();
      if (!isLoggedIn) {
        _user = null;
      }
    } catch (e) {
      _error = 'Erreur lors de la vérification de l\'authentification: $e';
      rethrow;
    }
  }

  // Connexion
  Future<AuthResult> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      
      if (result.success) {
        _error = '';
        return result;
      } else {
        final errorMessage = result.message;
        _error = errorMessage ?? 'Échec de la connexion';
        return AuthResult(
          success: false,
          message: _error,
        );
      }
    } catch (e) {
      _error = 'Erreur lors de la connexion: $e';
      return AuthResult(
        success: false,
        message: _error,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Inscription
  Future<AuthResult> register(String name, String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.register(name, email, password);
      
      if (result.success) {
        _error = '';
        return result;
      } else {
        _error = result.message ?? 'Erreur inconnue lors de l\'inscription';
        return AuthResult(
          success: false,
          message: _error,
        );
      }
    } catch (e) {
      _error = 'Erreur lors de l\'inscription: $e';
      return AuthResult(
        success: false,
        message: _error,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
      _error = '';
    } catch (e) {
      _error = 'Erreur lors de la déconnexion: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Forcer la déconnexion (sans appeler l'API)
  Future<void> forceLogout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.forceLogout();
      _error = '';
    } catch (e) {
      _error = 'Erreur lors de la déconnexion forcée: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rafraîchir le token d'authentification
  Future<bool> refreshToken() async {
    try {
      return await _authService.refreshToken();
    } catch (e) {
      _error = 'Erreur lors du rafraîchissement du token: $e';
      return false;
    }
  }

  // Rafraîchir les données utilisateur
  Future<void> refreshUser() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      _user = await _authService.getUser();
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du rafraîchissement des données utilisateur: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Effacer l'erreur
  void clearError() {
    if (_error.isNotEmpty) {
      _error = '';
      notifyListeners();
    }
  }
  
  // Vérifier si l'utilisateur a un rôle spécifique
  bool hasRole(String role) {
    final userRole = _user?.role;
    if (userRole == null || userRole.isEmpty) return false;
    return userRole.toLowerCase() == role.toLowerCase();
  }
  
  // Vérifier si l'utilisateur a l'un des rôles spécifiés
  bool hasAnyRole(List<String> roles) {
    final userRole = _user?.role;
    if (userRole == null || userRole.isEmpty) return false;
    return roles.any((role) => userRole.toLowerCase() == role.toLowerCase());
  }
}
