import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ConnectivityService {
  static const String baseUrl = ApiConfig.devBaseUrl;
  
  /// Teste la connectivité au backend
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🔍 Test de connectivité au backend...');
      
      // Test de santé du serveur
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Backend accessible',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Backend inaccessible (${response.statusCode})',
          'data': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
        'data': null,
      };
    }
  }
  
  /// Teste l'authentification
  static Future<Map<String, dynamic>> testAuthentication() async {
    try {
      print('🔐 Test d\'authentification...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'test@example.com',
          'password': 'password123',
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Authentification réussie',
          'data': data,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': 'Échec de l\'authentification: ${errorData['message']}',
          'data': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur d\'authentification: $e',
        'data': null,
      };
    }
  }
  
  /// Teste tous les endpoints principaux
  static Future<Map<String, dynamic>> testAllEndpoints() async {
    try {
      print('📊 Test de tous les endpoints...');
      
      // D'abord, obtenir un token
      final authResult = await testAuthentication();
      if (!authResult['success']) {
        return authResult;
      }
      
      final token = authResult['data']['token'];
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      final endpoints = [
        {'name': 'Clients', 'url': '/customers'},
        {'name': 'Commandes', 'url': '/commande'},
        {'name': 'Articles', 'url': '/article'},
        {'name': 'Factures', 'url': '/facture'},
        {'name': 'Appels d\'offre', 'url': '/appels-offre'},
        {'name': 'Marchés', 'url': '/marches'},
      ];
      
      final results = <String, dynamic>{};
      
      for (final endpoint in endpoints) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl${endpoint['url']}'),
            headers: headers,
          ).timeout(const Duration(seconds: 5));
          
          results[endpoint['name']] = {
            'success': response.statusCode == 200,
            'statusCode': response.statusCode,
            'message': response.statusCode == 200 ? 'OK' : 'Erreur',
          };
        } catch (e) {
          results[endpoint['name']] = {
            'success': false,
            'statusCode': 0,
            'message': 'Erreur: $e',
          };
        }
      }
      
      return {
        'success': true,
        'message': 'Tests des endpoints terminés',
        'data': results,
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors des tests: $e',
        'data': null,
      };
    }
  }
  
  /// Vérifie si le backend est prêt
  static Future<bool> isBackendReady() async {
    final result = await testConnection();
    return result['success'];
  }
}
