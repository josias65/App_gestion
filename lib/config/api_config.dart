class ApiConfig {
  // Configuration de l'environnement
  static const bool isDevelopment = true;
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

  // URLs pour différents environnements
  static const String devBaseUrl = 'http://10.0.2.2:8000'; // Pour émulateur Android
  static const String iosBaseUrl = 'http://localhost:8000'; // Pour simulateur iOS
  static const String mockApiUrl = 'https://66f7c5c8b5d85f31a3418d8e.mockapi.io/api/v1';
  static const String prodBaseUrl = 'https://api.votredomaine.com'; // À remplacer par votre URL de production
  
  // URL de base dynamique selon l'environnement
  static String get baseUrlForEnvironment {
    switch (environment) {
      case 'production':
        return prodBaseUrl;
      case 'staging':
        return 'https://staging.votredomaine.com'; // URL de staging si nécessaire
      case 'mock':
        return mockApiUrl;
      case 'development':
      default:
        // Pour le développement, on utilise l'URL de développement
        // Note: Pour iOS, vous devrez peut-être utiliser iosBaseUrl
        return devBaseUrl;
    }
  }

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
  static const String clientsEndpoint = '/customers';
  static const String clientsStatsEndpoint = '/customers/stats';

  // Endpoints des commandes
  static const String commandesEndpoint = '/commande';

  // Endpoints des devis
  static const String devisEndpoint = '/devis';

  // Endpoints des factures
  static const String facturesEndpoint = '/facture';
  static const String facturesAcompteEndpoint = '/facture/acompte';

  // Endpoints des articles
  static const String articlesEndpoint = '/article';
  
  // Endpoints des proformas
  static const String proformasEndpoint = '/proforma';
  
  // Endpoints des livraisons
  static const String livraisonsEndpoint = '/livraison';

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
        'role': 'user',
      },
    },
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
        'role': 'user',
      },
    },
  };

  // Réponse d'erreur
  static Map<String, dynamic> get errorResponse => {
    'success': false,
    'message': 'Email ou mot de passe incorrect',
    'errors': {
      'email': ['Email invalide'],
      'password': ['Mot de passe requis'],
    },
  };

  // Réponse de rafraîchissement de token
  static Map<String, dynamic> get refreshTokenResponse => {
    'success': true,
    'data': {
      'access_token': 'new_access_token_example',
      'refresh_token': 'new_refresh_token_example',
    },
  };
}
