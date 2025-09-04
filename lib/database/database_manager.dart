import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import '../config/api_config.dart';
// import '../models/models.dart'; // Commenté temporairement

class DatabaseManager {
  static DatabaseManager? _instance;
  static AppDatabase? _database;
  static Box? _settingsBox;
  static Box? _cacheBox;
  static Box? _offlineBox;

  DatabaseManager._();

  static DatabaseManager get instance {
    _instance ??= DatabaseManager._();
    return _instance!;
  }

  // Initialisation de la base de données
  static Future<void> initialize() async {
    try {
      // Initialiser Drift (SQLite)
      _database = AppDatabase();
      
      // Initialiser Hive pour le cache et les paramètres
      await Hive.initFlutter();
      
      _settingsBox = await Hive.openBox('app_settings');
      _cacheBox = await Hive.openBox('app_cache');
      _offlineBox = await Hive.openBox('offline_data');
      
      print('Base de données initialisée avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation de la base de données: $e');
      rethrow;
    }
  }

  // Getters pour accéder aux instances
  static AppDatabase get database {
    if (_database == null) {
      throw Exception('Base de données non initialisée. Appelez DatabaseManager.initialize() d\'abord.');
    }
    return _database!;
  }

  static Box get settingsBox {
    if (_settingsBox == null) {
      throw Exception('Hive non initialisé. Appelez DatabaseManager.initialize() d\'abord.');
    }
    return _settingsBox!;
  }

  static Box get cacheBox {
    if (_cacheBox == null) {
      throw Exception('Hive non initialisé. Appelez DatabaseManager.initialize() d\'abord.');
    }
    return _cacheBox!;
  }

  static Box get offlineBox {
    if (_offlineBox == null) {
      throw Exception('Hive non initialisé. Appelez DatabaseManager.initialize() d\'abord.');
    }
    return _offlineBox!;
  }

  // Méthodes de synchronisation
  static Future<void> syncAllData() async {
    try {
      print('Début de la synchronisation...');
      
      // Vérifier la connectivité
      if (!await _isConnected()) {
        print('Pas de connexion internet. Synchronisation reportée.');
        return;
      }

      // Synchroniser avec l'API
      await database.syncWithAPI();
      
      // Marquer la dernière synchronisation
      await _updateLastSyncTime();
      
      print('Synchronisation terminée avec succès');
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
      // Stocker les erreurs pour retry plus tard
      await _storeSyncError(e.toString());
    }
  }

  // Vérifier la connectivité
  static Future<bool> _isConnected() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_online') ?? false;
    } catch (e) {
      return false;
    }
  }

  // Mettre à jour le temps de dernière synchronisation
  static Future<void> _updateLastSyncTime() async {
    await settingsBox.put('last_sync', DateTime.now().toIso8601String());
  }

  // Obtenir le temps de dernière synchronisation
  static DateTime? getLastSyncTime() {
    final lastSyncString = settingsBox.get('last_sync');
    if (lastSyncString != null) {
      return DateTime.parse(lastSyncString);
    }
    return null;
  }

  // Stocker une erreur de synchronisation
  static Future<void> _storeSyncError(String error) async {
    final errors = List<String>.from(offlineBox.get('sync_errors', defaultValue: []));
    errors.add('${DateTime.now().toIso8601String()}: $error');
    await offlineBox.put('sync_errors', errors);
  }

  // Obtenir les erreurs de synchronisation
  static List<String> getSyncErrors() {
    return List<String>.from(offlineBox.get('sync_errors', defaultValue: []));
  }

  // Effacer les erreurs de synchronisation
  static Future<void> clearSyncErrors() async {
    await offlineBox.delete('sync_errors');
  }

  // Méthodes pour les données hors ligne
  static Future<void> storeOfflineData(String key, dynamic data) async {
    await offlineBox.put(key, data);
  }

  static dynamic getOfflineData(String key) {
    return offlineBox.get(key);
  }

  static Future<void> removeOfflineData(String key) async {
    await offlineBox.delete(key);
  }

  // Méthodes pour le cache
  static Future<void> cacheData(String key, dynamic data, {Duration? expiry}) async {
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await cacheBox.put(key, cacheEntry);
  }

  static dynamic getCachedData(String key) {
    final cacheEntry = cacheBox.get(key);
    if (cacheEntry == null) return null;

    final timestamp = cacheEntry['timestamp'] as int;
    final expiry = cacheEntry['expiry'] as int?;
    
    if (expiry != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > expiry) {
        // Cache expiré
        cacheBox.delete(key);
        return null;
      }
    }
    
    return cacheEntry['data'];
  }

  static Future<void> clearCache() async {
    await cacheBox.clear();
  }

  // Méthodes pour les paramètres
  static Future<void> setSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> removeSetting(String key) async {
    await settingsBox.delete(key);
  }

  // Méthodes utilitaires pour les données
  static Future<List<ClientsData>> getAllClients({bool forceRefresh = false}) async {
    if (forceRefresh) {
      await syncAllData();
    }
    return await database.getAllClients();
  }

  static Future<List<ArticlesData>> getAllArticles({bool forceRefresh = false}) async {
    if (forceRefresh) {
      await syncAllData();
    }
    return await database.getAllArticles();
  }

  static Future<List<CommandesData>> getAllCommandes({bool forceRefresh = false}) async {
    if (forceRefresh) {
      await syncAllData();
    }
    return await database.getAllCommandes();
  }

  static Future<List<FacturesData>> getAllFactures({bool forceRefresh = false}) async {
    if (forceRefresh) {
      await syncAllData();
    }
    return await database.getAllFactures();
  }

  static Future<List<DevisData>> getAllDevis({bool forceRefresh = false}) async {
    if (forceRefresh) {
      await syncAllData();
    }
    return await database.getAllDevis();
  }

  // Méthodes de recherche
  static Future<List<ClientsData>> searchClients(String query) async {
    final clients = await database.getAllClients();
    return clients.where((client) => 
      client.name.toLowerCase().contains(query.toLowerCase()) ||
      client.email.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  static Future<List<ArticlesData>> searchArticles(String query) async {
    final articles = await database.getAllArticles();
    return articles.where((article) => 
      article.name.toLowerCase().contains(query.toLowerCase()) ||
      (article.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  // Méthodes de statistiques
  static Future<Map<String, dynamic>> getStatistics() async {
    final clients = await database.getAllClients();
    final articles = await database.getAllArticles();
    final commandes = await database.getAllCommandes();
    final factures = await database.getAllFactures();
    final devis = await database.getAllDevis();

    double totalFactures = 0;
    double totalPaid = 0;
    for (var facture in factures) {
      totalFactures += facture.total;
      totalPaid += facture.paid;
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
      'last_sync': getLastSyncTime()?.toIso8601String(),
    };
  }

  // Nettoyage et maintenance
  static Future<void> cleanup() async {
    try {
      // Nettoyer le cache expiré
      final keys = cacheBox.keys.toList();
      for (var key in keys) {
        final cacheEntry = cacheBox.get(key);
        if (cacheEntry != null) {
          final timestamp = cacheEntry['timestamp'] as int;
          final expiry = cacheEntry['expiry'] as int?;
          
          if (expiry != null) {
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - timestamp > expiry) {
              await cacheBox.delete(key);
            }
          }
        }
      }
      
      print('Nettoyage de la base de données terminé');
    } catch (e) {
      print('Erreur lors du nettoyage: $e');
    }
  }

  // Fermer les connexions
  static Future<void> close() async {
    try {
      await _database?.close();
      await _settingsBox?.close();
      await _cacheBox?.close();
      await _offlineBox?.close();
      print('Connexions à la base de données fermées');
    } catch (e) {
      print('Erreur lors de la fermeture: $e');
    }
  }
}
