class ApiConfig {
  // URL de base de l'API
  static const String baseUrl = 'https://api.votre-domaine.com';
  
  // Endpoints d'authentification
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  
  // Endpoints des appels d'offre
  static const String appelsOffreEndpoint = '/appels-offre';
  static const String soumissionEndpoint = '/soumissions';
  
  // Endpoints des clients
  static const String clientsEndpoint = '/clients';
  
  // Endpoints des commandes
  static const String commandesEndpoint = '/commandes';
  
  // Endpoints des devis
  static const String devisEndpoint = '/devis';
  
  // Endpoints des factures
  static const String facturesEndpoint = '/factures';
  
  // Endpoints du stock
  static const String stockEndpoint = '/stock';
  
  // Endpoints des marches
  static const String marchesEndpoint = '/marches';
  
  // Endpoints des recouvrements
  static const String recouvrementsEndpoint = '/recouvrements';
  
  // Endpoints des relances
  static const String relancesEndpoint = '/relances';
  
  // Headers par défaut
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout pour les requêtes
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Configuration pour le développement
  static const bool isDevelopment = true;
  
  // URL de développement (pour les tests)
  static const String devBaseUrl = 'http://localhost:8000';
  static const String testBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const String mockApiUrl = 'https://mockapi.io/projects/your-project-id';
  
  // Obtenir l'URL de base selon l'environnement
  static String get baseUrlForEnvironment {
    if (isDevelopment) {
      return devBaseUrl;
    }
    return baseUrl;
  }
}

// Exemples de réponses d'API pour les tests
class ApiResponseExamples {
  // Réponse de connexion réussie
  static Map<String, dynamic> get successfulLoginResponse => {
    'success': true,
    'message': 'Connexion réussie',
    'data': {
      'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      'refresh_token': 'refresh_token_example',
      'user': {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'avatar': null,
        'created_at': '2024-01-01T00:00:00Z',
        'role': 'user'
      }
    }
  };
  
  // Réponse d'inscription réussie
  static Map<String, dynamic> get successfulRegisterResponse => {
    'success': true,
    'message': 'Compte créé avec succès',
    'data': {
      'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      'refresh_token': 'refresh_token_example',
      'user': {
        'id': 2,
        'name': 'Jane Smith',
        'email': 'jane@example.com',
        'avatar': null,
        'created_at': '2024-01-01T00:00:00Z',
        'role': 'user'
      }
    }
  };
  
  // Réponse d'erreur
  static Map<String, dynamic> get errorResponse => {
    'success': false,
    'message': 'Email ou mot de passe incorrect',
    'errors': {
      'email': ['Email invalide'],
      'password': ['Mot de passe requis']
    }
  };
  
  // Réponse de rafraîchissement de token
  static Map<String, dynamic> get refreshTokenResponse => {
    'success': true,
    'data': {
      'access_token': 'new_access_token_example',
      'refresh_token': 'new_refresh_token_example'
    }
  };
}
