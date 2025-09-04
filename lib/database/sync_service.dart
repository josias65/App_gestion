import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_manager.dart';
import '../config/api_config.dart';
import '../models/models.dart';

class SyncService {
  static SyncService? _instance;
  static Timer? _syncTimer;
  static StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  static bool _isOnline = false;
  static bool _isSyncing = false;

  SyncService._();

  static SyncService get instance {
    _instance ??= SyncService._();
    return _instance!;
  }

  // Initialiser le service de synchronisation
  static Future<void> initialize() async {
    try {
      // Écouter les changements de connectivité
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) => print('Erreur de connectivité: $error'),
      );

      // Vérifier la connectivité initiale
      final connectivityResult = await Connectivity().checkConnectivity();
      _isOnline = connectivityResult != ConnectivityResult.none;

      // Démarrer la synchronisation périodique
      _startPeriodicSync();

      print('Service de synchronisation initialisé');
    } catch (e) {
      print('Erreur lors de l\'initialisation du service de synchronisation: $e');
    }
  }

  // Gérer les changements de connectivité
  static void _onConnectivityChanged(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    if (!wasOnline && _isOnline) {
      // Connexion rétablie, synchroniser immédiatement
      print('Connexion rétablie, synchronisation en cours...');
      syncNow();
    } else if (wasOnline && !_isOnline) {
      print('Connexion perdue, mode hors ligne activé');
    }
  }

  // Démarrer la synchronisation périodique
  static void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 15), // Synchroniser toutes les 15 minutes
      (timer) {
        if (_isOnline && !_isSyncing) {
          syncNow();
        }
      },
    );
  }

  // Synchroniser maintenant
  static Future<void> syncNow() async {
    if (_isSyncing) {
      print('Synchronisation déjà en cours...');
      return;
    }

    if (!_isOnline) {
      print('Pas de connexion internet, synchronisation impossible');
      return;
    }

    _isSyncing = true;
    try {
      print('Début de la synchronisation...');
      await DatabaseManager.syncAllData();
      print('Synchronisation terminée avec succès');
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Synchroniser des données spécifiques
  static Future<void> syncClients() async {
    if (!_isOnline) return;

    try {
      await DatabaseManager.database._syncClients();
      print('Synchronisation des clients terminée');
    } catch (e) {
      print('Erreur lors de la synchronisation des clients: $e');
    }
  }

  static Future<void> syncArticles() async {
    if (!_isOnline) return;

    try {
      await DatabaseManager.database._syncArticles();
      print('Synchronisation des articles terminée');
    } catch (e) {
      print('Erreur lors de la synchronisation des articles: $e');
    }
  }

  static Future<void> syncCommandes() async {
    if (!_isOnline) return;

    try {
      await DatabaseManager.database._syncCommandes();
      print('Synchronisation des commandes terminée');
    } catch (e) {
      print('Erreur lors de la synchronisation des commandes: $e');
    }
  }

  static Future<void> syncFactures() async {
    if (!_isOnline) return;

    try {
      await DatabaseManager.database._syncFactures();
      print('Synchronisation des factures terminée');
    } catch (e) {
      print('Erreur lors de la synchronisation des factures: $e');
    }
  }

  static Future<void> syncDevis() async {
    if (!_isOnline) return;

    try {
      await DatabaseManager.database._syncDevis();
      print('Synchronisation des devis terminée');
    } catch (e) {
      print('Erreur lors de la synchronisation des devis: $e');
    }
  }

  // Vérifier si en ligne
  static bool get isOnline => _isOnline;

  // Vérifier si en cours de synchronisation
  static bool get isSyncing => _isSyncing;

  // Obtenir le statut de synchronisation
  static Map<String, dynamic> getSyncStatus() {
    return {
      'is_online': _isOnline,
      'is_syncing': _isSyncing,
      'last_sync': DatabaseManager.getLastSyncTime()?.toIso8601String(),
      'sync_errors': DatabaseManager.getSyncErrors(),
    };
  }

  // Forcer la synchronisation (pour les actions utilisateur)
  static Future<void> forceSync() async {
    if (_isSyncing) return;
    
    print('Synchronisation forcée par l\'utilisateur');
    await syncNow();
  }

  // Arrêter le service de synchronisation
  static void stop() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    print('Service de synchronisation arrêté');
  }

  // Redémarrer le service de synchronisation
  static Future<void> restart() async {
    stop();
    await initialize();
  }
}
