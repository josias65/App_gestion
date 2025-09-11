import 'package:flutter/foundation.dart';

/// Configuration globale de l'application
class AppConfig {
  // Configuration de l'environnement
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  // Configuration des fonctionnalités
  static const bool enableMockData = bool.fromEnvironment('USE_MOCK_API', defaultValue: true);
  static const bool enableOfflineMode = true;
  static const bool enableSync = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  
  // Configuration de l'interface
  static const bool enableDarkMode = true;
  static const bool enableAnimations = true;
  static const bool enableHapticFeedback = true;
  
  // Configuration de la base de données
  static const bool enableLocalDatabase = true;
  static const bool enableDataSync = true;
  static const Duration syncInterval = Duration(minutes: 5);
  
  // Configuration de l'API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Configuration de la sécurité
  static const bool enableBiometricAuth = false;
  static const bool enableAutoLock = true;
  static const Duration autoLockTimeout = Duration(minutes: 15);
  
  // Configuration des notifications
  static const bool enablePushNotifications = false;
  static const bool enableEmailNotifications = false;
  
  // Configuration du cache
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int maxCacheSize = 100; // MB
  
  // Configuration des logs
  static const bool enableLogging = kDebugMode;
  static const bool enableNetworkLogging = kDebugMode;
  static const bool enableDatabaseLogging = kDebugMode;
  
  // URLs et endpoints
  static const String appName = 'Gestion Commerciale';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@votredomaine.com';
  static const String privacyPolicyUrl = 'https://votredomaine.com/privacy';
  static const String termsOfServiceUrl = 'https://votredomaine.com/terms';
  
  // Configuration des fonctionnalités spécifiques
  static const bool enableClientManagement = true;
  static const bool enableOrderManagement = true;
  static const bool enableInvoiceManagement = true;
  static const bool enableQuoteManagement = true;
  static const bool enableStockManagement = true;
  static const bool enableReportGeneration = true;
  
  // Configuration des limites
  static const int maxClientsPerPage = 50;
  static const int maxOrdersPerPage = 50;
  static const int maxInvoicesPerPage = 50;
  static const int maxQuotesPerPage = 50;
  static const int maxStockItemsPerPage = 100;
  
  // Configuration des formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String currencySymbol = '€';
  static const String currencyCode = 'EUR';
  
  // Configuration des validations
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int minEmailLength = 5;
  static const int maxEmailLength = 100;
  
  // Configuration des fichiers
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentFormats = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];
  static const int maxFileSize = 10; // MB
  static const int maxImageSize = 5; // MB
  
  // Configuration des thèmes
  static const String defaultTheme = 'light';
  static const List<String> availableThemes = ['light', 'dark', 'system'];
  
  // Configuration des langues
  static const String defaultLanguage = 'fr';
  static const List<String> availableLanguages = ['fr', 'en'];
  
  // Configuration des fonctionnalités expérimentales
  static const bool enableExperimentalFeatures = kDebugMode;
  static const bool enableBetaFeatures = false;

  static var version;
  
  // Méthodes utilitaires
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
  static bool get isDevelopment => environment == 'development';
  
  static bool get useMockData => enableMockData && isDevelopment;
  static bool get shouldEnableLogging => enableLogging && kDebugMode;
  
  // Configuration des fonctionnalités selon l'environnement
  static bool get shouldEnableAnalytics => enableAnalytics && isProduction;
  static bool get shouldEnableCrashReporting => enableCrashReporting && isProduction;
  static bool get shouldEnablePushNotifications => enablePushNotifications && isProduction;
  
  // Configuration des timeouts selon l'environnement
  static Duration get apiTimeoutForEnvironment {
    switch (environment) {
      case 'production':
        return const Duration(seconds: 15);
      case 'staging':
        return const Duration(seconds: 20);
      case 'development':
      default:
        return const Duration(seconds: 30);
    }
  }
  
  // Configuration des URLs selon l'environnement
  static String get baseUrlForEnvironment {
    switch (environment) {
      case 'production':
        return 'https://api.votredomaine.com';
      case 'staging':
        return 'https://staging-api.votredomaine.com';
      case 'development':
      default:
        return 'http://localhost:8000';
    }
  }
  
  // Configuration des fonctionnalités de débogage
  static bool get shouldShowDebugInfo => kDebugMode && isDevelopment;
  static bool get shouldEnablePerformanceMonitoring => kDebugMode;
  static bool get shouldEnableMemoryMonitoring => kDebugMode;
  
  // Configuration des fonctionnalités de test
  static bool get shouldEnableTestMode => kDebugMode;
  static bool get shouldEnableMockData => useMockData;
  static bool get shouldEnableTestUsers => kDebugMode;
  
  // Configuration des fonctionnalités de synchronisation
  static bool get shouldEnableAutoSync => enableDataSync && !isDevelopment;
  static Duration get syncIntervalForEnvironment {
    switch (environment) {
      case 'production':
        return const Duration(minutes: 10);
      case 'staging':
        return const Duration(minutes: 5);
      case 'development':
      default:
        return const Duration(minutes: 1);
    }
  }
  
  // Configuration des fonctionnalités de cache
  static Duration get cacheExpiryForEnvironment {
    switch (environment) {
      case 'production':
        return const Duration(hours: 2);
      case 'staging':
        return const Duration(hours: 1);
      case 'development':
      default:
        return const Duration(minutes: 30);
    }
  }
  
  // Configuration des fonctionnalités de sécurité
  static bool get shouldEnableBiometricAuth => enableBiometricAuth && isProduction;
  static bool get shouldEnableAutoLock => enableAutoLock && isProduction;
  static Duration get autoLockTimeoutForEnvironment {
    switch (environment) {
      case 'production':
        return const Duration(minutes: 10);
      case 'staging':
        return const Duration(minutes: 15);
      case 'development':
      default:
        return const Duration(minutes: 30);
    }
  }
}