import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Service API mock pour les tests et le développement
class MockApiService {
  static const String baseUrl = 'https://66f7c5c8b5d85f31a3418d8e.mockapi.io/api/v1';
  
  // Données mock pour les tests
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'email': 'admin@neo.com',
      'name': 'Administrateur',
      'role': 'admin',
      'avatar': null,
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': '2',
      'email': 'test@example.com',
      'name': 'Utilisateur Test',
      'role': 'user',
      'avatar': null,
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> _mockClients = [
    {
      'id': '1',
      'name': 'Jean Dupont',
      'email': 'jean.dupont@email.com',
      'phone': '+33 1 23 45 67 89',
      'address': '123 Rue de la Paix',
      'city': 'Paris',
      'country': 'France',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': '2',
      'name': 'Marie Martin',
      'email': 'marie.martin@email.com',
      'phone': '+33 1 98 76 54 32',
      'address': '456 Avenue des Champs',
      'city': 'Lyon',
      'country': 'France',
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> _mockArticles = [
    {
      'id': '1',
      'name': 'Ordinateur Portable',
      'description': 'Laptop haute performance',
      'price': 999.99,
      'quantity': 10,
      'unit': 'pièce',
      'category': 'Informatique',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': '2',
      'name': 'Smartphone',
      'description': 'Téléphone intelligent',
      'price': 599.99,
      'quantity': 25,
      'unit': 'pièce',
      'category': 'Mobile',
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> _mockCommandes = [
    {
      'id': '1',
      'client_id': '1',
      'reference': 'CMD-001',
      'date': DateTime.now().toIso8601String(),
      'status': 'En attente',
      'total': 1599.98,
      'notes': 'Commande urgente',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': '2',
      'client_id': '2',
      'reference': 'CMD-002',
      'date': DateTime.now().toIso8601String(),
      'status': 'Livrée',
      'total': 899.99,
      'notes': 'Livraison express',
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> _mockFactures = [
    {
      'id': '1',
      'client_id': '1',
      'reference': 'FAC-001',
      'date': DateTime.now().toIso8601String(),
      'status': 'Payée',
      'total': 1599.98,
      'paid': 1599.98,
      'notes': 'Paiement par virement',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': '2',
      'client_id': '2',
      'reference': 'FAC-002',
      'date': DateTime.now().toIso8601String(),
      'status': 'En attente',
      'total': 899.99,
      'paid': 0.0,
      'notes': 'Paiement à réception',
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> _mockDevis = [
    {
      'id': '1',
      'client_id': '1',
      'reference': 'DEV-001',
      'date': DateTime.now().toIso8601String(),
      'status': 'Accepté',
      'total': 1599.98,
      'notes': 'Devis accepté par le client',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': '2',
      'client_id': '2',
      'reference': 'DEV-002',
      'date': DateTime.now().toIso8601String(),
      'status': 'En attente',
      'total': 899.99,
      'notes': 'En attente de validation',
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  // Simuler un délai réseau
  static Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: Random().nextInt(500) + 200));
  }

  // Générer un token mock
  static String _generateMockToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'mock_token_${timestamp}_${Random().nextInt(1000)}';
  }

  // Authentification
  static Future<http.Response> login(String email, String password) async {
    await _simulateNetworkDelay();
    
    final user = _mockUsers.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );

    if (user.isNotEmpty && password == 'password123') {
      final token = _generateMockToken();
      final response = {
        'success': true,
        'message': 'Connexion réussie',
        'data': {
          'user': user,
          'tokens': {
            'access': token,
            'refresh': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          },
        },
      };
      
      return http.Response(jsonEncode(response), 200);
    } else {
      final response = {
        'success': false,
        'message': 'Email ou mot de passe incorrect',
      };
      
      return http.Response(jsonEncode(response), 401);
    }
  }

  // Obtenir tous les clients
  static Future<http.Response> getClients() async {
    await _simulateNetworkDelay();
    
    final response = {
      'success': true,
      'data': _mockClients,
      'total': _mockClients.length,
    };
    
    return http.Response(jsonEncode(response), 200);
  }

  // Créer un client
  static Future<http.Response> createClient(Map<String, dynamic> clientData) async {
    await _simulateNetworkDelay();
    
    final newClient = {
      'id': (_mockClients.length + 1).toString(),
      ...clientData,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    _mockClients.add(newClient);
    
    final response = {
        'success': true,
      'message': 'Client créé avec succès',
      'data': newClient,
    };
    
    return http.Response(jsonEncode(response), 201);
  }

  // Obtenir tous les articles
  static Future<http.Response> getArticles() async {
    await _simulateNetworkDelay();
    
    final response = {
      'success': true,
      'data': _mockArticles,
      'total': _mockArticles.length,
    };
    
    return http.Response(jsonEncode(response), 200);
  }

  // Créer un article
  static Future<http.Response> createArticle(Map<String, dynamic> articleData) async {
    await _simulateNetworkDelay();
    
    final newArticle = {
      'id': (_mockArticles.length + 1).toString(),
      ...articleData,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    _mockArticles.add(newArticle);
    
    final response = {
        'success': true,
      'message': 'Article créé avec succès',
      'data': newArticle,
    };
    
    return http.Response(jsonEncode(response), 201);
  }

  // Obtenir toutes les commandes
  static Future<http.Response> getCommandes() async {
    await _simulateNetworkDelay();
    
    final response = {
      'success': true,
      'data': _mockCommandes,
      'total': _mockCommandes.length,
    };
    
    return http.Response(jsonEncode(response), 200);
  }

  // Créer une commande
  static Future<http.Response> createCommande(Map<String, dynamic> commandeData) async {
    await _simulateNetworkDelay();
    
    final newCommande = {
      'id': (_mockCommandes.length + 1).toString(),
      ...commandeData,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    _mockCommandes.add(newCommande);
    
    final response = {
      'success': true,
      'message': 'Commande créée avec succès',
      'data': newCommande,
    };
    
    return http.Response(jsonEncode(response), 201);
  }

  // Obtenir toutes les factures
  static Future<http.Response> getFactures() async {
    await _simulateNetworkDelay();
    
    final response = {
      'success': true,
      'data': _mockFactures,
      'total': _mockFactures.length,
    };
    
    return http.Response(jsonEncode(response), 200);
  }

  // Créer une facture
  static Future<http.Response> createFacture(Map<String, dynamic> factureData) async {
    await _simulateNetworkDelay();
    
    final newFacture = {
      'id': (_mockFactures.length + 1).toString(),
      ...factureData,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    _mockFactures.add(newFacture);
    
    final response = {
      'success': true,
      'message': 'Facture créée avec succès',
      'data': newFacture,
    };
    
    return http.Response(jsonEncode(response), 201);
  }

  // Obtenir tous les devis
  static Future<http.Response> getDevis() async {
    await _simulateNetworkDelay();
    
    final response = {
      'success': true,
      'data': _mockDevis,
      'total': _mockDevis.length,
    };
    
    return http.Response(jsonEncode(response), 200);
  }

  // Créer un devis
  static Future<http.Response> createDevis(Map<String, dynamic> devisData) async {
    await _simulateNetworkDelay();
    
    final newDevis = {
      'id': (_mockDevis.length + 1).toString(),
      ...devisData,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    _mockDevis.add(newDevis);
    
    final response = {
      'success': true,
      'message': 'Devis créé avec succès',
      'data': newDevis,
    };
    
    return http.Response(jsonEncode(response), 201);
  }

  // Obtenir les statistiques du dashboard
  static Future<http.Response> getDashboardStats() async {
    await _simulateNetworkDelay();
    
    final totalFactures = _mockFactures.fold<double>(0, (sum, facture) => sum + (facture['total'] as num).toDouble());
    final totalPaid = _mockFactures.fold<double>(0, (sum, facture) => sum + (facture['paid'] as num).toDouble());
    
    final stats = {
      'total_clients': _mockClients.length,
      'total_articles': _mockArticles.length,
      'total_commandes': _mockCommandes.length,
      'total_factures': _mockFactures.length,
      'total_devis': _mockDevis.length,
      'total_revenue': totalFactures,
      'total_paid': totalPaid,
      'pending_amount': totalFactures - totalPaid,
      'sales_today': 2500.0,
      'orders_today': 15,
      'new_clients_week': 3,
      'low_stock_items': 12,
    };
    
    final response = {
      'success': true,
      'data': stats,
    };
    
    return http.Response(jsonEncode(response), 200);
  }

  // Simuler une erreur réseau
  static Future<http.Response> simulateNetworkError() async {
    await _simulateNetworkDelay();
    
    final response = {
      'success': false,
      'message': 'Erreur de connexion réseau',
      'error': 'NETWORK_ERROR',
    };
    
    return http.Response(jsonEncode(response), 500);
  }

  // Vérifier la connectivité
  static Future<http.Response> checkConnectivity() async {
    await _simulateNetworkDelay();
    
    final response = {
      'success': true,
      'message': 'Connexion établie',
      'data': {
        'status': 'online',
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
    
    return http.Response(jsonEncode(response), 200);
  }
}