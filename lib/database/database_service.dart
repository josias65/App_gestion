import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
// import '../models/models.dart'; // Commenté temporairement pour éviter les conflits

part 'database_service.g.dart';

// Tables de base de données
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get avatar => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  TextColumn get role => text()();
  BoolColumn get isActive => boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get lastSync => dateTime().named('last_sync').nullable()();
}

class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientId => text().named('client_id')();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get country => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastSync => dateTime().named('last_sync').nullable()();
}

class Articles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get articleId => text().named('article_id')();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get price => real()();
  IntColumn get quantity => integer()();
  TextColumn get unit => text()();
  TextColumn get category => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastSync => dateTime().named('last_sync').nullable()();
}

class Commandes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get commandeId => text().named('commande_id')();
  TextColumn get clientId => text().named('client_id')();
  TextColumn get reference => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => text()();
  RealColumn get total => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastSync => dateTime().named('last_sync').nullable()();
}

class Factures extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get factureId => text().named('facture_id')();
  TextColumn get clientId => text().named('client_id')();
  TextColumn get reference => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => text()();
  RealColumn get total => real()();
  RealColumn get paid => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastSync => dateTime().named('last_sync').nullable()();
}

class Devis extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get devisId => text().named('devis_id')();
  TextColumn get clientId => text().named('client_id')();
  TextColumn get reference => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => text()();
  RealColumn get total => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastSync => dateTime().named('last_sync').nullable()();
}

// Classe principale de la base de données
@DriftDatabase(tables: [Users, Clients, Articles, Commandes, Factures, Devis])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Méthodes pour les utilisateurs
  Future<List<UsersData>> getAllUsers() => select(users).get();
  Future<UsersData?> getUserById(String userId) => 
      (select(users)..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);
  Future<bool> updateUser(UsersCompanion user) => update(users).replace(user);
  Future<int> deleteUser(String userId) => 
      (delete(users)..where((tbl) => tbl.userId.equals(userId))).go();

  // Méthodes pour les clients
  Future<List<ClientsData>> getAllClients() => select(clients).get();
  Future<ClientsData?> getClientById(String clientId) => 
      (select(clients)..where((tbl) => tbl.clientId.equals(clientId))).getSingleOrNull();
  Future<int> insertClient(ClientsCompanion client) => into(clients).insert(client);
  Future<bool> updateClient(ClientsCompanion client) => update(clients).replace(client);
  Future<int> deleteClient(String clientId) => 
      (delete(clients)..where((tbl) => tbl.clientId.equals(clientId))).go();

  // Méthodes pour les articles
  Future<List<ArticlesData>> getAllArticles() => select(articles).get();
  Future<ArticlesData?> getArticleById(String articleId) => 
      (select(articles)..where((tbl) => tbl.articleId.equals(articleId))).getSingleOrNull();
  Future<int> insertArticle(ArticlesCompanion article) => into(articles).insert(article);
  Future<bool> updateArticle(ArticlesCompanion article) => update(articles).replace(article);
  Future<int> deleteArticle(String articleId) => 
      (delete(articles)..where((tbl) => tbl.articleId.equals(articleId))).go();

  // Méthodes pour les commandes
  Future<List<CommandesData>> getAllCommandes() => select(commandes).get();
  Future<CommandesData?> getCommandeById(String commandeId) => 
      (select(commandes)..where((tbl) => tbl.commandeId.equals(commandeId))).getSingleOrNull();
  Future<int> insertCommande(CommandesCompanion commande) => into(commandes).insert(commande);
  Future<bool> updateCommande(CommandesCompanion commande) => update(commandes).replace(commande);
  Future<int> deleteCommande(String commandeId) => 
      (delete(commandes)..where((tbl) => tbl.commandeId.equals(commandeId))).go();

  // Méthodes pour les factures
  Future<List<FacturesData>> getAllFactures() => select(factures).get();
  Future<FacturesData?> getFactureById(String factureId) => 
      (select(factures)..where((tbl) => tbl.factureId.equals(factureId))).getSingleOrNull();
  Future<int> insertFacture(FacturesCompanion facture) => into(factures).insert(facture);
  Future<bool> updateFacture(FacturesCompanion facture) => update(factures).replace(facture);
  Future<int> deleteFacture(String factureId) => 
      (delete(factures)..where((tbl) => tbl.factureId.equals(factureId))).go();

  // Méthodes pour les devis
  Future<List<DevisData>> getAllDevis() => select(devis).get();
  Future<DevisData?> getDevisById(String devisId) => 
      (select(devis)..where((tbl) => tbl.devisId.equals(devisId))).getSingleOrNull();
  Future<int> insertDevis(DevisCompanion devi) => into(devis).insert(devi);
  Future<bool> updateDevis(DevisCompanion devi) => update(devis).replace(devi);
  Future<int> deleteDevis(String devisId) => 
      (delete(devis)..where((tbl) => tbl.devisId.equals(devisId))).go();

  // Méthodes de synchronisation
  Future<void> syncWithAPI() async {
    try {
      // Synchroniser les clients
      await _syncClients();
      // Synchroniser les articles
      await _syncArticles();
      // Synchroniser les commandes
      await _syncCommandes();
      // Synchroniser les factures
      await _syncFactures();
      // Synchroniser les devis
      await _syncDevis();
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    }
  }

  Future<void> _syncClients() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.clientsEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'] ?? [];
        
        for (var clientData in data) {
          final existingClient = await getClientById(clientData['id'].toString());
          if (existingClient == null) {
            await insertClient(ClientsCompanion(
              clientId: Value(clientData['id'].toString()),
              name: Value(clientData['name']),
              email: Value(clientData['email']),
              phone: Value(clientData['phone']),
              address: Value(clientData['address']),
              city: Value(clientData['city']),
              country: Value(clientData['country']),
              createdAt: Value(DateTime.parse(clientData['created_at'])),
              lastSync: Value(DateTime.now()),
            ));
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des clients: $e');
    }
  }

  Future<void> _syncArticles() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.articlesEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'] ?? [];
        
        for (var articleData in data) {
          final existingArticle = await getArticleById(articleData['id'].toString());
          if (existingArticle == null) {
            await insertArticle(ArticlesCompanion(
              articleId: Value(articleData['id'].toString()),
              name: Value(articleData['name']),
              description: Value(articleData['description']),
              price: Value(articleData['price'].toDouble()),
              quantity: Value(articleData['quantity']),
              unit: Value(articleData['unit']),
              category: Value(articleData['category']),
              createdAt: Value(DateTime.parse(articleData['created_at'])),
              lastSync: Value(DateTime.now()),
            ));
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des articles: $e');
    }
  }

  Future<void> _syncCommandes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.commandesEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'] ?? [];
        
        for (var commandeData in data) {
          final existingCommande = await getCommandeById(commandeData['id'].toString());
          if (existingCommande == null) {
            await insertCommande(CommandesCompanion(
              commandeId: Value(commandeData['id'].toString()),
              clientId: Value(commandeData['client_id'].toString()),
              reference: Value(commandeData['reference']),
              date: Value(DateTime.parse(commandeData['date'])),
              status: Value(commandeData['status']),
              total: Value(commandeData['total'].toDouble()),
              notes: Value(commandeData['notes']),
              createdAt: Value(DateTime.parse(commandeData['created_at'])),
              lastSync: Value(DateTime.now()),
            ));
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des commandes: $e');
    }
  }

  Future<void> _syncFactures() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.facturesEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'] ?? [];
        
        for (var factureData in data) {
          final existingFacture = await getFactureById(factureData['id'].toString());
          if (existingFacture == null) {
            await insertFacture(FacturesCompanion(
              factureId: Value(factureData['id'].toString()),
              clientId: Value(factureData['client_id'].toString()),
              reference: Value(factureData['reference']),
              date: Value(DateTime.parse(factureData['date'])),
              status: Value(factureData['status']),
              total: Value(factureData['total'].toDouble()),
              paid: Value(factureData['paid']?.toDouble() ?? 0.0),
              notes: Value(factureData['notes']),
              createdAt: Value(DateTime.parse(factureData['created_at'])),
              lastSync: Value(DateTime.now()),
            ));
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des factures: $e');
    }
  }

  Future<void> _syncDevis() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}${ApiConfig.devisEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'] ?? [];
        
        for (var devisData in data) {
          final existingDevis = await getDevisById(devisData['id'].toString());
          if (existingDevis == null) {
            await insertDevis(DevisCompanion(
              devisId: Value(devisData['id'].toString()),
              clientId: Value(devisData['client_id'].toString()),
              reference: Value(devisData['reference']),
              date: Value(DateTime.parse(devisData['date'])),
              status: Value(devisData['status']),
              total: Value(devisData['total'].toDouble()),
              notes: Value(devisData['notes']),
              createdAt: Value(DateTime.parse(devisData['created_at'])),
              lastSync: Value(DateTime.now()),
            ));
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des devis: $e');
    }
  }
}

// Connexion à la base de données
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'appgestion.db'));
    return NativeDatabase.createInBackground(file);
  });
}
