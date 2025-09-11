import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabaseService {
  static const String _appBox = 'app_data_box';
  static bool _initialized = false;
  static late Box<Map<dynamic, dynamic>> _box;

  // Initialiser Hive
  static Future<void> init() async {
    if (_initialized) return;
    
    await Hive.initFlutter();
    
    // Ouvrir la boîte
    _box = await Hive.openBox(_appBox);
    
    _initialized = true;
  }

  // Vérifier si le service est initialisé
  static void _checkInitialized() {
    if (!_initialized) {
      throw Exception('HiveDatabaseService must be initialized first');
    }
  }

  // Sauvegarder des données
  static Future<void> saveData({
    required String id,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    _checkInitialized();
    
    final item = {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    await _box.put(id, item);
  }

  // Récupérer des données par ID
  static Map<String, dynamic>? getData(String id) {
    _checkInitialized();
    final item = _box.get(id);
    if (item == null) return null;
    
    return Map<String, dynamic>.from(item['data']);
  }

  // Récupérer toutes les données d'un certain type
  static List<Map<String, dynamic>> getAllData(String type) {
    _checkInitialized();
    
    return _box.values
        .where((item) => item['type'] == type)
        .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item['data']))
        .toList();
  }

  // Supprimer des données
  static Future<void> deleteData(String id) async {
    _checkInitialized();
    await _box.delete(id);
  }

  // Vider toutes les données
  static Future<void> clearAllData() async {
    _checkInitialized();
    await _box.clear();
  }

  // Fermer la connexion
  static Future<void> close() async {
    _checkInitialized();
    await _box.close();
    _initialized = false;
  }
}
