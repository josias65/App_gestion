class Settings {
  final bool isDarkTheme;
  final bool notificationsEnabled;
  final String currency;
  final String language;
  final bool autoLock;
  final String? userId;
  final DateTime? lastUpdated;

  Settings({
    required this.isDarkTheme,
    required this.notificationsEnabled,
    required this.currency,
    required this.language,
    required this.autoLock,
    this.userId,
    this.lastUpdated,
  });

  // Convertir l'objet en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'isDarkTheme': isDarkTheme,
      'notificationsEnabled': notificationsEnabled,
      'currency': currency,
      'language': language,
      'autoLock': autoLock,
      'userId': userId,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Créer un objet Settings à partir d'un Map
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      isDarkTheme: json['isDarkTheme'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      currency: json['currency'] ?? 'EUR',
      language: json['language'] ?? 'Français',
      autoLock: json['autoLock'] ?? true,
      userId: json['userId'],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : null,
    );
  }

  // Créer une copie de l'objet avec des valeurs mises à jour
  Settings copyWith({
    bool? isDarkTheme,
    bool? notificationsEnabled,
    String? currency,
    String? language,
    bool? autoLock,
    String? userId,
    DateTime? lastUpdated,
  }) {
    return Settings(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      autoLock: autoLock ?? this.autoLock,
      userId: userId ?? this.userId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
