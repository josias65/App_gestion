# 🚀 Guide de Démarrage Simple - AppGestion

## ✅ **Votre application est maintenant prête !**

---

## 🔧 **Étape 1 : Démarrer le Backend**

**Option A : Script automatique (recommandé)**
```bash
# Double-cliquez sur ce fichier :
setup-appel-offre.bat
```

**Option B : Manuel**
```bash
# Ouvrir PowerShell en tant qu'administrateur
# Aller dans le dossier de votre projet
cd C:\Users\josia\Desktop\appgestion

# Démarrer le backend
cd backend
npm start
```

**✅ Vérification :** Le serveur doit afficher :
```
🚀 Serveur AppGestion démarré sur le port 8000
✅ Base de données connectée
✅ Routes API configurées
```

---

## 📱 **Étape 2 : Lancer l'Application Flutter**

**Ouvrir un nouveau terminal et exécuter :**
```bash
# Aller dans le dossier principal
cd C:\Users\josia\Desktop\appgestion

# Lancer l'application Flutter
flutter run
```

**✅ Vérification :** L'application doit se lancer sur votre émulateur/appareil.

---

## 🧪 **Étape 3 : Tester les Nouvelles Fonctionnalités**

### **3.1 Se connecter**
- **Email :** `admin@neo.com`
- **Mot de passe :** `admin123`

### **3.2 Accéder aux tests**
1. Aller dans **Menu > Test Appels d'Offre**
2. Tester les fonctionnalités dans l'onglet **"Tests"**

### **3.3 Tester les appels d'offre**
1. Aller dans **Menu > Appels d'Offres**
2. Cliquer sur **"Nouvel appel d'offre"**
3. Remplir le formulaire et créer

---

## 🎯 **Fonctionnalités à Tester**

### **✅ Appels d'Offre**
- Créer un nouvel appel d'offre
- Modifier un appel d'offre existant
- Supprimer un appel d'offre
- Marquer en favori

### **✅ Documents**
- Uploader un fichier PDF
- Télécharger un document
- Supprimer un document

### **✅ Commentaires**
- Ajouter un commentaire
- Voir l'historique des commentaires

### **✅ Soumissions**
- Soumettre une offre
- Évaluer une soumission
- Voir les scores

### **✅ Statistiques**
- Visualiser les analytics
- Exporter les données

---

## 🔍 **Vérifications Importantes**

### **Backend (Port 8000)**
```bash
# Tester l'API
curl http://localhost:8000

# Tester les appels d'offre
curl http://localhost:8000/appels-offre
```

### **Flutter App**
- L'application se lance sans erreur
- La connexion fonctionne
- Les menus sont accessibles

---

## 🚨 **Résolution de Problèmes**

### **Problème : Backend ne démarre pas**
```bash
# Vérifier Node.js
node --version

# Réinstaller les dépendances
cd backend
npm install
npm start
```

### **Problème : Flutter ne se connecte pas**
1. Vérifier que le backend est démarré sur le port 8000
2. Vérifier la configuration dans `lib/config/api_config.dart`
3. Utiliser l'écran de test backend

### **Problème : Erreurs de base de données**
```bash
# Réinitialiser la base
cd backend
node scripts/enhance-database.js
node scripts/init-database.js
```

### **Problème : PowerShell bloque npm**
```bash
# Exécuter en tant qu'administrateur
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📊 **URLs Importantes**

- **Backend API :** http://localhost:8000
- **Test Backend :** http://localhost:8000/health
- **Appels d'Offre :** http://localhost:8000/appels-offre

---

## 🎉 **Félicitations !**

Votre application AppGestion est maintenant équipée d'un système complet de gestion des appels d'offre avec :

- ✅ **API Backend complète**
- ✅ **Interface Flutter moderne**
- ✅ **Gestion des documents**
- ✅ **Système de commentaires**
- ✅ **Analytics avancés**
- ✅ **Évaluation des soumissions**
- ✅ **Export de données**

**Votre application est prête pour un usage professionnel !** 🚀

---

## 📞 **Support**

Si vous rencontrez des problèmes :
1. Vérifiez les logs du backend dans le terminal
2. Utilisez l'écran de test intégré
3. Consultez le guide complet : `GUIDE_APPELS_OFFRE_AVANCES.md`

**Bon usage de votre nouvelle application !** 🎯
