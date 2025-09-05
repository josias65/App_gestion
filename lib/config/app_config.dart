import 'package:flutter/foundation.dart';

class AppConfig {
  // Configuration de l'application
  static const String appName = 'Gestion App';
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  // Configuration du débogage
  static const bool debugMode = kDebugMode;
  static const bool releaseMode = kReleaseMode;
  static const bool profileMode = kProfileMode;

  // Configuration des logs
  static const bool enableLogging = true;
  static const bool enableAnalytics = true;
  
  // Configuration du thème
  static const String defaultTheme = 'light';
  static const bool enableDarkMode = true;
  
  // Configuration des données de test
  static const bool useMockData = false; // Mettre à false pour utiliser l'API réelle
  
  // Configuration du cache
  static const int cacheDurationInMinutes = 15;
  static const int maxCacheSize = 50; // en MB
  
  // Configuration des mises à jour
  static const bool checkForUpdates = true;
  static const String appStoreUrl = 'https://apps.apple.com/app/idYOUR_APP_ID';
  static const String playStoreUrl = 'market://details?id=YOUR_PACKAGE_NAME';
  
  // Configuration des fonctionnalités
  static const bool enablePremiumFeatures = false;
  static const bool enableOfflineMode = true;
  
  // Configuration du support
  static const String supportEmail = 'support@votredomaine.com';
  static const String privacyPolicyUrl = 'https://votredomaine.com/privacy';
  static const String termsOfServiceUrl = 'https://votredomaine.com/terms';
  
  // Configuration des tests
  static const bool isTesting = bool.fromEnvironment('IS_TESTING', defaultValue: false);
  
  // Méthode pour afficher la configuration (à utiliser dans les logs)
  static Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'version': version,
      'buildNumber': buildNumber,
      'debugMode': debugMode,
      'releaseMode': releaseMode,
      'profileMode': profileMode,
      'enableLogging': enableLogging,
      'enableAnalytics': enableAnalytics,
      'enableOfflineMode': enableOfflineMode,
      'isTesting': isTesting,
    };
  }
}
