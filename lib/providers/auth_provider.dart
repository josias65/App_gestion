import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

  AuthProvider() {
    _checkAuthStatus();
  }

  // Vérifier le statut d'authentification au démarrage
  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _authService.getUser();
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      
      if (result.success) {
        _user = result.user;
        _isAuthenticated = true;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result.error;
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Inscription
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(name, email, password);
      
      if (result.success) {
        _user = result.user;
        _isAuthenticated = true;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result.error;
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      notifyListeners();
      return false;
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
    } catch (e) {
      // Ignorer les erreurs lors de la déconnexion
    } finally {
      _user = null;
      _isAuthenticated = false;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Forcer la déconnexion
  Future<void> forceLogout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.forceLogout();
    } catch (e) {
      // Ignorer les erreurs
    } finally {
      _user = null;
      _isAuthenticated = false;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rafraîchir les données utilisateur
  Future<void> refreshUser() async {
    try {
      _user = await _authService.getUser();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
