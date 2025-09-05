# Backend AppGestion

Backend API pour l'application de gestion Flutter.

## 🚀 Installation et démarrage

### Prérequis
- Node.js (version 16 ou supérieure)
- npm ou yarn

### Installation
```bash
# Installer les dépendances
npm install

# Initialiser la base de données
npm run init-db

# Démarrer le serveur
npm start
```

### Développement
```bash
# Démarrer en mode développement avec rechargement automatique
npm run dev
```

## 📡 Endpoints API

### Authentification (`/auth`)
- `POST /auth/login` - Connexion
- `POST /auth/register` - Inscription
- `POST /auth/refresh` - Rafraîchir le token
- `POST /auth/logout` - Déconnexion
- `GET /auth/profile` - Profil utilisateur

### Clients (`/customers`)
- `GET /customers` - Liste des clients
- `GET /customers/:id` - Détails d'un client
- `POST /customers` - Créer un client
- `PUT /customers/:id` - Modifier un client
- `DELETE /customers/:id` - Supprimer un client
- `GET /customers/stats/overview` - Statistiques des clients

### Commandes (`/commande`)
- `GET /commande` - Liste des commandes
- `GET /commande/:id` - Détails d'une commande
- `POST /commande` - Créer une commande
- `PUT /commande/:id` - Modifier une commande
- `DELETE /commande/:id` - Supprimer une commande
- `GET /commande/stats/overview` - Statistiques des commandes

### Articles (`/article`)
- `GET /article` - Liste des articles
- `GET /article/:id` - Détails d'un article
- `POST /article` - Créer un article
- `PUT /article/:id` - Modifier un article
- `DELETE /article/:id` - Supprimer un article
- `PATCH /article/:id/stock` - Mettre à jour le stock
- `GET /article/low-stock/items` - Articles en rupture de stock

### Factures (`/facture`)
- `GET /facture` - Liste des factures
- `GET /facture/:id` - Détails d'une facture
- `POST /facture` - Créer une facture
- `PUT /facture/:id` - Modifier une facture
- `DELETE /facture/:id` - Supprimer une facture
- `PATCH /facture/:id/pay` - Marquer comme payée
- `GET /facture/stats/overview` - Statistiques des factures

### Appels d'offre (`/appels-offre`)
- `GET /appels-offre` - Liste des appels d'offre
- `GET /appels-offre/:id` - Détails d'un appel d'offre
- `POST /appels-offre` - Créer un appel d'offre
- `PUT /appels-offre/:id` - Modifier un appel d'offre
- `DELETE /appels-offre/:id` - Supprimer un appel d'offre
- `POST /appels-offre/:id/soumissions` - Soumettre une offre
- `GET /appels-offre/stats/overview` - Statistiques des appels d'offre

### Marchés (`/marches`)
- `GET /marches` - Liste des marchés
- `GET /marches/:id` - Détails d'un marché
- `POST /marches` - Créer un marché
- `PUT /marches/:id` - Modifier un marché
- `DELETE /marches/:id` - Supprimer un marché
- `GET /marches/stats/overview` - Statistiques des marchés

## 🔐 Authentification

L'API utilise JWT (JSON Web Tokens) pour l'authentification. Incluez le token dans l'en-tête `Authorization` :

```
Authorization: Bearer <votre_token>
```

## 📊 Base de données

La base de données SQLite est créée automatiquement au démarrage. Le fichier `database.sqlite` contient toutes les tables nécessaires.

### Utilisateurs par défaut
- **Admin** : `admin@neo.com` / `admin123`
- **Test** : `test@example.com` / `password123`

## 🌐 Configuration

Le serveur démarre sur le port 8000 par défaut. Pour Flutter :
- **Émulateur Android** : `http://10.0.2.2:8000`
- **Simulateur iOS** : `http://localhost:8000`
- **Appareil physique** : `http://<IP_LOCALE>:8000`

## 🔧 Variables d'environnement

Créez un fichier `.env` avec :
```
PORT=8000
NODE_ENV=development
JWT_SECRET=votre_secret_jwt_tres_securise
JWT_EXPIRES_IN=24h
REFRESH_TOKEN_EXPIRES_IN=7d
DB_PATH=./database.sqlite
```

## 📝 Format des réponses

Toutes les réponses suivent ce format :
```json
{
  "success": true,
  "message": "Message de succès",
  "data": { ... }
}
```

En cas d'erreur :
```json
{
  "success": false,
  "message": "Message d'erreur",
  "errors": [ ... ]
}
```

## 🛡️ Sécurité

- Rate limiting (100 requêtes par 15 minutes)
- Validation des données d'entrée
- Protection CORS
- Headers de sécurité avec Helmet
- Hachage des mots de passe avec bcrypt

## 📱 Intégration Flutter

Mettez à jour votre configuration Flutter dans `lib/config/api_config.dart` :

```dart
static const String devBaseUrl = 'http://10.0.2.2:8000';
```

Et dans `lib/config/app_config.dart` :
```dart
static const bool useMockData = false;
```
