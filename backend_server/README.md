# Backend Simple pour AppGestion

Ce backend simple utilise JSON Server avec authentification JWT pour fournir une API REST complète pour l'application Flutter.

## 🚀 Démarrage rapide

### 1. Installation des dépendances
```bash
cd backend_server
npm install
```

### 2. Démarrage du serveur
```bash
# Mode développement (redémarre automatiquement)
npm run dev

# ou Mode production
npm start
```

Le serveur sera disponible sur `http://localhost:8000`

## 📊 Données de test

### Comptes utilisateur prédéfinis :
- **Admin** : `admin@appgestion.com` / `password`
- **Utilisateur** : `user@test.com` / `password`

## 🔌 Endpoints disponibles

### Authentification
- `POST /auth/login` - Connexion
- `POST /auth/register` - Inscription
- `POST /auth/refresh` - Rafraîchir le token
- `POST /auth/logout` - Déconnexion
- `GET /auth/me` - Informations utilisateur

### Routes CRUD (authentifiées)
- `GET|POST /customers` - Gestion des clients
- `GET|POST /article` - Gestion des articles
- `GET|POST /commande` - Gestion des commandes
- `GET|POST /devis` - Gestion des devis
- `GET|POST /facture` - Gestion des factures
- `GET|POST /marches` - Gestion des marchés
- `GET|POST /appels-offre` - Gestion des appels d'offre
- `GET|POST /recouvrements` - Gestion des recouvrements
- `GET|POST /relances` - Gestion des relances

### Utilitaires
- `GET /health` - État du serveur

## 🔐 Authentification

Le serveur utilise JWT (JSON Web Tokens) pour l'authentification :
- Token d'accès : valide 1 heure
- Token de rafraîchissement : valide 7 jours

## 📝 Format des réponses

### Succès
```json
{
  "success": true,
  "message": "Action réussie",
  "data": { ... }
}
```

### Erreur
```json
{
  "success": false,
  "message": "Description de l'erreur",
  "errors": { ... }
}
```

## 🛠 Configuration

Le fichier `db.json` contient toutes les données. Vous pouvez le modifier pour ajouter/supprimer des données de test.

## 📱 Intégration avec Flutter

Votre application Flutter est déjà configurée pour utiliser ce backend. Assurez-vous que l'URL dans `lib/config/api_config.dart` correspond à `http://localhost:8000` (ou l'URL de votre serveur).

## 🐛 Logs

Le serveur affiche automatiquement les logs de toutes les requêtes reçues dans la console.