# 🚀 Démarrage Rapide - AppGestion avec Backend

## ✅ Configuration Terminée !

Votre application Flutter est maintenant connectée à un backend JSON Server fonctionnel avec authentification JWT.

## 🎯 Pour démarrer immédiatement :

### 1. Démarrer le backend (Terminal 1)
```bash
cd backend_server
npm run dev
```
Le serveur sera disponible sur `http://localhost:8000`

### 2. Lancer l'application Flutter (Terminal 2)
```bash
flutter run
```

### 3. Se connecter dans l'app
Utilisez un de ces comptes :
- **Admin** : `admin@appgestion.com` / `password`
- **User** : `user@test.com` / `password`

## 🧪 Tester le backend
```bash
# Test rapide
./test_backend.sh

# Test complet
./test_full_api.sh
```

## 📁 Fichiers créés

### Backend
- `/backend_server/` - Serveur JSON complet
- `/backend_server/server.js` - Serveur principal avec JWT
- `/backend_server/db.json` - Base de données avec données de test
- `/backend_server/package.json` - Configuration npm
- `./start.sh` / `./start.bat` - Scripts de démarrage

### Configuration
- `lib/config/api_config.dart` - Modifiée pour pointer vers localhost:8000
- `BACKEND_SETUP.md` - Documentation complète
- `test_backend.sh` - Script de test simple
- `test_full_api.sh` - Script de test complet

## 🌟 Fonctionnalités disponibles

### ✅ Authentification complète
- Connexion/déconnexion
- Inscription de nouveaux utilisateurs
- Tokens JWT avec refresh automatique
- Sessions persistantes

### ✅ APIs CRUD pour tous les modules
- **Clients** (`/customers`)
- **Articles** (`/article`)
- **Commandes** (`/commande`)
- **Devis** (`/devis`)
- **Factures** (`/facture`)
- **Marchés** (`/marches`)
- **Appels d'offre** (`/appels-offre`)
- **Recouvrements** (`/recouvrements`)
- **Relances** (`/relances`)

### ✅ Sécurité
- Tous les endpoints sont protégés par JWT
- Mots de passe hashés avec bcrypt
- Headers CORS configurés
- Gestion d'erreurs complète

## 🎊 Résultat des tests

Tous les tests passent avec succès :
- ✅ Backend: Fonctionnel
- ✅ Authentification: Opérationnelle
- ✅ Endpoints: Protégés et accessibles
- ✅ CRUD: Opérationnel

---

## 🚨 Besoin d'aide ?

### Le serveur ne démarre pas ?
```bash
cd backend_server
node --version  # Doit afficher une version
npm install     # Réinstaller les dépendances
npm run dev     # Redémarrer
```

### Erreur de connexion dans Flutter ?
- Vérifiez que le backend tourne sur port 8000
- Pour émulateur Android, l'URL est `10.0.2.2:8000`
- Pour simulateur iOS, l'URL est `localhost:8000`

### Problème d'authentification ?
- Comptes de test : `admin@appgestion.com` / `password`
- Token valide 1 heure, refresh automatique

---

🎉 **Félicitations ! Votre application est maintenant connectée à un backend fonctionnel !**

Vous pouvez maintenant développer et tester toutes les fonctionnalités de gestion de données en temps réel.