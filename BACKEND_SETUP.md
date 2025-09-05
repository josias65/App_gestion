# 🚀 Configuration Backend - AppGestion

Votre application est maintenant connectée à un backend JSON Server fonctionnel !

## ✅ Ce qui a été configuré

### 1. Serveur Backend JSON Server
- **Location**: `/workspace/backend_server/`
- **Port**: `8000`
- **Type**: API REST avec authentification JWT
- **Base de données**: JSON (fichier `db.json`)

### 2. Endpoints disponibles
- **Authentification**: `/auth/login`, `/auth/register`, `/auth/refresh`, `/auth/logout`
- **Santé**: `/health`
- **CRUD**: `/customers`, `/article`, `/commande`, `/devis`, `/facture`, etc.

### 3. Configuration API Flutter
- L'application pointe maintenant vers `http://localhost:8000`
- Configuré dans `lib/config/api_config.dart`

## 🔧 Comment utiliser

### Démarrage du serveur
```bash
# Option 1: Script automatique
cd backend_server && ./start.sh

# Option 2: Manuel
cd backend_server && npm run dev
```

### Comptes de test
- **Admin**: `admin@appgestion.com` / `password`
- **Utilisateur**: `user@test.com` / `password`

### Test de connectivité
```bash
# Tester le backend
./test_backend.sh

# Ou manuellement
curl http://localhost:8000/health
```

## 📱 Utilisation dans l'application Flutter

### 1. Lancer le backend
```bash
cd backend_server
npm run dev
```

### 2. Lancer l'application Flutter
```bash
flutter run
```

### 3. Se connecter
Utilisez les comptes de test mentionnés ci-dessus dans l'application.

## 🔍 Fonctionnalités disponibles

### ✅ Authentification
- Connexion/déconnexion
- Inscription
- Rafraîchissement automatique du token
- Gestion des sessions

### ✅ Gestion des données
- **Clients**: CRUD complet
- **Articles**: CRUD complet  
- **Commandes**: CRUD complet
- **Devis**: CRUD complet
- **Factures**: CRUD complet
- **Marchés**: CRUD complet
- **Appels d'offre**: CRUD complet
- **Recouvrements**: CRUD complet
- **Relances**: CRUD complet

## 🛠 Structure des fichiers backend

```
backend_server/
├── package.json          # Dépendances npm
├── server.js             # Serveur principal
├── db.json               # Base de données JSON
├── README.md             # Documentation
├── start.sh              # Script de démarrage Linux/macOS
└── start.bat             # Script de démarrage Windows
```

## 🔒 Sécurité

- **JWT**: Authentification par tokens
- **CORS**: Configuré pour accepter les requêtes Flutter
- **Hachage**: Mots de passe hashés avec bcrypt
- **Headers**: Authentification Bearer automatique

## 🧪 Tests et développement

### Tester l'API manuellement
```bash
# Connexion
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@appgestion.com","password":"password"}'

# Récupérer les clients (avec token)
curl -X GET http://localhost:8000/customers \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Données de test
Le fichier `db.json` contient des données d'exemple pour tous les types d'entités. Vous pouvez les modifier selon vos besoins.

## 🚨 Dépannage

### Le serveur ne démarre pas
```bash
# Vérifier Node.js
node --version
npm --version

# Réinstaller les dépendances
rm -rf node_modules package-lock.json
npm install
```

### Erreur de connexion depuis Flutter
- Vérifiez que le serveur backend est démarré
- Vérifiez l'URL dans `api_config.dart`
- Pour émulateur Android, utilisez `10.0.2.2:8000` au lieu de `localhost:8000`

### Problèmes d'authentification
- Vérifiez les credentials dans `db.json`
- Le mot de passe par défaut est `password` pour tous les comptes de test

## 📈 Prochaines étapes

1. **Production**: Remplacez JSON Server par une vraie base de données (PostgreSQL, MySQL, etc.)
2. **Déploiement**: Hébergez le backend sur un service cloud (Heroku, Vercel, etc.)
3. **Sécurité avancée**: Implémentez des validations plus strictes
4. **Monitoring**: Ajoutez des logs et métriques de performance

---

🎉 **Votre application est maintenant connectée à un backend fonctionnel !**

Vous pouvez commencer à tester toutes les fonctionnalités d'authentification et de gestion des données.