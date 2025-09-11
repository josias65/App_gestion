import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

/// Service de base de données local avec Hive
class DatabaseService {
  static DatabaseService? _instance;
  static Box? _clientsBox;
  static Box? _articlesBox;
  static Box? _commandesBox;
  static Box? _facturesBox;
  static Box? _devisBox;
  static Box? _settingsBox;
  static Box? _cacheBox;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
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
      _cacheBox = await Hive.openBox('cache');
      
      print('DatabaseService initialisé avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation de DatabaseService: $e');
      rethrow;
    }
  }

  // ========== CLIENTS ==========
  
  Future<List<Map<String, dynamic>>> getAllClients() async {
    try {
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

  Future<Map<String, dynamic>?> getClientById(String id) async {
    try {
      return _clientsBox!.get(id) as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération du client: $e');
      return null;
    }
  }

  Future<bool> saveClient(Map<String, dynamic> client) async {
    try {
      final id = client['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final clientData = {
        ...client,
        'id': id,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _clientsBox!.put(id, clientData);
      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde du client: $e');
      return false;
    }
  }

  Future<bool> deleteClient(String id) async {
    try {
      await _clientsBox!.delete(id);
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du client: $e');
      return false;
    }
  }

  // ========== ARTICLES ==========
  
  Future<List<Map<String, dynamic>>> getAllArticles() async {
    try {
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

  Future<Map<String, dynamic>?> getArticleById(String id) async {
    try {
      return _articlesBox!.get(id) as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération de l\'article: $e');
      return null;
    }
  }

  Future<bool> saveArticle(Map<String, dynamic> article) async {
    try {
      final id = article['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final articleData = {
        ...article,
        'id': id,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _articlesBox!.put(id, articleData);
      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'article: $e');
      return false;
    }
  }

  Future<bool> deleteArticle(String id) async {
    try {
      await _articlesBox!.delete(id);
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de l\'article: $e');
      return false;
    }
  }

  // ========== COMMANDES ==========
  
  Future<List<Map<String, dynamic>>> getAllCommandes() async {
    try {
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

  Future<Map<String, dynamic>?> getCommandeById(String id) async {
    try {
      return _commandesBox!.get(id) as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération de la commande: $e');
      return null;
    }
  }

  Future<bool> saveCommande(Map<String, dynamic> commande) async {
    try {
      final id = commande['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final commandeData = {
        ...commande,
        'id': id,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _commandesBox!.put(id, commandeData);
      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde de la commande: $e');
      return false;
    }
  }

  Future<bool> deleteCommande(String id) async {
    try {
      await _commandesBox!.delete(id);
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la commande: $e');
      return false;
    }
  }

  // ========== FACTURES ==========
  
  Future<List<Map<String, dynamic>>> getAllFactures() async {
    try {
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

  Future<Map<String, dynamic>?> getFactureById(String id) async {
    try {
      return _facturesBox!.get(id) as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération de la facture: $e');
      return null;
    }
  }

  Future<bool> saveFacture(Map<String, dynamic> facture) async {
    try {
      final id = facture['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final factureData = {
        ...facture,
        'id': id,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _facturesBox!.put(id, factureData);
      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde de la facture: $e');
      return false;
    }
  }

  Future<bool> deleteFacture(String id) async {
    try {
      await _facturesBox!.delete(id);
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la facture: $e');
      return false;
    }
  }

  // ========== DEVIS ==========
  
  Future<List<Map<String, dynamic>>> getAllDevis() async {
    try {
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

  Future<Map<String, dynamic>?> getDevisById(String id) async {
    try {
      return _devisBox!.get(id) as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération du devis: $e');
      return null;
    }
  }

  Future<bool> saveDevis(Map<String, dynamic> devis) async {
    try {
      final id = devis['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final devisData = {
        ...devis,
        'id': id,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _devisBox!.put(id, devisData);
      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde du devis: $e');
      return false;
    }
  }

  Future<bool> deleteDevis(String id) async {
    try {
      await _devisBox!.delete(id);
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du devis: $e');
      return false;
    }
  }

  // ========== STATISTIQUES ==========
  
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final clients = await getAllClients();
      final articles = await getAllArticles();
      final commandes = await getAllCommandes();
      final factures = await getAllFactures();
      final devis = await getAllDevis();

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
      final clients = await getAllClients();
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
      final articles = await getAllArticles();
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
  
  Future<void> syncWithAPI() async {
    try {
      final apiClient = ApiClient.instance;
      
      // Synchroniser les clients
      final clientsResponse = await apiClient.getClients();
      if (clientsResponse.isSuccess && clientsResponse.data != null) {
        for (var client in clientsResponse.data!) {
          await saveClient(client);
        }
      }
      
      // Synchroniser les articles
      final articlesResponse = await apiClient.getArticles();
      if (articlesResponse.isSuccess && articlesResponse.data != null) {
        for (var article in articlesResponse.data!) {
          await saveArticle(article);
        }
      }
      
      // Synchroniser les commandes
      final commandesResponse = await apiClient.getCommandes();
      if (commandesResponse.isSuccess && commandesResponse.data != null) {
        for (var commande in commandesResponse.data!) {
          await saveCommande(commande);
        }
      }
      
      // Synchroniser les factures
      final facturesResponse = await apiClient.getFactures();
      if (facturesResponse.isSuccess && facturesResponse.data != null) {
        for (var facture in facturesResponse.data!) {
          await saveFacture(facture);
        }
      }
      
      // Synchroniser les devis
      final devisResponse = await apiClient.getDevis();
      if (devisResponse.isSuccess && devisResponse.data != null) {
        for (var devis in devisResponse.data!) {
          await saveDevis(devis);
        }
      }
      
      // Marquer la dernière synchronisation
      await _settingsBox!.put('last_sync', DateTime.now().toIso8601String());
      
      print('Synchronisation terminée avec succès');
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    }
  }

  // ========== CACHE ==========
  
  Future<void> cacheData(String key, dynamic data, {Duration? expiry}) async {
    try {
      final cacheEntry = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': expiry?.inMilliseconds,
      };
      await _cacheBox!.put(key, cacheEntry);
    } catch (e) {
      print('Erreur lors de la mise en cache: $e');
    }
  }

  dynamic getCachedData(String key) {
    try {
      final cacheEntry = _cacheBox!.get(key);
      if (cacheEntry == null) return null;

      final timestamp = cacheEntry['timestamp'] as int;
      final expiry = cacheEntry['expiry'] as int?;
      
      if (expiry != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp > expiry) {
          _cacheBox!.delete(key);
          return null;
        }
      }
      
      return cacheEntry['data'];
    } catch (e) {
      print('Erreur lors de la récupération du cache: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      await _cacheBox!.clear();
    } catch (e) {
      print('Erreur lors du nettoyage du cache: $e');
    }
  }

  // ========== PARAMÈTRES ==========
  
  Future<void> setSetting(String key, dynamic value) async {
    try {
      await _settingsBox!.put(key, value);
    } catch (e) {
      print('Erreur lors de la sauvegarde du paramètre: $e');
    }
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    try {
      return _settingsBox!.get(key, defaultValue: defaultValue);
    } catch (e) {
      print('Erreur lors de la récupération du paramètre: $e');
      return defaultValue;
    }
  }

  Future<void> removeSetting(String key) async {
    try {
      await _settingsBox!.delete(key);
    } catch (e) {
      print('Erreur lors de la suppression du paramètre: $e');
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
      await _cacheBox!.clear();
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
      await _cacheBox?.close();
      print('Connexions fermées');
    } catch (e) {
      print('Erreur lors de la fermeture: $e');
    }
  }
}


