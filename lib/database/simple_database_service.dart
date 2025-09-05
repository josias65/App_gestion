import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class SimpleDatabaseService {
  static SimpleDatabaseService? _instance;
  static Box? _clientsBox;
  static Box? _articlesBox;
  static Box? _commandesBox;
  static Box? _facturesBox;
  static Box? _devisBox;
  static Box? _settingsBox;

  SimpleDatabaseService._();

  static SimpleDatabaseService get instance {
    _instance ??= SimpleDatabaseService._();
    return _instance!;
  }

  // Initialisation
  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      _clientsBox = await Hive.openBox('clients');
      _articlesBox = await Hive.openBox('articles');
      _commandesBox = await Hive.openBox('commandes');
      _facturesBox = await Hive.openBox('factures');
      _devisBox = await Hive.openBox('devis');
      _settingsBox = await Hive.openBox('settings');
      
      print('Base de données simple initialisée avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation: $e');
      rethrow;
    }
  }

  // ========== CLIENTS ==========
  
  Future<List<Map<String, dynamic>>> getClients({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await _syncClients();
      }
      
      final clients = <Map<String, dynamic>>[];
      for (var key in _clientsBox!.keys) {
        final client = _clientsBox!.get(key) as Map<String, dynamic>;
        clients.add(client);
      }
      return clients;
    } catch (e) {
      print('Erreur lors de la récupération des clients: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getClientById(String clientId) async {
    try {
      return _clientsBox!.get(clientId) as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération du client: $e');
      return null;
    }
  }

  Future<bool> createClient(Map<String, dynamic> clientData) async {
    try {
      final clientId = clientData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final client = {
        'id': clientId,
        'name': clientData['name'],
        'email': clientData['email'],
        'phone': clientData['phone'],
        'address': clientData['address'],
        'city': clientData['city'],
        'country': clientData['country'],
        'created_at': DateTime.now().toIso8601String(),
        'last_sync': DateTime.now().toIso8601String(),
      };
      
      await _clientsBox!.put(clientId, client);
      return true;
    } catch (e) {
      print('Erreur lors de la création du client: $e');
      return false;
    }
  }

  Future<bool> updateClient(String clientId, Map<String, dynamic> clientData) async {
    try {
      final existingClient = await getClientById(clientId);
      if (existingClient == null) return false;
      
      final updatedClient = {
        ...existingClient,
        ...clientData,
        'id': clientId,
        'last_sync': DateTime.now().toIso8601String(),
      };
      
      await _clientsBox!.put(clientId, updatedClient);
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du client: $e');
      return false;
    }
  }

  Future<bool> deleteClient(String clientId) async {
    try {
      await _clientsBox!.delete(clientId);
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du client: $e');
      return false;
    }
  }

  // ========== ARTICLES ==========
  
  Future<List<Map<String, dynamic>>> getArticles({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await _syncArticles();
      }
      
      final articles = <Map<String, dynamic>>[];
      for (var key in _articlesBox!.keys) {
        final article = _articlesBox!.get(key) as Map<String, dynamic>;
        articles.add(article);
      }
      return articles;
    } catch (e) {
      print('Erreur lors de la récupération des articles: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getArticleById(String articleId) async {
    try {
      return _articlesBox!.get(articleId) as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération de l\'article: $e');
      return null;
    }
  }

  Future<bool> createArticle(Map<String, dynamic> articleData) async {
    try {
      final articleId = articleData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final article = {
        'id': articleId,
        'name': articleData['name'],
        'description': articleData['description'],
        'price': articleData['price'],
        'quantity': articleData['quantity'],
        'unit': articleData['unit'],
        'category': articleData['category'],
        'created_at': DateTime.now().toIso8601String(),
        'last_sync': DateTime.now().toIso8601String(),
      };
      
      await _articlesBox!.put(articleId, article);
      return true;
    } catch (e) {
      print('Erreur lors de la création de l\'article: $e');
      return false;
    }
  }

  // ========== COMMANDES ==========
  
  Future<List<Map<String, dynamic>>> getCommandes({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await _syncCommandes();
      }
      
      final commandes = <Map<String, dynamic>>[];
      for (var key in _commandesBox!.keys) {
        final commande = _commandesBox!.get(key) as Map<String, dynamic>;
        commandes.add(commande);
      }
      return commandes;
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCommandeById(String commandeId) async {
    try {
      return _commandesBox!.get(commandeId) as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération de la commande: $e');
      return null;
    }
  }

  Future<bool> createCommande(Map<String, dynamic> commandeData) async {
    try {
      final commandeId = commandeData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final commande = {
        'id': commandeId,
        'client_id': commandeData['client_id'],
        'reference': commandeData['reference'],
        'date': commandeData['date'],
        'status': commandeData['status'],
        'total': commandeData['total'],
        'notes': commandeData['notes'],
        'created_at': DateTime.now().toIso8601String(),
        'last_sync': DateTime.now().toIso8601String(),
      };
      
      await _commandesBox!.put(commandeId, commande);
      return true;
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      return false;
    }
  }

  // ========== FACTURES ==========
  
  Future<List<Map<String, dynamic>>> getFactures({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await _syncFactures();
      }
      
      final factures = <Map<String, dynamic>>[];
      for (var key in _facturesBox!.keys) {
        final facture = _facturesBox!.get(key) as Map<String, dynamic>;
        factures.add(facture);
      }
      return factures;
    } catch (e) {
      print('Erreur lors de la récupération des factures: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getFactureById(String factureId) async {
    try {
      return _facturesBox!.get(factureId) as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération de la facture: $e');
      return null;
    }
  }

  // ========== DEVIS ==========
  
  Future<List<Map<String, dynamic>>> getDevis({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await _syncDevis();
      }
      
      final devis = <Map<String, dynamic>>[];
      for (var key in _devisBox!.keys) {
        final devi = _devisBox!.get(key) as Map<String, dynamic>;
        devis.add(devi);
      }
      return devis;
    } catch (e) {
      print('Erreur lors de la récupération des devis: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDevisById(String devisId) async {
    try {
      return _devisBox!.get(devisId) as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération du devis: $e');
      return null;
    }
  }

  // ========== STATISTIQUES ==========
  
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final clients = await getClients();
      final articles = await getArticles();
      final commandes = await getCommandes();
      final factures = await getFactures();
      final devis = await getDevis();

      double totalFactures = 0;
      double totalPaid = 0;
      for (var facture in factures) {
        totalFactures += (facture['total'] as num).toDouble();
        totalPaid += (facture['paid'] as num? ?? 0).toDouble();
      }

      return {
        'total_clients': clients.length,
        'total_articles': articles.length,
        'total_commandes': commandes.length,
        'total_factures': factures.length,
        'total_devis': devis.length,
        'total_revenue': totalFactures,
        'total_paid': totalPaid,
        'pending_amount': totalFactures - totalPaid,
        'last_sync': _settingsBox!.get('last_sync'),
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return {};
    }
  }

  // ========== RECHERCHE ==========
  
  Future<List<Map<String, dynamic>>> searchClients(String query) async {
    try {
      final clients = await getClients();
      return clients.where((client) => 
        client['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
        client['email'].toString().toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('Erreur lors de la recherche de clients: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchArticles(String query) async {
    try {
      final articles = await getArticles();
      return articles.where((article) => 
        article['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
        (article['description']?.toString().toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    } catch (e) {
      print('Erreur lors de la recherche d\'articles: $e');
      return [];
    }
  }

  // ========== SYNCHRONISATION ==========
  
  Future<void> syncAll() async {
    try {
      print('Début de la synchronisation...');
      await _syncClients();
      await _syncArticles();
      await _syncCommandes();
      await _syncFactures();
      await _syncDevis();
      
      await _settingsBox!.put('last_sync', DateTime.now().toIso8601String());
      print('Synchronisation terminée avec succès');
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    }
  }

  Future<void> _syncClients() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.clientsEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        
        for (var clientData in data) {
          final clientId = clientData['id'].toString();
          final existingClient = await getClientById(clientId);
          if (existingClient == null) {
            await createClient(clientData);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des clients: $e');
    }
  }

  Future<void> _syncArticles() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.articlesEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        
        for (var articleData in data) {
          final articleId = articleData['id'].toString();
          final existingArticle = await getArticleById(articleId);
          if (existingArticle == null) {
            await createArticle(articleData);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des articles: $e');
    }
  }

  Future<void> _syncCommandes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.commandesEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        
        for (var commandeData in data) {
          final commandeId = commandeData['id'].toString();
          final existingCommande = await getCommandeById(commandeId);
          if (existingCommande == null) {
            await createCommande(commandeData);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des commandes: $e');
    }
  }

  Future<void> _syncFactures() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.facturesEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        
        for (var factureData in data) {
          final factureId = factureData['id'].toString();
          final existingFacture = await getFactureById(factureId);
          if (existingFacture == null) {
            final facture = {
              'id': factureId,
              'client_id': factureData['client_id'],
              'reference': factureData['reference'],
              'date': factureData['date'],
              'status': factureData['status'],
              'total': factureData['total'],
              'paid': factureData['paid'] ?? 0.0,
              'notes': factureData['notes'],
              'created_at': factureData['created_at'],
              'last_sync': DateTime.now().toIso8601String(),
            };
            await _facturesBox!.put(factureId, facture);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des factures: $e');
    }
  }

  Future<void> _syncDevis() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.devisEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        
        for (var devisData in data) {
          final devisId = devisData['id'].toString();
          final existingDevis = await getDevisById(devisId);
          if (existingDevis == null) {
            final devi = {
              'id': devisId,
              'client_id': devisData['client_id'],
              'reference': devisData['reference'],
              'date': devisData['date'],
              'status': devisData['status'],
              'total': devisData['total'],
              'notes': devisData['notes'],
              'created_at': devisData['created_at'],
              'last_sync': DateTime.now().toIso8601String(),
            };
            await _devisBox!.put(devisId, devi);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des devis: $e');
    }
  }

  // ========== UTILITAIRES ==========
  
  Future<void> clearAllData() async {
    try {
      await _clientsBox!.clear();
      await _articlesBox!.clear();
      await _commandesBox!.clear();
      await _facturesBox!.clear();
      await _devisBox!.clear();
      print('Toutes les données ont été effacées');
    } catch (e) {
      print('Erreur lors de l\'effacement des données: $e');
    }
  }

  Future<void> close() async {
    try {
      await _clientsBox?.close();
      await _articlesBox?.close();
      await _commandesBox?.close();
      await _facturesBox?.close();
      await _devisBox?.close();
      await _settingsBox?.close();
      print('Connexions fermées');
    } catch (e) {
      print('Erreur lors de la fermeture: $e');
    }
  }
}



