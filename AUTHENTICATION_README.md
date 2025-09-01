# Système d'Authentification API

Ce document explique comment utiliser le système d'authentification intégré dans l'application Flutter.

## 📁 Structure des fichiers

```
lib/
├── services/
│   ├── auth_service.dart      # Service d'authentification principal
│   └── api_service.dart       # Service API générique
├── providers/
│   └── auth_provider.dart     # Provider pour l'état d'authentification
├── config/
│   └── api_config.dart        # Configuration de l'API
└── login/
    ├── login.dart             # Écran de connexion
    └── register.dart          # Écran d'inscription
```

## 🔧 Configuration

### 1. Configuration de l'API

Modifiez le fichier `lib/config/api_config.dart` pour configurer votre API :

```dart
class ApiConfig {
  // Remplacez par l'URL de votre API
  static const String baseUrl = 'https://votre-api.com';
  
  // Pour le développement local
  static const String devBaseUrl = 'http://localhost:8000';
  
  // Changez selon votre environnement
  static const bool isDevelopment = true;
}
```

### 2. Endpoints requis

Votre API backend doit implémenter les endpoints suivants :

#### Authentification
- `POST /auth/login` - Connexion utilisateur
- `POST /auth/register` - Inscription utilisateur
- `POST /auth/refresh` - Rafraîchissement du token
- `POST /auth/logout` - Déconnexion

#### Format des réponses

**Connexion réussie :**
```json
{
  "success": true,
  "message": "Connexion réussie",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "refresh_token_example",
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "avatar": null,
      "created_at": "2024-01-01T00:00:00Z",
      "role": "user"
    }
  }
}
```

**Erreur :**
```json
{
  "success": false,
  "message": "Email ou mot de passe incorrect",
  "errors": {
    "email": ["Email invalide"],
    "password": ["Mot de passe requis"]
  }
}
```

## 🚀 Utilisation

### 1. Connexion utilisateur

```dart
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

// Dans votre widget
final authProvider = Provider.of<AuthProvider>(context, listen: false);

// Connexion
final success = await authProvider.login(email, password);
if (success) {
  // Navigation vers le dashboard
  Navigator.pushReplacementNamed(context, '/dashboard');
} else {
  // Afficher l'erreur
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(authProvider.error ?? 'Erreur de connexion')),
  );
}
```

### 2. Inscription utilisateur

```dart
final success = await authProvider.register(name, email, password);
if (success) {
  // Navigation vers le dashboard
  Navigator.pushReplacementNamed(context, '/dashboard');
} else {
  // Afficher l'erreur
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(authProvider.error ?? 'Erreur d\'inscription')),
  );
}
```

### 3. Déconnexion

```dart
await authProvider.logout();
// L'utilisateur sera automatiquement redirigé vers l'écran de connexion
```

### 4. Vérifier l'état d'authentification

```dart
// Dans un widget
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (authProvider.isAuthenticated) {
      return DashboardScreen();
    } else {
      return LoginScreen();
    }
  },
)
```

### 5. Accéder aux données utilisateur

```dart
final user = authProvider.user;
if (user != null) {
  print('Nom: ${user['name']}');
  print('Email: ${user['email']}');
}
```

## 🔒 Sécurité

### Gestion des tokens

- Les tokens sont automatiquement stockés dans `SharedPreferences`
- Le token d'accès est inclus dans toutes les requêtes authentifiées
- Le token de rafraîchissement est utilisé automatiquement quand le token d'accès expire
- Les tokens sont supprimés lors de la déconnexion

### Headers d'authentification

```dart
// Automatiquement ajouté par le service
Authorization: Bearer <access_token>
```

## 📡 Utilisation du service API

### Requêtes authentifiées

```dart
import 'services/api_service.dart';

final apiService = ApiService();

// GET
final response = await apiService.get('/users/profile');
if (response.success) {
  final userData = response.data;
  // Traiter les données
} else {
  print('Erreur: ${response.error}');
}

// POST
final response = await apiService.post(
  '/users',
  body: {
    'name': 'John Doe',
    'email': 'john@example.com',
  },
);

// PUT
final response = await apiService.put(
  '/users/1',
  body: {
    'name': 'Jane Doe',
  },
);

// DELETE
final response = await apiService.delete('/users/1');
```

### Upload de fichiers

```dart
final response = await apiService.uploadFile(
  '/upload',
  '/path/to/file.jpg',
  fields: {
    'description': 'Photo de profil',
  },
);
```

## 🧪 Tests

### Mode développement

Pour tester sans API réelle, vous pouvez :

1. Modifier `ApiConfig.isDevelopment = true`
2. Utiliser un serveur local (ex: `http://localhost:8000`)
3. Ou utiliser un service de mock API comme JSONPlaceholder

### Exemple avec JSONPlaceholder

```dart
// Dans api_config.dart
static const String testBaseUrl = 'https://jsonplaceholder.typicode.com';

// Pour les tests
static String get baseUrlForEnvironment {
  if (isDevelopment) {
    return testBaseUrl; // Utiliser JSONPlaceholder pour les tests
  }
  return baseUrl;
}
```

## 🔧 Personnalisation

### Ajouter des champs personnalisés

Modifiez le modèle `User` dans `auth_service.dart` :

```dart
class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final String? role;        // Ajouté
  final String? phone;       // Ajouté
  final String? company;     // Ajouté

  // ... reste du code
}
```

### Ajouter des validations

Dans `login.dart` ou `register.dart`, ajoutez vos validations :

```dart
String? _validateCustomField(String? value) {
  if (value == null || value.isEmpty) {
    return 'Ce champ est requis';
  }
  // Autres validations...
  return null;
}
```

## 🐛 Dépannage

### Erreurs courantes

1. **Erreur de connexion réseau**
   - Vérifiez l'URL de l'API
   - Vérifiez votre connexion internet
   - Vérifiez que le serveur est accessible

2. **Token expiré**
   - Le système tente automatiquement de rafraîchir le token
   - Si cela échoue, l'utilisateur est déconnecté

3. **Erreur 401**
   - Vérifiez que les credentials sont corrects
   - Vérifiez que l'API accepte les tokens Bearer

### Logs de débogage

Activez les logs dans `api_service.dart` :

```dart
// Ajouter dans les méthodes
print('Request: ${request.method} ${request.url}');
print('Response: ${response.statusCode} ${response.body}');
```

## 📱 Intégration avec l'application

Le système d'authentification est déjà intégré dans :

- `main.dart` - Provider configuré
- `login.dart` - Écran de connexion
- `register.dart` - Écran d'inscription
- `dashboard_screen.dart` - Redirection automatique

Pour ajouter l'authentification à d'autres écrans, utilisez le `Consumer<AuthProvider>`.



















