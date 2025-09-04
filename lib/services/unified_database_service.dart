import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/database_manager.dart';
import '../database/sync_service.dart';
import '../config/api_config.dart';
import '../models/models.dart';

class UnifiedDatabaseService {
  static UnifiedDatabaseService? _instance;

  UnifiedDatabaseService._();

  static UnifiedDatabaseService get instance {
    _instance ??= UnifiedDatabaseService._();
    return _instance!;
  }

  // ========== CLIENTS ==========
  
  Future<List<ClientsData>> getClients({bool forceRefresh = false}) async {
    try {
      if (forceRefresh && SyncService.isOnline) {
        await SyncService.syncClients();
      }
      return await DatabaseManager.getAllClients(forceRefresh: forceRefresh);
    } catch (e) {
      print('Erreur lors de la récupération des clients: $e');
      return [];
    }
  }

  Future<ClientsData?> getClientById(String clientId) async {
    try {
      return await DatabaseManager.database.getClientById(clientId);
    } catch (e) {
      print('Erreur lors de la récupération du client: $e');
      return null;
    }
  }

  Future<bool> createClient(Map<String, dynamic> clientData) async {
    try {
      if (SyncService.isOnline) {
        // Créer sur l'API d'abord
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.clientsEndpoint}'),
          headers: ApiConfig.defaultHeaders,
          body: json.encode(clientData),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final createdClient = responseData['data'];
          
          // Insérer dans la base locale
          await DatabaseManager.database.insertClient(ClientsCompanion(
            clientId: Value(createdClient['id'].toString()),
            name: Value(createdClient['name']),
            email: Value(createdClient['email']),
            phone: Value(createdClient['phone']),
            address: Value(createdClient['address']),
            city: Value(createdClient['city']),
            country: Value(createdClient['country']),
            createdAt: Value(DateTime.parse(createdClient['created_at'])),
            lastSync: Value(DateTime.now()),
          ));
          
          return true;
        }
      } else {
        // Mode hors ligne - stocker pour synchronisation plus tard
        await DatabaseManager.storeOfflineData('pending_client_${DateTime.now().millisecondsSinceEpoch}', clientData);
        
        // Créer un ID temporaire pour l'affichage local
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        await DatabaseManager.database.insertClient(ClientsCompanion(
          clientId: Value(tempId),
          name: Value(clientData['name']),
          email: Value(clientData['email']),
          phone: Value(clientData['phone']),
          address: Value(clientData['address']),
          city: Value(clientData['city']),
          country: Value(clientData['country']),
          createdAt: Value(DateTime.now()),
          lastSync: Value(null),
        ));
        
        return true;
      }
    } catch (e) {
      print('Erreur lors de la création du client: $e');
    }
    return false;
  }

  Future<bool> updateClient(String clientId, Map<String, dynamic> clientData) async {
    try {
      if (SyncService.isOnline) {
        final response = await http.put(
          Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.clientsEndpoint}/$clientId'),
          headers: ApiConfig.defaultHeaders,
          body: json.encode(clientData),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final updatedClient = responseData['data'];
          
          await DatabaseManager.database.updateClient(ClientsCompanion(
            clientId: Value(updatedClient['id'].toString()),
            name: Value(updatedClient['name']),
            email: Value(updatedClient['email']),
            phone: Value(updatedClient['phone']),
            address: Value(updatedClient['address']),
            city: Value(updatedClient['city']),
            country: Value(updatedClient['country']),
            createdAt: Value(DateTime.parse(updatedClient['created_at'])),
            lastSync: Value(DateTime.now()),
          ));
          
          return true;
        }
      } else {
        // Mode hors ligne
        await DatabaseManager.storeOfflineData('pending_update_client_$clientId', {
          'id': clientId,
          'data': clientData,
        });
        
        // Mettre à jour localement
        final existingClient = await DatabaseManager.database.getClientById(clientId);
        if (existingClient != null) {
          await DatabaseManager.database.updateClient(ClientsCompanion(
            clientId: Value(clientId),
            name: Value(clientData['name'] ?? existingClient.name),
            email: Value(clientData['email'] ?? existingClient.email),
            phone: Value(clientData['phone'] ?? existingClient.phone),
            address: Value(clientData['address'] ?? existingClient.address),
            city: Value(clientData['city'] ?? existingClient.city),
            country: Value(clientData['country'] ?? existingClient.country),
            createdAt: Value(existingClient.createdAt),
            lastSync: Value(null),
          ));
        }
        
        return true;
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du client: $e');
    }
    return false;
  }

  Future<bool> deleteClient(String clientId) async {
    try {
      if (SyncService.isOnline) {
        final response = await http.delete(
          Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.clientsEndpoint}/$clientId'),
          headers: ApiConfig.defaultHeaders,
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          await DatabaseManager.database.deleteClient(clientId);
          return true;
        }
      } else {
        // Mode hors ligne
        await DatabaseManager.storeOfflineData('pending_delete_client_$clientId', {
          'id': clientId,
          'action': 'delete',
        });
        
        await DatabaseManager.database.deleteClient(clientId);
        return true;
      }
    } catch (e) {
      print('Erreur lors de la suppression du client: $e');
    }
    return false;
  }

  // ========== ARTICLES ==========
  
  Future<List<ArticlesData>> getArticles({bool forceRefresh = false}) async {
    try {
      if (forceRefresh && SyncService.isOnline) {
        await SyncService.syncArticles();
      }
      return await DatabaseManager.getAllArticles(forceRefresh: forceRefresh);
    } catch (e) {
      print('Erreur lors de la récupération des articles: $e');
      return [];
    }
  }

  Future<ArticlesData?> getArticleById(String articleId) async {
    try {
      return await DatabaseManager.database.getArticleById(articleId);
    } catch (e) {
      print('Erreur lors de la récupération de l\'article: $e');
      return null;
    }
  }

  Future<bool> createArticle(Map<String, dynamic> articleData) async {
    try {
      if (SyncService.isOnline) {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.articlesEndpoint}'),
          headers: ApiConfig.defaultHeaders,
          body: json.encode(articleData),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final createdArticle = responseData['data'];
          
          await DatabaseManager.database.insertArticle(ArticlesCompanion(
            articleId: Value(createdArticle['id'].toString()),
            name: Value(createdArticle['name']),
            description: Value(createdArticle['description']),
            price: Value(createdArticle['price'].toDouble()),
            quantity: Value(createdArticle['quantity']),
            unit: Value(createdArticle['unit']),
            category: Value(createdArticle['category']),
            createdAt: Value(DateTime.parse(createdArticle['created_at'])),
            lastSync: Value(DateTime.now()),
          ));
          
          return true;
        }
      } else {
        // Mode hors ligne
        await DatabaseManager.storeOfflineData('pending_article_${DateTime.now().millisecondsSinceEpoch}', articleData);
        
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        await DatabaseManager.database.insertArticle(ArticlesCompanion(
          articleId: Value(tempId),
          name: Value(articleData['name']),
          description: Value(articleData['description']),
          price: Value(articleData['price'].toDouble()),
          quantity: Value(articleData['quantity']),
          unit: Value(articleData['unit']),
          category: Value(articleData['category']),
          createdAt: Value(DateTime.now()),
          lastSync: Value(null),
        ));
        
        return true;
      }
    } catch (e) {
      print('Erreur lors de la création de l\'article: $e');
    }
    return false;
  }

  // ========== COMMANDES ==========
  
  Future<List<CommandesData>> getCommandes({bool forceRefresh = false}) async {
    try {
      if (forceRefresh && SyncService.isOnline) {
        await SyncService.syncCommandes();
      }
      return await DatabaseManager.getAllCommandes(forceRefresh: forceRefresh);
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
      return [];
    }
  }

  Future<CommandesData?> getCommandeById(String commandeId) async {
    try {
      return await DatabaseManager.database.getCommandeById(commandeId);
    } catch (e) {
      print('Erreur lors de la récupération de la commande: $e');
      return null;
    }
  }

  Future<bool> createCommande(Map<String, dynamic> commandeData) async {
    try {
      if (SyncService.isOnline) {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.commandesEndpoint}'),
          headers: ApiConfig.defaultHeaders,
          body: json.encode(commandeData),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final createdCommande = responseData['data'];
          
          await DatabaseManager.database.insertCommande(CommandesCompanion(
            commandeId: Value(createdCommande['id'].toString()),
            clientId: Value(createdCommande['client_id'].toString()),
            reference: Value(createdCommande['reference']),
            date: Value(DateTime.parse(createdCommande['date'])),
            status: Value(createdCommande['status']),
            total: Value(createdCommande['total'].toDouble()),
            notes: Value(createdCommande['notes']),
            createdAt: Value(DateTime.parse(createdCommande['created_at'])),
            lastSync: Value(DateTime.now()),
          ));
          
          return true;
        }
      } else {
        // Mode hors ligne
        await DatabaseManager.storeOfflineData('pending_commande_${DateTime.now().millisecondsSinceEpoch}', commandeData);
        
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        await DatabaseManager.database.insertCommande(CommandesCompanion(
          commandeId: Value(tempId),
          clientId: Value(commandeData['client_id'].toString()),
          reference: Value(commandeData['reference']),
          date: Value(DateTime.parse(commandeData['date'])),
          status: Value(commandeData['status']),
          total: Value(commandeData['total'].toDouble()),
          notes: Value(commandeData['notes']),
          createdAt: Value(DateTime.now()),
          lastSync: Value(null),
        ));
        
        return true;
      }
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
    }
    return false;
  }

  // ========== FACTURES ==========
  
  Future<List<FacturesData>> getFactures({bool forceRefresh = false}) async {
    try {
      if (forceRefresh && SyncService.isOnline) {
        await SyncService.syncFactures();
      }
      return await DatabaseManager.getAllFactures(forceRefresh: forceRefresh);
    } catch (e) {
      print('Erreur lors de la récupération des factures: $e');
      return [];
    }
  }

  Future<FacturesData?> getFactureById(String factureId) async {
    try {
      return await DatabaseManager.database.getFactureById(factureId);
    } catch (e) {
      print('Erreur lors de la récupération de la facture: $e');
      return null;
    }
  }

  // ========== DEVIS ==========
  
  Future<List<DevisData>> getDevis({bool forceRefresh = false}) async {
    try {
      if (forceRefresh && SyncService.isOnline) {
        await SyncService.syncDevis();
      }
      return await DatabaseManager.getAllDevis(forceRefresh: forceRefresh);
    } catch (e) {
      print('Erreur lors de la récupération des devis: $e');
      return [];
    }
  }

  Future<DevisData?> getDevisById(String devisId) async {
    try {
      return await DatabaseManager.database.getDevisById(devisId);
    } catch (e) {
      print('Erreur lors de la récupération du devis: $e');
      return null;
    }
  }

  // ========== STATISTIQUES ==========
  
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      return await DatabaseManager.getStatistics();
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return {};
    }
  }

  // ========== RECHERCHE ==========
  
  Future<List<ClientsData>> searchClients(String query) async {
    try {
      return await DatabaseManager.searchClients(query);
    } catch (e) {
      print('Erreur lors de la recherche de clients: $e');
      return [];
    }
  }

  Future<List<ArticlesData>> searchArticles(String query) async {
    try {
      return await DatabaseManager.searchArticles(query);
    } catch (e) {
      print('Erreur lors de la recherche d\'articles: $e');
      return [];
    }
  }

  // ========== SYNCHRONISATION ==========
  
  Future<void> syncAll() async {
    await SyncService.forceSync();
  }

  Future<void> syncClients() async {
    await SyncService.syncClients();
  }

  Future<void> syncArticles() async {
    await SyncService.syncArticles();
  }

  Future<void> syncCommandes() async {
    await SyncService.syncCommandes();
  }

  Future<void> syncFactures() async {
    await SyncService.syncFactures();
  }

  Future<void> syncDevis() async {
    await SyncService.syncDevis();
  }

  // ========== STATUT ==========
  
  Map<String, dynamic> getSyncStatus() {
    return SyncService.getSyncStatus();
  }

  bool get isOnline => SyncService.isOnline;
  bool get isSyncing => SyncService.isSyncing;
}
