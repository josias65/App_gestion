import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _appBox = 'app_box';
  static const String _clientsBox = 'clients_box';
  static const String _articlesBox = 'articles_box';
  static const String _commandesBox = 'commandes_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Enregistrer les adaptateurs ici
    // Hive.registerAdapter(ClientAdapter());
    // Hive.registerAdapter(ArticleAdapter());
    
    // Ouvrir les boîtes
    await Future.wait([
      Hive.openBox(_appBox),
      Hive.openBox(_clientsBox),
      Hive.openBox(_articlesBox),
      Hive.openBox(_commandesBox),
    ]);
  }

  // Méthodes génériques pour gérer n'importe quelle boîte
  static Box _getBox(String boxName) {
    return Hive.box(boxName);
  }

  // Méthodes pour les clients
  static Future<void> saveClient(String id, Map<String, dynamic> client) async {
    final box = _getBox(_clientsBox);
    await box.put(id, client);
  }

  static Map<String, dynamic>? getClient(String id) {
    final box = _getBox(_clientsBox);
    return box.get(id);
  }

  static List<Map<String, dynamic>> getAllClients() {
    final box = _getBox(_clientsBox);
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  // Méthodes pour les articles
  static Future<void> saveArticle(String id, Map<String, dynamic> article) async {
    final box = _getBox(_articlesBox);
    await box.put(id, article);
  }

  static Map<String, dynamic>? getArticle(String id) {
    final box = _getBox(_articlesBox);
    return box.get(id);
  }

  // Méthodes pour les commandes
  static Future<void> saveCommande(String id, Map<String, dynamic> commande) async {
    final box = _getBox(_commandesBox);
    await box.put(id, commande);
  }

  static Map<String, dynamic>? getCommande(String id) {
    final box = _getBox(_commandesBox);
    return box.get(id);
  }

  // Nettoyage
  static Future<void> clearAllData() async {
    await Future.wait([
      _getBox(_appBox).clear(),
      _getBox(_clientsBox).clear(),
      _getBox(_articlesBox).clear(),
      _getBox(_commandesBox).clear(),
    ]);
  }
}
