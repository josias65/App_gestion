import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/services/auth_service.dart';
import 'lib/config/api_config.dart';

// Script de test pour vérifier l'API d'authentification
void main() async {
  print('🔍 Test de l\'API d\'authentification...\n');
  
  // Test 1: Vérifier la configuration
  await testConfiguration();
  
  // Test 2: Tester la connexion API mock
  await testMockApiConnection();
  
  // Test 3: Tester le service d'authentification
  await testAuthService();
  
  // Test 4: Tester le fallback
  await testFallbackMode();
}

// Test de la configuration
Future<void> testConfiguration() async {
  print('📋 Test 1: Configuration API');
  print('URL de base: ${ApiConfig.baseUrlForEnvironment}');
  print('Mode développement: ${ApiConfig.isDevelopment}');
  print('URL mock: ${ApiConfig.mockApiUrl}');
  print('✅ Configuration OK\n');
}

// Test de connexion à l'API mock
Future<void> testMockApiConnection() async {
  print('🌐 Test 2: Connexion API Mock');
  
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.mockApiUrl}/users'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    
    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ API Mock accessible');
      final data = jsonDecode(response.body);
      print('Données reçues: ${data.length} utilisateurs');
    } else {
      print('⚠️ API Mock répond mais avec erreur: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Erreur de connexion API Mock: $e');
  }
  print('');
}

// Test du service d'authentification
Future<void> testAuthService() async {
  print('🔐 Test 3: Service d\'authentification');
  
  final authService = AuthService();
  
  // Test avec des credentials quelconques
  print('Test de connexion avec email: test@demo.com');
  
  try {
    final result = await authService.login('test@demo.com', 'password123');
    
    if (result.success) {
      print('✅ Connexion réussie!');
      print('Utilisateur: ${result.user?['name']}');
      print('Email: ${result.user?['email']}');
      
      // Vérifier le token
      final token = await authService.getToken();
      print('Token généré: ${token?.substring(0, 20)}...');
      
      // Vérifier l'état de connexion
      final isLoggedIn = await authService.isLoggedIn();
      print('État connecté: $isLoggedIn');
      
    } else {
      print('❌ Échec de connexion: ${result.error}');
    }
  } catch (e) {
    print('❌ Erreur lors du test: $e');
  }
  print('');
}

// Test du mode fallback
Future<void> testFallbackMode() async {
  print('🔄 Test 4: Mode Fallback');
  
  final authService = AuthService();
  
  // Test avec les credentials de fallback
  print('Test avec credentials de fallback...');
  
  try {
    final result = await authService.login('test@example.com', 'password123');
    
    if (result.success) {
      print('✅ Mode fallback fonctionne');
      print('Utilisateur: ${result.user?['name']}');
    } else {
      print('❌ Mode fallback échoué: ${result.error}');
    }
  } catch (e) {
    print('❌ Erreur mode fallback: $e');
  }
  print('');
}
