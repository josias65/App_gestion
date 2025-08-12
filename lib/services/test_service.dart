import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TestService {
  static final TestService _instance = TestService._internal();
  factory TestService() => _instance;
  TestService._internal();

  // Test de connectivité basique
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrlForEnvironment}/health'))
          .timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur de connexion: $e');
      return false;
    }
  }

  // Test avec JSONPlaceholder (API publique de test)
  Future<bool> testWithJsonPlaceholder() async {
    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Test JSONPlaceholder réussi: ${data['title']}');
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur JSONPlaceholder: $e');
      return false;
    }
  }

  // Test d'authentification simulée
  Future<Map<String, dynamic>> testAuthSimulation() async {
    try {
      // Simulation d'une réponse d'API d'authentification
      await Future.delayed(const Duration(seconds: 2)); // Simuler le délai réseau
      
      return {
        'success': true,
        'message': 'Test d\'authentification réussi',
        'data': {
          'access_token': 'test_token_123',
          'refresh_token': 'test_refresh_token_123',
          'user': {
            'id': 1,
            'name': 'Utilisateur Test',
            'email': 'test@example.com',
            'avatar': null,
            'created_at': DateTime.now().toIso8601String(),
            'role': 'user'
          }
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de test: $e',
        'data': null
      };
    }
  }

  // Test de votre API spécifique
  Future<Map<String, dynamic>> testYourApi() async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.loginEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': 'test@example.com',
              'password': 'password123',
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
        'message': response.statusCode == 200 
            ? 'API fonctionne correctement' 
            : 'Erreur API: ${data['message'] ?? 'Erreur inconnue'}'
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': null,
        'data': null,
        'message': 'Erreur de connexion: $e'
      };
    }
  }

  // Test complet du système
  Future<Map<String, dynamic>> runFullTest() async {
    final results = <String, dynamic>{};
    
    print('🧪 Début des tests...');
    
    // Test 1: Connectivité basique
    print('1. Test de connectivité...');
    results['connectivity'] = await testConnection();
    
    // Test 2: JSONPlaceholder
    print('2. Test JSONPlaceholder...');
    results['jsonPlaceholder'] = await testWithJsonPlaceholder();
    
    // Test 3: Authentification simulée
    print('3. Test d\'authentification simulée...');
    results['authSimulation'] = await testAuthSimulation();
    
    // Test 4: Votre API
    print('4. Test de votre API...');
    results['yourApi'] = await testYourApi();
    
    // Résumé
    final successCount = results.values.where((v) => 
        v is bool ? v : (v is Map && v['success'] == true)
    ).length;
    
    results['summary'] = {
      'totalTests': 4,
      'successCount': successCount,
      'successRate': (successCount / 4 * 100).toStringAsFixed(1) + '%'
    };
    
    print('✅ Tests terminés: $successCount/4 réussis');
    
    return results;
  }
}
