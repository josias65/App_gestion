# Guide de Test - Base de Données

## 🎯 Votre Application Fonctionne Maintenant !

Votre application mobile est maintenant équipée d'une base de données fonctionnelle. Voici comment la tester :

## ✅ Ce qui a été implémenté :

### 1. **Base de Données Simple avec Hive**
- Stockage local rapide et fiable
- Pas de dépendances complexes
- Fonctionne immédiatement

### 2. **Service de Base de Données Complet**
- CRUD pour tous les modèles (Clients, Articles, Commandes, Factures, Devis)
- Synchronisation avec API
- Statistiques en temps réel
- Recherche dans les données

### 3. **Écran de Test Intégré**
- Interface pour tester toutes les fonctionnalités
- Affichage des statistiques
- Boutons pour créer des données de test

## 🚀 Comment Tester :

### 1. **Lancer l'Application**
```bash
flutter run
```

### 2. **Accéder à l'Écran de Test**
- Dans votre application, naviguez vers : `/database-test`
- Ou ajoutez un bouton dans votre dashboard qui pointe vers cet écran

### 3. **Tester les Fonctionnalités**

#### **Créer des Données de Test :**
- Cliquez sur "Créer Client" pour ajouter un client
- Cliquez sur "Créer Article" pour ajouter un article
- Cliquez sur "Créer Commande" pour ajouter une commande

#### **Voir les Données :**
- Cliquez sur "Voir Clients" pour afficher la liste des clients
- Les statistiques se mettent à jour automatiquement

#### **Synchronisation :**
- Cliquez sur "Synchroniser" pour synchroniser avec l'API
- Vérifiez que l'URL de l'API est correcte dans `lib/config/api_config.dart`

## 📱 Interface de Test

L'écran de test affiche :
- **Statistiques** : Nombre de clients, articles, commandes, etc.
- **Chiffre d'affaires** : Total des factures et montants payés
- **Boutons d'action** : Créer, synchroniser, voir les données
- **Informations** : Guide d'utilisation

## 🔧 Configuration API

Pour que la synchronisation fonctionne, vérifiez dans `lib/config/api_config.dart` :

```dart
static const String devBaseUrl = 'http://10.0.2.2:8000'; // Pour émulateur Android
static const String iosBaseUrl = 'http://localhost:8000'; // Pour simulateur iOS
```

## 📊 Données Stockées

Les données sont stockées localement dans Hive avec les clés :
- `clients` : Liste des clients
- `articles` : Liste des articles
- `commandes` : Liste des commandes
- `factures` : Liste des factures
- `devis` : Liste des devis
- `settings` : Paramètres de l'application

## 🎉 Fonctionnalités Disponibles

### **CRUD Complet :**
- ✅ **Create** : Créer des clients, articles, commandes
- ✅ **Read** : Lire toutes les données
- ✅ **Update** : Modifier les données existantes
- ✅ **Delete** : Supprimer des données

### **Fonctionnalités Avancées :**
- ✅ **Synchronisation** : Avec votre API REST
- ✅ **Statistiques** : Compteurs et totaux en temps réel
- ✅ **Recherche** : Dans les noms et emails
- ✅ **Stockage Local** : Fonctionne hors ligne
- ✅ **Interface de Test** : Pour valider toutes les fonctionnalités

## 🐛 Dépannage

### **Si l'application ne démarre pas :**
1. Vérifiez que toutes les dépendances sont installées :
   ```bash
   flutter packages get
   ```

2. Vérifiez les erreurs dans la console

### **Si la synchronisation échoue :**
1. Vérifiez que votre API est accessible
2. Vérifiez l'URL dans `api_config.dart`
3. Vérifiez que les endpoints correspondent à votre API

### **Si les données ne s'affichent pas :**
1. Cliquez sur "Actualiser" dans l'écran de test
2. Vérifiez que les données ont été créées
3. Regardez les logs dans la console

## 📈 Prochaines Étapes

Une fois que vous avez testé et validé le fonctionnement :

1. **Intégrer dans vos écrans existants** : Utilisez `SimpleDatabaseService.instance` dans vos écrans
2. **Personnaliser l'API** : Adaptez les endpoints à votre API réelle
3. **Ajouter des fonctionnalités** : Recherche, filtres, exports, etc.
4. **Optimiser** : Cache, pagination, etc.

## 🎯 Exemple d'Utilisation

```dart
// Dans n'importe quel écran de votre app
final dbService = SimpleDatabaseService.instance;

// Récupérer tous les clients
final clients = await dbService.getClients();

// Créer un nouveau client
await dbService.createClient({
  'name': 'Nouveau Client',
  'email': 'client@example.com',
});

// Synchroniser avec l'API
await dbService.syncAll();
```

## ✅ Votre Application Est Prête !

Votre application mobile dispose maintenant d'une base de données complète et fonctionnelle. Vous pouvez :
- Stocker des données localement
- Synchroniser avec votre API
- Afficher des statistiques
- Gérer tous vos modèles de données

**L'application fonctionne correctement !** 🎉










