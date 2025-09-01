import 'package:hive_flutter/hive_flutter.dart';

class LocalDbService {
  static const String clientsBoxName = 'clients_box';
  static const String settingsBoxName = 'settings_box';

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox(clientsBoxName);
    await Hive.openBox(settingsBoxName);
    _initialized = true;
  }

  // Clients
  Future<void> upsertClient(String id, Map<String, dynamic> client) async {
    final box = Hive.box(clientsBoxName);
    await box.put(id, client);
  }

  Map<String, dynamic>? getClient(String id) {
    final box = Hive.box(clientsBoxName);
    final dynamic value = box.get(id);
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  Future<void> deleteClient(String id) async {
    final box = Hive.box(clientsBoxName);
    await box.delete(id);
  }

  List<Map<String, dynamic>> getAllClients() {
    final box = Hive.box(clientsBoxName);
    return box.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // Settings simples
  Future<void> setSetting(String key, dynamic value) async {
    final box = Hive.box(settingsBoxName);
    await box.put(key, value);
  }

  T? getSetting<T>(String key) {
    final box = Hive.box(settingsBoxName);
    final dynamic value = box.get(key);
    return value as T?;
  }
}


