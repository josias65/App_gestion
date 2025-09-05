// Import des dépendances nécessaires
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

// Import des modèles et services
import 'database_service.dart';
import '../models/article.dart';
import '../models/client.dart';
import '../models/commande.dart';
import '../models/facture.dart';
import '../models/devis.dart';
import '../config/api_config.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._();
  static bool _isInitialized = false;
  
  // Boxes Hive
  late final Box _settingsBox;
  late final Box _cacheBox;
  late final Box _offlineBox;
  
  // Getters pour les boxes
  Box get settingsBox => _settingsBox;
  Box get cacheBox => _cacheBox;
  Box get offlineBox => _offlineBox;

  DatabaseManager._();

  static DatabaseManager get instance {
    if (!_isInitialized) {
      throw Exception('DatabaseManager must be initialized first. Call initialize() before accessing instance.');
    }
    return _instance;
  }

  // Instance de la base de données Drift
  late final AppDatabase _database;

  // Initialisation de la base de données
  static Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      
      // Initialiser Hive avec un répertoire de stockage
      final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
      final hivePath = path.join(appDocumentDir.path, 'hive');
      await Directory(hivePath).create(recursive: true);
      
      Hive.init(hivePath);
      
      // Enregistrer les adaptateurs Hive
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ClientAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ArticleAdapter());
      }
      
      // Ouvrir les boîtes Hive
      _instance._settingsBox = await Hive.openBox('app_settings');
      _instance._cacheBox = await Hive.openBox('app_cache');
      _instance._offlineBox = await Hive.openBox('offline_data');
      
      // Initialiser la base de données Drift
      _instance._database = AppDatabase();
      
      _isInitialized = true;
      debugPrint('Base de données initialisée avec succès');
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de l\'initialisation de la base de données: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Getters pour accéder aux instances
  AppDatabase get database {
    _checkInitialized();
    return _database;
  }

  // Suppression des getters statiques en conflit
  // Utilisez DatabaseManager.instance.settingsBox au lieu de DatabaseManager.settingsBox

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
  static Future<List<Article>> getAllArticles({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await syncAllData();
      }
      // Récupérer les articles depuis Hive
      final box = await Hive.openBox<Article>('articles');
      return box.values.toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des articles: $e');
      rethrow;
    }
  }

  static Future<List<Client>> getAllClients({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await syncAllData();
      }
      // Récupérer les clients depuis Hive
      final box = await Hive.openBox<Client>('clients');
      return box.values.toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des clients: $e');
      rethrow;
    }
  }

  static Future<List<CommandesData>> getAllCommandes({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await syncAllData();
      }
      // Utiliser la méthode getAllCommandes de AppDatabase
      return await database.getAllCommandes();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des commandes: $e');
      rethrow;
    }
  }

  static Future<List<FacturesData>> getAllFactures({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await syncAllData();
      }
      // Utiliser la méthode getAllFactures de AppDatabase
      return await database.getAllFactures();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des factures: $e');
      rethrow;
    }
  }

  static Future<List<DevisData>> getAllDevis({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await syncAllData();
      }
      // Utiliser la méthode getAllDevis de AppDatabase
      return await database.getAllDevis();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des devis: $e');
      rethrow;
    }
  }

  // Méthodes de recherche
  static Future<List<ArticlesData>> searchArticles(String query) async {
    try {
      final allArticles = await database.getAllArticles();
      final queryLower = query.toLowerCase();
      
      return allArticles.where((article) => 
(article.name?.toLowerCase().contains(queryLower) ?? false) ||
        (article.description?.toLowerCase().contains(queryLower) ?? false)
      ).toList();
    } catch (e) {
      debugPrint('Erreur lors de la recherche d\'articles: $e');
      rethrow;
    }
  }

  static Future<List<ClientsData>> searchClients(String query) async {
    try {
      final allClients = await database.getAllClients();
      final queryLower = query.toLowerCase();
      
      return allClients.where((client) => 
        (client.name?.toLowerCase().contains(queryLower) ?? false) ||
        (client.email?.toLowerCase().contains(queryLower) ?? false) ||
        (client.phone?.toLowerCase().contains(queryLower) ?? false)
      ).toList();
    } catch (e) {
      debugPrint('Erreur lors de la recherche de clients: $e');
      rethrow;
    }
  }

  }

  // Méthodes de statistiques
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
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
    } catch (e) {
      debugPrint('Erreur lors du calcul des statistiques: $e');
      rethrow;
    }
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

  // Fermeture de la base de données
  static Future<void> close() async {
    // La méthode close n'existe pas directement sur AppDatabase
    // On peut simplement libérer la référence
    _database = null;
    await _settingsBox?.close();
    _settingsBox = null;
    await _cacheBox?.close();
    _cacheBox = null;
    await _offlineBox?.close();
    _offlineBox = null;
  }

  // Méthode utilitaire pour vérifier l'initialisation
  static void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('DatabaseManager must be initialized first. Call initialize() before using any methods.');
    }
  }
}
