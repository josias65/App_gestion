# Base de Données - Application de Gestion

## Vue d'ensemble

Cette application utilise un système de base de données hybride qui combine :
- **SQLite local** (via Drift) pour le stockage local rapide
- **API REST** pour la synchronisation avec le serveur
- **Hive** pour le cache et les paramètres
- **Synchronisation automatique** en arrière-plan

## Architecture

### 1. Base de Données Locale (SQLite + Drift)
- **Fichier** : `lib/database/database_service.dart`
- **Tables** : Users, Clients, Articles, Commandes, Factures, Devis
- **Avantages** : Accès rapide, fonctionnement hors ligne, requêtes SQL

### 2. Gestionnaire de Base de Données
- **Fichier** : `lib/database/database_manager.dart`
- **Fonctions** : Initialisation, synchronisation, cache, paramètres
- **Méthodes utilitaires** : Recherche, statistiques, nettoyage

### 3. Service de Synchronisation
- **Fichier** : `lib/database/sync_service.dart`
- **Fonctions** : Synchronisation automatique, gestion de la connectivité
- **Fréquence** : Toutes les 15 minutes + synchronisation immédiate lors de la reconnexion

### 4. Service Unifié
- **Fichier** : `lib/services/unified_database_service.dart`
- **Fonctions** : Interface unique pour toutes les opérations CRUD
- **Gestion** : Mode hors ligne, synchronisation différée

## Installation et Configuration

### 1. Dépendances
Les dépendances suivantes sont déjà ajoutées dans `pubspec.yaml` :
```yaml
dependencies:
  drift: ^2.14.1
  drift_flutter: ^0.1.0
  sqflite: ^2.3.0
  connectivity_plus: ^5.0.2

dev_dependencies:
  drift_dev: ^2.14.1
  build_runner: ^2.4.7
```

### 2. Génération du Code
Exécutez la commande suivante pour générer le code Drift :
```bash
flutter packages pub run build_runner build
```

### 3. Initialisation
La base de données est automatiquement initialisée dans `main.dart` :
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser la base de données
  await DatabaseManager.initialize();
  
  // Initialiser le service de synchronisation
  await SyncService.initialize();
  
  runApp(MyApp());
}
```

## Utilisation

### 1. Service Unifié
```dart
final dbService = UnifiedDatabaseService.instance;

// Récupérer des clients
final clients = await dbService.getClients();

// Créer un client
final success = await dbService.createClient({
  'name': 'John Doe',
  'email': 'john@example.com',
  'phone': '+1234567890',
});

// Synchroniser
await dbService.syncAll();
```

### 2. Accès Direct à la Base
```dart
// Récupérer tous les clients
final clients = await DatabaseManager.database.getAllClients();

// Rechercher des clients
final results = await DatabaseManager.searchClients('John');

// Obtenir des statistiques
final stats = await DatabaseManager.getStatistics();
```

### 3. Gestion Hors Ligne
```dart
// Vérifier le statut de connexion
if (SyncService.isOnline) {
  // Opérations en ligne
} else {
  // Mode hors ligne - données stockées localement
}

// Synchronisation forcée
await SyncService.forceSync();
```

## Fonctionnalités

### 1. Synchronisation Automatique
- **Fréquence** : Toutes les 15 minutes
- **Déclenchement** : Reconnexion internet
- **Gestion d'erreurs** : Stockage des erreurs pour retry

### 2. Mode Hors Ligne
- **Stockage local** : Toutes les données sont disponibles hors ligne
- **Synchronisation différée** : Les modifications sont synchronisées lors de la reconnexion
- **Indicateurs visuels** : Statut de connexion et synchronisation

### 3. Cache et Performance
- **Cache intelligent** : Données fréquemment utilisées mises en cache
- **Expiration** : Cache avec durée de vie configurable
- **Nettoyage automatique** : Suppression des données expirées

### 4. Recherche et Statistiques
- **Recherche textuelle** : Dans les noms, emails, descriptions
- **Statistiques en temps réel** : Compteurs, totaux, montants
- **Filtrage** : Par statut, date, catégorie

## Widgets d'Interface

### 1. SyncStatusWidget
Affiche le statut de connexion et de synchronisation :
```dart
SyncStatusWidget(showDetails: true)
```

### 2. SyncButton
Bouton de synchronisation avec indicateur de statut :
```dart
SyncButton(
  isOnline: dbService.isOnline,
  isSyncing: dbService.isSyncing,
  onPressed: () => dbService.syncAll(),
)
```

## Configuration API

### 1. URLs de Base
Configurez les URLs dans `lib/config/api_config.dart` :
```dart
static const String devBaseUrl = 'http://10.0.2.2:8000';
static const String prodBaseUrl = 'https://api.votredomaine.com';
```

### 2. Endpoints
Tous les endpoints sont définis dans `ApiConfig` :
- `/customers` - Clients
- `/article` - Articles
- `/commande` - Commandes
- `/facture` - Factures
- `/devis` - Devis

## Maintenance

### 1. Nettoyage
```dart
// Nettoyer le cache expiré
await DatabaseManager.cleanup();

// Effacer les erreurs de synchronisation
await DatabaseManager.clearSyncErrors();
```

### 2. Fermeture
```dart
// Fermer les connexions (à la fermeture de l'app)
await DatabaseManager.close();
```

## Dépannage

### 1. Erreurs de Synchronisation
- Vérifiez la connectivité internet
- Consultez les erreurs stockées via `DatabaseManager.getSyncErrors()`
- Utilisez la synchronisation forcée : `SyncService.forceSync()`

### 2. Problèmes de Base de Données
- Vérifiez que `DatabaseManager.initialize()` est appelé
- Regardez les logs de la console pour les erreurs
- Utilisez l'écran de test : `DatabaseTestScreen`

### 3. Performance
- Le cache est automatiquement géré
- Utilisez `forceRefresh: true` pour forcer la synchronisation
- Évitez les requêtes trop fréquentes

## Écran de Test

Un écran de test est disponible pour tester toutes les fonctionnalités :
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DatabaseTestScreen()),
);
```

Cet écran permet de :
- Voir le statut de connexion
- Afficher les statistiques
- Tester la synchronisation
- Créer des données de test
- Voir les erreurs de synchronisation


