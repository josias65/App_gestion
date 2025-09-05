import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

import '../models/app_user.dart';

class HiveInitializationException implements Exception {
  final String message;
  HiveInitializationException(this.message);
  
  @override
  String toString() => 'HiveInitializationException: $message';
}

class HiveService {
  static bool _isInitialized = false;
  static final Map<String, Box> _openBoxes = {};

  /// Initialise Hive avec gestion des erreurs
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Initialiser Hive avec un répertoire de stockage
      final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
      
      // Créer un sous-dossier pour les données Hive
      final hivePath = path.join(appDocumentDir.path, 'hive');
      await Directory(hivePath).create(recursive: true);
      
      Hive.init(hivePath);
      
      // Enregistrer les adaptateurs
      if (!Hive.isAdapterRegistered(AppUserAdapter().typeId)) {
        Hive.registerAdapter(AppUserAdapter());
      }
      
      // Ouvrir les boîtes (tables) avec gestion des erreurs
      await Future.wait([
        _openBox('settings'),
        _openBox('users'),
        _openBox('app_data'),
      ]);
      
      _isInitialized = true;
      debugPrint('Hive initialisé avec succès');
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de l\'initialisation de Hive: $e');
      debugPrint('Stack trace: $stackTrace');
      throw HiveInitializationException('Impossible d\'initialiser le stockage local: $e');
    }
  }
  
  static Future<Box> _openBox(String name) async {
    try {
      if (_openBoxes.containsKey(name)) {
        return _openBoxes[name]!;
      }
      
      final box = await Hive.openBox(name);
      _openBoxes[name] = box;
      return box;
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture de la boîte $name: $e');
      rethrow;
    }
  }

  // Méthodes utilitaires avec typage fort et gestion d'erreurs
  static Future<Box> getBox(String boxName) async {
    if (!_isInitialized) {
      await init();
    }
    
    if (!_openBoxes.containsKey(boxName)) {
      return await _openBox(boxName);
    }
    
    return _openBoxes[boxName]!;
  }

  /// Enregistre une valeur dans une boîte
  static Future<void> saveData<T>({
    required String boxName,
    required dynamic key,
    required T value,
  }) async {
    try {
      final box = await getBox(boxName);
      await box.put(key, value);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des données dans $boxName: $e');
      rethrow;
    }
  }

  /// Récupère une valeur typée depuis une boîte
  static Future<T?> getData<T>({
    required String boxName,
    required dynamic key,
    T? defaultValue,
  }) async {
    try {
      final box = await getBox(boxName);
      return box.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des données depuis $boxName: $e');
      rethrow;
    }
  }

  /// Supprime une entrée d'une boîte
  static Future<void> deleteData({
    required String boxName,
    required dynamic key,
  }) async {
    try {
      final box = await getBox(boxName);
      await box.delete(key);
    } catch (e) {
      debugPrint('Erreur lors de la suppression des données de $boxName: $e');
      rethrow;
    }
  }
  
  /// Vide complètement une boîte
  static Future<void> clearBox(String boxName) async {
    try {
      final box = await getBox(boxName);
      await box.clear();
    } catch (e) {
      debugPrint('Erreur lors du vidage de la boîte $boxName: $e');
      rethrow;
    }
  }
  
  /// Ferme toutes les boîtes et nettoie les ressources
  static Future<void> close() async {
    try {
      await Hive.close();
      _openBoxes.clear();
      _isInitialized = false;
    } catch (e) {
      debugPrint('Erreur lors de la fermeture de Hive: $e');
      rethrow;
    }
  }
}
