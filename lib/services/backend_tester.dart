import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendTester {
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  static Future<void> testConnection() async {
    print('🧪 Test de connexion au backend...');
    
    try {
      // Test de santé du serveur
      final healthResponse = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (healthResponse.statusCode == 200) {
        print('✅ Serveur accessible');
        final healthData = jsonDecode(healthResponse.body);
        print('📊 Statut: ${healthData['status']}');
        print('🕒 Timestamp: ${healthData['timestamp']}');
        print('📦 Version: ${healthData['version']}');
      } else {
        print('❌ Serveur inaccessible (${healthResponse.statusCode})');
        return;
      }
      
      // Test de connexion
      print('\n🔐 Test de connexion...');
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'test@example.com',
          'password': 'password123',
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (loginResponse.statusCode == 200) {
        print('✅ Connexion réussie');
        final loginData = jsonDecode(loginResponse.body);
        print('👤 Utilisateur: ${loginData['user']['name']}');
        print('📧 Email: ${loginData['user']['email']}');
        print('🔑 Token reçu: ${loginData['token'] != null ? 'Oui' : 'Non'}');
        
        // Test d'une requête authentifiée
        if (loginData['token'] != null) {
          print('\n📋 Test de récupération des clients...');
          final clientsResponse = await http.get(
            Uri.parse('$baseUrl/customers'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${loginData['token']}',
            },
          ).timeout(const Duration(seconds: 10));
          
          if (clientsResponse.statusCode == 200) {
            print('✅ Récupération des clients réussie');
            final clientsData = jsonDecode(clientsResponse.body);
            print('📊 Nombre de clients: ${clientsData['data'].length}');
          } else {
            print('❌ Erreur lors de la récupération des clients (${clientsResponse.statusCode})');
          }
        }
      } else {
        print('❌ Échec de la connexion (${loginResponse.statusCode})');
        final errorData = jsonDecode(loginResponse.body);
        print('📝 Message: ${errorData['message']}');
      }
      
      print('\n🎉 Tests terminés !');
      
    } catch (e) {
      print('❌ Erreur lors du test: $e');
      print('\n💡 Vérifiez que:');
      print('   1. Le backend est démarré (npm start dans le dossier backend)');
      print('   2. Le serveur écoute sur le port 8000');
      print('   3. L\'émulateur Android peut accéder à 10.0.2.2:8000');
    }
  }
  
  static Future<void> testAllEndpoints() async {
    print('🧪 Test de tous les endpoints...');
    
    try {
      // Connexion pour obtenir le token
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'test@example.com',
          'password': 'password123',
        }),
      );
      
      if (loginResponse.statusCode != 200) {
        print('❌ Impossible de se connecter pour les tests');
        return;
      }
      
      final loginData = jsonDecode(loginResponse.body);
      final token = loginData['token'];
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      // Liste des endpoints à tester
      final endpoints = [
        {'name': 'Clients', 'url': '/customers'},
        {'name': 'Commandes', 'url': '/commande'},
        {'name': 'Articles', 'url': '/article'},
        {'name': 'Factures', 'url': '/facture'},
        {'name': 'Appels d\'offre', 'url': '/appels-offre'},
        {'name': 'Marchés', 'url': '/marches'},
      ];
      
      for (final endpoint in endpoints) {
        print('\n🔍 Test de ${endpoint['name']}...');
        
        try {
          final response = await http.get(
            Uri.parse('$baseUrl${endpoint['url']}'),
            headers: headers,
          ).timeout(const Duration(seconds: 5));
          
          if (response.statusCode == 200) {
            print('✅ ${endpoint['name']} accessible');
            final data = jsonDecode(response.body);
            if (data['data'] is List) {
              print('📊 Nombre d\'éléments: ${data['data'].length}');
            }
          } else {
            print('❌ ${endpoint['name']} inaccessible (${response.statusCode})');
          }
        } catch (e) {
          print('❌ Erreur pour ${endpoint['name']}: $e');
        }
      }
      
      print('\n🎉 Tests des endpoints terminés !');
      
    } catch (e) {
      print('❌ Erreur lors des tests: $e');
    }
  }
}
