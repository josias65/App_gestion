# Configuration Backend AppGestion

## 🚀 Démarrage Rapide

### 1. Installation des dépendances
```bash
cd backend
npm install
```

### 2. Initialisation de la base de données
```bash
npm run init-db
```

### 3. Démarrage du serveur
```bash
npm start
```

## 📱 Configuration Flutter

L'application Flutter est déjà configurée pour utiliser le backend :
- URL: `http://10.0.2.2:8000` (émulateur Android)
- Mode mock désactivé dans `lib/config/app_config.dart`
- Services d'authentification prêts

## 🔐 Utilisateurs de test

- **Admin**: `admin@neo.com` / `admin123`
- **Utilisateur**: `test@example.com` / `password123`

## 🧪 Test de connexion

1. Démarrez le backend
2. Ouvrez l'application Flutter
3. Allez dans l'écran de test backend
4. Lancez les tests de connexion

## 📊 Endpoints disponibles

- `/auth` - Authentification
- `/customers` - Gestion des clients
- `/commande` - Gestion des commandes
- `/article` - Gestion des articles
- `/facture` - Gestion des factures
- `/appels-offre` - Appels d'offre
- `/marches` - Marchés

## 🛠️ Dépannage

### Le serveur ne démarre pas
- Vérifiez que Node.js est installé
- Vérifiez que le port 8000 est libre
- Vérifiez les logs d'erreur

### L'application Flutter ne se connecte pas
- Vérifiez que le backend est démarré
- Vérifiez l'URL dans la configuration
- Testez avec l'écran de test backend

### Erreurs de base de données
- Supprimez `backend/database.sqlite`
- Relancez `npm run init-db`
