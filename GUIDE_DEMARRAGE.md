# 🚀 Guide de Démarrage - AppGestion Backend

Votre application Flutter est maintenant connectée à un backend fonctionnel ! Voici comment démarrer et utiliser le système complet.

## 📋 Résumé de ce qui a été créé

✅ **Backend Node.js/Express complet** avec :
- API REST pour toutes les fonctionnalités métier
- Base de données SQLite avec schéma complet
- Authentification JWT sécurisée
- Gestion des clients, commandes, factures, articles, appels d'offre, marchés
- Middleware de sécurité (CORS, rate limiting, validation)

✅ **Configuration Flutter mise à jour** :
- Mode mock désactivé
- Services d'authentification configurés
- Écran de test backend créé
- Configuration API pointant vers le backend

## 🚀 Démarrage Rapide

### 1. Installer Node.js
Si Node.js n'est pas installé, téléchargez-le depuis [nodejs.org](https://nodejs.org/)

### 2. Démarrer le Backend
```bash
# Option 1: Script automatique (Windows)
start-backend.bat

# Option 2: Script automatique (Linux/Mac)
chmod +x start-backend.sh
./start-backend.sh

# Option 3: Manuel
cd backend
npm install
npm run init-db
npm start
```

### 3. Tester la Connexion
1. Ouvrez votre application Flutter
2. Allez dans l'écran de test backend
3. Lancez les tests de connexion

## 🔐 Utilisateurs de Test

- **Administrateur** : `admin@neo.com` / `admin123`
- **Utilisateur** : `test@example.com` / `password123`

## 📊 Fonctionnalités Disponibles

### Authentification
- Connexion/Déconnexion
- Inscription
- Rafraîchissement de token
- Gestion des sessions

### Gestion des Clients
- CRUD complet
- Recherche et filtrage
- Statistiques

### Gestion des Commandes
- Création avec articles
- Suivi des statuts
- Calcul automatique des totaux

### Gestion des Articles
- CRUD complet
- Gestion des stocks
- Alertes de rupture

### Gestion des Factures
- Génération automatique
- Suivi des paiements
- Relances

### Appels d'Offre
- Création et gestion
- Soumissions
- Attribution

### Marchés
- Suivi des contrats
- Gestion des échéances

## 🌐 URLs et Endpoints

**Backend** : `http://10.0.2.2:8000` (émulateur Android)
**API Documentation** : `http://10.0.2.2:8000/` (page d'accueil)

### Endpoints Principaux
- `POST /auth/login` - Connexion
- `GET /customers` - Liste des clients
- `GET /commande` - Liste des commandes
- `GET /article` - Liste des articles
- `GET /facture` - Liste des factures
- `GET /appels-offre` - Appels d'offre
- `GET /marches` - Marchés

## 🛠️ Dépannage

### Le backend ne démarre pas
1. Vérifiez que Node.js est installé : `node --version`
2. Vérifiez que le port 8000 est libre
3. Vérifiez les logs d'erreur dans la console

### L'app Flutter ne se connecte pas
1. Vérifiez que le backend est démarré
2. Testez l'URL : `http://10.0.2.2:8000/health`
3. Utilisez l'écran de test dans l'app Flutter

### Erreurs de base de données
1. Supprimez `backend/database.sqlite`
2. Relancez `npm run init-db`

## 📱 Configuration Flutter

L'application est configurée pour utiliser le backend :
- `lib/config/app_config.dart` : `useMockData = false`
- `lib/config/api_config.dart` : URL du backend
- `lib/services/auth_service.dart` : Service d'authentification

## 🔧 Personnalisation

### Modifier l'URL du backend
Éditez `lib/config/api_config.dart` :
```dart
static const String devBaseUrl = 'http://VOTRE_IP:8000';
```

### Ajouter de nouveaux endpoints
1. Créez la route dans `backend/routes/`
2. Ajoutez l'endpoint dans `backend/server-complete.js`
3. Créez le service Flutter correspondant

## 📈 Prochaines Étapes

1. **Testez toutes les fonctionnalités** avec les utilisateurs de test
2. **Personnalisez** les endpoints selon vos besoins
3. **Ajoutez des données** via l'interface ou directement en base
4. **Déployez** le backend sur un serveur pour la production

## 🎉 Félicitations !

Votre application de gestion est maintenant complètement fonctionnelle avec un backend robuste et sécurisé. Vous pouvez commencer à utiliser toutes les fonctionnalités métier !
