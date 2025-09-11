import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_client.dart';

/// Service de gestion de la connectivité réseau
class ConnectivityService {
  static ConnectivityService? _instance;
  static Connectivity? _connectivity;
  
  ConnectivityService._() {
    _connectivity = Connectivity();
  }
  
  static ConnectivityService get instance {
    _instance ??= ConnectivityService._();
    return _instance!;
  }
  
  // Vérifier la connectivité Internet
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity!.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Erreur lors de la vérification de la connectivité: $e');
      return false;
    }
  }
  
  // Vérifier si le backend est accessible
  static Future<bool> isBackendReady() async {
    try {
      final apiClient = ApiClient.instance;
      final response = await apiClient.checkHealth();
      return response.isSuccess;
    } catch (e) {
      print('Backend non accessible: $e');
      return false;
    }
  }
  
  // Stream de changements de connectivité
  Stream<ConnectivityResult> get connectivityStream => _connectivity!.onConnectivityChanged;
  
  // Vérifier la connectivité avec un timeout
  Future<bool> isConnectedWithTimeout({Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final result = await _connectivity!.checkConnectivity().timeout(timeout);
      return result != ConnectivityResult.none;
    } catch (e) {
      print('Timeout de connectivité: $e');
      return false;
    }
  }
  
  // Obtenir le type de connexion
  Future<String> getConnectionType() async {
    try {
      final connectivityResult = await _connectivity!.checkConnectivity();
      
      switch (connectivityResult) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.mobile:
          return 'Mobile';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.other:
          return 'Autre';
        case ConnectivityResult.none:
        default:
          return 'Aucune connexion';
      }
    } catch (e) {
      print('Erreur lors de la récupération du type de connexion: $e');
      return 'Inconnu';
    }
  }
  
  // Vérifier la connectivité avec un ping
  Future<bool> pingTest({String host = 'google.com'}) async {
    try {
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      print('Erreur lors du test de ping: $e');
      return false;
    }
  }
  
  // Obtenir les informations de connectivité complètes
  Future<Map<String, dynamic>> getConnectivityInfo() async {
    try {
      final isConnected = await this.isConnected();
      final connectionType = await getConnectionType();
      final pingResult = await pingTest();
      final backendReady = await isBackendReady();
      
      return {
        'isConnected': isConnected,
        'connectionType': connectionType,
        'pingTest': pingResult,
        'backendReady': backendReady,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Erreur lors de la récupération des informations de connectivité: $e');
      return {
        'isConnected': false,
        'connectionType': 'Inconnu',
        'pingTest': false,
        'backendReady': false,
        'timestamp': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  static Future testConnection() async {}

  static Future testAuthentication() async {}

  static Future testAllEndpoints() async {}
}