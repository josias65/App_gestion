import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../models/app_user.dart';

class HiveService {
  static Future<void> init() async {
    // Initialiser Hive avec un répertoire de stockage
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    
    // Enregistrer les adaptateurs
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AppUserAdapter());
    }
    
    // Ouvrir les boîtes (tables)
    await Hive.openBox('settings');
    await Hive.openBox('users');
    await Hive.openBox('app_data');
  }

  // Méthodes utilitaires
  static Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  static Future<void> saveData(String boxName, String key, dynamic value) async {
    final box = getBox(boxName);
    await box.put(key, value);
  }

  static dynamic getData(String boxName, String key) {
    final box = getBox(boxName);
    return box.get(key);
  }

  static Future<void> deleteData(String boxName, String key) async {
    final box = getBox(boxName);
    await box.delete(key);
  }
  
  static Future<void> clearBox(String boxName) async {
    final box = getBox(boxName);
    await box.clear();
  }
}
