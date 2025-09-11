class LocalDbService {
  static const String clientsBoxName = 'clients_box';
  static const String settingsBoxName = 'settings_box';

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  // Clients
  Future<void> upsertClient(String id, Map<String, dynamic> client) async {
    // No-op implementation
  }

  Map<String, dynamic>? getClient(String id) {
    // No-op implementation
    return null;
  }

  Future<void> deleteClient(String id) async {
    // No-op implementation
  }

  Future<List<Map<String, dynamic>>> getAllClients() async {
    // No-op implementation
    return [];
  }

  // Settings
  Future<void> setSetting(String key, dynamic value) async {
    // No-op implementation
  }

  T? getSetting<T>(String key) {
    // No-op implementation
    return null;
  }
}


