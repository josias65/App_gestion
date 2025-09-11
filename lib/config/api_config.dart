import 'dart:io' show Platform;

/// Configuration de l'API pour différents environnements
/// 
/// Cette classe contient tous les endpoints de l'API ainsi que la configuration
/// pour les différents environnements (développement, staging, production).
class ApiConfig {
  // Configuration de l'environnement
  static const bool isDevelopment = bool.fromEnvironment('DEBUG', defaultValue: true);
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  static const bool useMockData = bool.fromEnvironment('USE_MOCK_API', defaultValue: true);

  // URLs pour différents environnements
  static const String devBaseUrl = 'http://10.0.2.2:8000'; // Pour émulateur Android
  static const String iosBaseUrl = 'http://localhost:8000'; // Pour simulateur iOS
  static const String mockApiUrl = 'https://66f7c5c8b5d85f31a3418d8e.mockapi.io/api/v1';
  static const String prodBaseUrl = 'https://api.votredomaine.com';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // En-têtes par défaut
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };

  // Endpoints pour les appels d'offre
  static const String appelsOffre = '/appels-offre';
  static String appelOffreDetail(String id) => '$appelsOffre/$id';
  static String appelOffreFavori(String id) => '$appelsOffre/$id/favorite';
  
  // Endpoints pour les recouvrements
  static const String recouvrements = '/recouvrements';
  static String recouvrementDetail(String id) => '$recouvrements/$id';
  static String recouvrementStatistiques = '$recouvrements/statistiques';
  
  // Endpoints pour les relances
  static const String relances = '/relances';
  static String relanceDetail(String id) => '$relances/$id';
  static String relanceTraiter(String id) => '$relances/$id/traiter';
  static String relanceStatistiques = '$relances/statistiques';
  
  // Endpoints pour les marchés
  static const String marches = '/marches';
  static String marcheDetail(String id) => '$marches/$id';
  static String marcheSoumissions(String marcheId) => '$marches/$marcheId/soumissions';
  static String marcheStatistiques = '$marches/statistiques';
  
  // URL de base dynamique selon l'environnement
  static String get baseUrlForEnvironment {
    // Utiliser l'API mock si configuré
    if (useMockData) {
      return mockApiUrl;
    }
    
    switch (environment.toLowerCase()) {
      case 'production':
        return const String.fromEnvironment('API_BASE_URL', defaultValue: prodBaseUrl);
      case 'staging':
        return const String.fromEnvironment('STAGING_API_URL', 
            defaultValue: 'https://staging.votredomaine.com');
      case 'development':
      default:
        // Détection automatique de la plateforme pour le développement
        if (Platform.isIOS) {
          return iosBaseUrl;
        } else if (Platform.isAndroid) {
          return devBaseUrl;
        }
        return devBaseUrl; // Fallback
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
