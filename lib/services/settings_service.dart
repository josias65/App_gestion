import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';
import 'api_client.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  final ApiClient _apiClient = ApiClient.instance;
  late SharedPreferences _prefs;
  
  // Valeurs par défaut
  static const String _defaultCurrency = 'EUR';
  static const String _defaultLanguage = 'Français';
  static const bool _defaultDarkTheme = false;
  static const bool _defaultNotifications = true;
  static const bool _defaultAutoLock = true;

  // Clés de stockage local
  static const String _settingsKey = 'user_settings';
  static const String _lastSyncKey = 'last_settings_sync';

  // État actuel des paramètres
  Settings _currentSettings = Settings(
    isDarkTheme: _defaultDarkTheme,
    notificationsEnabled: _defaultNotifications,
    currency: _defaultCurrency,
    language: _defaultLanguage,
    autoLock: _defaultAutoLock,
  );

  // Stream pour écouter les changements de paramètres
  final _settingsController = StreamController<Settings>.broadcast();
  Stream<Settings> get settingsStream => _settingsController.stream;

  // Constructeur privé
  SettingsService._internal();

  // Instance unique
  factory SettingsService() => _instance;

  // Initialisation
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromCache();
    await _syncWithBackend();
  }

  // Récupérer les paramètres actuels
  Settings get settings => _currentSettings;

  // Charger depuis le cache local
  Future<void> _loadFromCache() async {
    try {
      final settingsJson = _prefs.getString(_settingsKey);
      if (settingsJson != null) {
        final decoded = jsonDecode(settingsJson) as Map<String, dynamic>;
        _currentSettings = Settings.fromJson(decoded);
        _notifyListeners();
      }
    } catch (e) {
      // En cas d'erreur, on garde les valeurs par défaut
      print('Erreur lors du chargement des paramètres: $e');
    }
  }

  // Synchroniser avec le backend
  Future<void> _syncWithBackend() async {
    try {
      final lastSync = _prefs.getInt(_lastSyncKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Ne synchroniser que si plus de 5 minutes se sont écoulées depuis la dernière synchronisation
      if (now - lastSync > 5 * 60 * 1000) {
        final response = await _apiClient.makeRequest<Map<String, dynamic>>(
          method: 'GET',
          endpoint: '/api/settings',
        );

        if (response.success && response.data != null) {
          _currentSettings = Settings.fromJson(response.data!);
          await _saveToCache();
          _notifyListeners();
        }
        
        await _prefs.setInt(_lastSyncKey, now);
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des paramètres: $e');
    }
  }

  // Sauvegarder en cache local
  Future<void> _saveToCache() async {
    try {
      await _prefs.setString(_settingsKey, jsonEncode(_currentSettings.toJson()));
    } catch (e) {
      print('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  // Mettre à jour les paramètres
  Future<bool> updateSettings(Settings newSettings) async {
    try {
      final response = await _apiClient.makeRequest<Map<String, dynamic>>(
        method: 'PUT',
        endpoint: '/api/settings',
        body: newSettings.toJson(),
      );

      if (response.success) {
        _currentSettings = newSettings.copyWith(
          lastUpdated: DateTime.now(),
        );
        await _saveToCache();
        _notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la mise à jour des paramètres: $e');
      return false;
    }
  }

  // Mettre à jour un paramètre individuel
  Future<bool> updateSetting<T>(String key, T value) async {
    try {
      final updatedSettings = _currentSettings.copyWith(
        isDarkTheme: key == 'isDarkTheme' ? value as bool? : _currentSettings.isDarkTheme,
        notificationsEnabled: key == 'notificationsEnabled' ? value as bool? : _currentSettings.notificationsEnabled,
        currency: key == 'currency' ? value as String? : _currentSettings.currency,
        language: key == 'language' ? value as String? : _currentSettings.language,
        autoLock: key == 'autoLock' ? value as bool? : _currentSettings.autoLock,
        lastUpdated: DateTime.now(),
      );

      return await updateSettings(updatedSettings);
    } catch (e) {
      print('Erreur lors de la mise à jour du paramètre $key: $e');
      return false;
    }
  }

  // Notifier les écouteurs
  void _notifyListeners() {
    if (!_settingsController.isClosed) {
      _settingsController.add(_currentSettings);
    }
  }

  // Nettoyage
  Future<void> dispose() async {
    await _settingsController.close();
  }
}
