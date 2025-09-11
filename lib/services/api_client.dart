import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'mock_api_service.dart';
import 'auth_service.dart';

/// Classe utilitaire pour gérer les réponses HTTP
class HttpException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  HttpException(this.statusCode, this.message, {this.data});

  @override
  String toString() => 'HttpException: $statusCode - $message';
}

/// Service client API unifié pour toutes les requêtes
class ApiClient {
  static ApiClient? _instance;
  late AuthService _authService;
  late http.Client _httpClient;
  
  ApiClient._() {
    _authService = AuthService();
    _httpClient = http.Client();
  }
  
  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }
  
  // Initialisation
  void initialize() {
    print('ApiClient initialisé');
  }
  
  // Nettoyage
  void dispose() {
    _httpClient.close();
  }
  

  // Headers avec authentification
  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final token = await _authService.getToken();
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      return {'Content-Type': 'application/json'};
    }
  }

  // Méthode générique pour les requêtes GET
  Future<http.Response> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final response = await _httpClient.get(
        uri,
        headers: await _getAuthHeaders(),
      );

      _handleResponse(response);
      return response;
    } on SocketException catch (e) {
      throw HttpException(0, 'Erreur de connexion: ${e.message}');
    } on FormatException catch (e) {
      throw HttpException(0, 'Erreur de format de réponse: ${e.message}');
    } catch (e) {
      throw HttpException(0, 'Erreur inattendue: $e');
    }
  }

  // Méthode générique pour les requêtes POST
  Future<http.Response> post(String endpoint, {dynamic body}) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint'),
        headers: await _getAuthHeaders(),
        body: body is Map || body is List ? jsonEncode(body) : body,
      );

      _handleResponse(response);
      return response;
    } on SocketException catch (e) {
      throw HttpException(0, 'Erreur de connexion: ${e.message}');
    } on FormatException catch (e) {
      throw HttpException(0, 'Erreur de format de réponse: ${e.message}');
    } catch (e) {
      throw HttpException(0, 'Erreur inattendue: $e');
    }
  }

  // Méthode générique pour les requêtes PUT
  Future<http.Response> put(String endpoint, {dynamic body}) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint'),
        headers: await _getAuthHeaders(),
        body: body is Map || body is List ? jsonEncode(body) : body,
      );

      _handleResponse(response);
      return response;
    } on SocketException catch (e) {
      throw HttpException(0, 'Erreur de connexion: ${e.message}');
    } on FormatException catch (e) {
      throw HttpException(0, 'Erreur de format de réponse: ${e.message}');
    } catch (e) {
      throw HttpException(0, 'Erreur inattendue: $e');
    }
  }

  // Méthode générique pour les requêtes PATCH
  Future<http.Response> patch(String endpoint, {dynamic body}) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint'),
        headers: await _getAuthHeaders(),
        body: body is Map || body is List ? jsonEncode(body) : body,
      );

      _handleResponse(response);
      return response;
    } on SocketException catch (e) {
      throw HttpException(0, 'Erreur de connexion: ${e.message}');
    } on FormatException catch (e) {
      throw HttpException(0, 'Erreur de format de réponse: ${e.message}');
    } catch (e) {
      throw HttpException(0, 'Erreur inattendue: $e');
    }
  }

  // Méthode générique pour les requêtes DELETE
  Future<http.Response> delete(String endpoint) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint'),
        headers: await _getAuthHeaders(),
      );

      _handleResponse(response);
      return response;
    } on SocketException catch (e) {
      throw HttpException(0, 'Erreur de connexion: ${e.message}');
    } on FormatException catch (e) {
      throw HttpException(0, 'Erreur de format de réponse: ${e.message}');
    } catch (e) {
      throw HttpException(0, 'Erreur inattendue: $e');
    }
  }

  // Gestion de base de la réponse HTTP (utilisée uniquement par les méthodes directes)
  void _handleResponse(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage = 'Erreur serveur (${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw HttpException(response.statusCode, errorMessage);
    }
  }
  
  // Méthode générique pour toutes les requêtes
  Future<ApiResponse<T>> makeRequest<T>({
    required String method,
    required String endpoint,
    dynamic body,
    T Function(dynamic)? fromJson,
    bool useMock = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint');
      http.Response response;
      
      if (useMock) {
        response = await _makeMockRequest(method, endpoint, body);
      } else {
        final headers = await _getAuthHeaders();
        
        switch (method.toUpperCase()) {
          case 'GET':
            response = await _httpClient.get(uri, headers: headers);
            break;
          case 'POST':
            response = await _httpClient.post(
              uri,
              headers: headers,
              body: body is Map || body is List ? jsonEncode(body) : body,
            );
            break;
          case 'PUT':
            response = await _httpClient.put(
              uri,
              headers: headers,
              body: body is Map || body is List ? jsonEncode(body) : body,
            );
            break;
          case 'DELETE':
            response = await _httpClient.delete(uri, headers: headers);
            break;
          default:
            throw Exception('Méthode HTTP non supportée: $method');
        }
      }
      
      return _handleApiResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Erreur de requête: ${e.toString()}');
    }
  }
  
  // Requête mock
  Future<http.Response> _makeMockRequest(String method, String endpoint, Map<String, dynamic>? body) async {
    switch (endpoint) {
      case '/auth/login':
        return await MockApiService.login(
          body?['email'] ?? '',
          body?['password'] ?? '',
        );
      case '/customers':
        if (method == 'GET') return await MockApiService.getClients();
        if (method == 'POST') return await MockApiService.createClient(body ?? {});
        break;
      case '/article':
        if (method == 'GET') return await MockApiService.getArticles();
        if (method == 'POST') return await MockApiService.createArticle(body ?? {});
        break;
      case '/commande':
        if (method == 'GET') return await MockApiService.getCommandes();
        if (method == 'POST') return await MockApiService.createCommande(body ?? {});
        break;
      case '/facture':
        if (method == 'GET') return await MockApiService.getFactures();
        if (method == 'POST') return await MockApiService.createFacture(body ?? {});
        break;
      case '/devis':
        if (method == 'GET') return await MockApiService.getDevis();
        if (method == 'POST') return await MockApiService.createDevis(body ?? {});
        break;
      case '/dashboard/stats':
        return await MockApiService.getDashboardStats();
      case '/health':
        return await MockApiService.checkConnectivity();
    }
    
    // Fallback
    return http.Response(jsonEncode({'success': false, 'message': 'Endpoint non trouvé'}), 404);
  }
  
  // Gestion de la réponse pour les requêtes génériques
  Future<ApiResponse<T>> _handleApiResponse<T>(
    http.Response response, 
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (T.toString() == 'void') {
          return ApiResponse.success(null as T);
        } else if (fromJson != null) {
          return ApiResponse.success(fromJson(data));
        } else {
          return ApiResponse.success(data as T);
        }
      } else {
        return ApiResponse.error(data['message'] ?? 'Erreur de requête');
      }
    } on FormatException catch (e) {
      return ApiResponse.error('Erreur de format: ${e.toString()}');
    } on SocketException catch (e) {
      return ApiResponse.error('Erreur de connexion: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Erreur inattendue: ${e.toString()}');
    }
  }
  
  // ========== AUTHENTIFICATION ==========
  
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    return await makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/auth/login',
      body: {'email': email, 'password': password},
      useMock: true, // Utiliser mock par défaut
    );
  }
  
  Future<ApiResponse<void>> logout() async {
    return await makeRequest<void>(
      method: 'POST',
      endpoint: '/auth/logout',
    );
  }
  
  // ========== CLIENTS ==========
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getClients() async {
    return await makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/customers',
      fromJson: (data) => List<Map<String, dynamic>>.from(data as List),
      useMock: true,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> createClient(Map<String, dynamic> clientData) async {
    return await makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/customers',
      body: clientData,
      useMock: true,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> updateClient(String id, Map<String, dynamic> clientData) async {
    return await makeRequest<Map<String, dynamic>>(
      method: 'PUT',
      endpoint: '/customers/$id',
      body: clientData,
      useMock: true,
    );
  }
  
  Future<ApiResponse<void>> deleteClient(String id) async {
    return await makeRequest<void>(
      method: 'DELETE',
      endpoint: '/customers/$id',
      useMock: true,
    );
  }
  
  // ========== ARTICLES ==========
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getArticles() async {
    return await makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/article',
      fromJson: (data) => List<Map<String, dynamic>>.from(data as List),
      useMock: true,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> createArticle(Map<String, dynamic> articleData) async {
    return await makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/article',
      body: articleData,
      useMock: true,
    );
  }
  
  // ========== COMMANDES ==========
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getCommandes() async {
    return await makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/commande',
      fromJson: (data) => List<Map<String, dynamic>>.from(data as List),
      useMock: true,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> createCommande(Map<String, dynamic> commandeData) async {
    return await makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/commande',
      body: commandeData,
      useMock: true,
    );
  }
  
  // ========== FACTURES ==========
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getFactures() async {
    return await makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/facture',
      fromJson: (data) => List<Map<String, dynamic>>.from(data as List),
      useMock: true,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> createFacture(Map<String, dynamic> factureData) async {
    return await makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/facture',
      body: factureData,
      useMock: true,
    );
  }
  
  // ========== DEVIS ==========
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getDevis() async {
    return await makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/devis',
      fromJson: (data) => List<Map<String, dynamic>>.from(data as List),
      useMock: true,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> createDevis(Map<String, dynamic> devisData) async {
    return await makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/devis',
      body: devisData,
      useMock: true,
    );
  }
  
  // ========== STATISTIQUES ==========
  
  Future<ApiResponse<Map<String, dynamic>>> getDashboardStats() async {
    return await makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/dashboard/stats',
      useMock: true,
    );
  }
  
  // ========== SANTÉ DU SYSTÈME ==========
  
  Future<ApiResponse<Map<String, dynamic>>> checkHealth() async {
    return await makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/health',
      useMock: true,
    );
  }
  
  // ========== MÉTHODES MOCK POUR LES TESTS ==========
  
  Future<ApiResponse<T>> _mockApiCall<T>(
    String endpoint, 
    Map<String, dynamic>? queryParams, 
    dynamic body, 
    T Function(dynamic)? fromJson,
  ) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Exemple de réponse mock pour différents endpoints
    switch (endpoint) {
      case '/appels-offre':
        final mockData = [
          {'id': 1, 'titre': 'Appel d\'offre 1', 'statut': 'En cours'},
          {'id': 2, 'titre': 'Appel d\'offre 2', 'statut': 'Terminé'},
        ];
        return ApiResponse.success(mockData as T);
        
      case '/recouvrements':
        final mockData = [
          {'id': 1, 'montant': 1000, 'statut': 'En attente'},
          {'id': 2, 'montant': 2000, 'statut': 'Payé'},
        ];
        return ApiResponse.success(mockData as T);
        
      default:
        return ApiResponse.error('Endpoint mock non implémenté: $endpoint');
    }
  }

  // ========== MÉTHODE GÉNÉRIQUE POUR LES REQUÊTES ==========  
  
  Future<ApiResponse<T>> _makeRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? queryParams,
    dynamic body,
    T Function(dynamic)? fromJson,
    bool useMock = false,
  }) async {
    if (useMock) {
      return _mockApiCall(endpoint, queryParams, body, fromJson);
    }

    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint')
          .replace(queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())));

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _httpClient.get(uri, headers: headers);
          break;
        case 'POST':
          response = await _httpClient.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await _httpClient.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PATCH':
          response = await _httpClient.patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await _httpClient.delete(
            uri,
            headers: headers,
          );
          break;
        default:
          throw ArgumentError('Méthode HTTP non supportée: $method');
      }

      return _handleApiResponse(response, fromJson);
    } on SocketException catch (e) {
      return ApiResponse.error('Erreur de connexion: ${e.message}');
    } on FormatException catch (e) {
      return ApiResponse.error('Erreur de format: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Erreur inattendue: $e');
    }
  }
  
  // ========== APPELS D'OFFRE ==========
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getAppelsOffre({Map<String, dynamic>? filters}) async {
    return await _makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/appels-offre',
      queryParams: filters,
      fromJson: (data) => List<Map<String, dynamic>>.from(data as List),
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getAppelOffre(String id) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/appels-offre/$id',
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> createAppelOffre(Map<String, dynamic> data) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/appels-offre',
      body: data,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> updateAppelOffre(String id, Map<String, dynamic> data) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'PUT',
      endpoint: '/appels-offre/$id',
      body: data,
    );
  }
  
  Future<ApiResponse<void>> deleteAppelOffre(String id) async {
    return await _makeRequest<void>(
      method: 'DELETE',
      endpoint: '/appels-offre/$id',
    );
  }
  
  Future<ApiResponse<void>> toggleFavoriteAppelOffre(String id, bool isFavorite) async {
    return await _makeRequest<void>(
      method: 'PATCH',
      endpoint: '/appels-offre/$id/favorite',
      body: {'isFavorite': isFavorite},
    );
  }
  
  // ========== RECOUVREMENTS ==========
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getRecouvrements({Map<String, dynamic>? filters}) async {
    return await _makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/recouvrements',
      queryParams: filters,
      fromJson: (data) => List<Map<String, dynamic>>.from(data as List),
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getRecouvrement(String id) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/recouvrements/$id',
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> createRecouvrement(Map<String, dynamic> data) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/recouvrements',
      body: data,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> updateRecouvrement(String id, Map<String, dynamic> data) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'PUT',
      endpoint: '/recouvrements/$id',
      body: data,
    );
  }
  
  Future<ApiResponse<void>> deleteRecouvrement(String id) async {
    return await _makeRequest<void>(
      method: 'DELETE',
      endpoint: '/recouvrements/$id',
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getRecouvrementStats() async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/recouvrements/stats',
    );
  }
  
  // ========== RELANCES ==========
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getRelances({Map<String, dynamic>? filters}) async {
    return await _makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/relances',
      queryParams: filters,
      fromJson: (data) => List<Map<String, dynamic>>.from(data as List),
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getRelance(String id) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/relances/$id',
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> createRelance(Map<String, dynamic> data) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/relances',
      body: data,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> updateRelance(String id, Map<String, dynamic> data) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'PUT',
      endpoint: '/relances/$id',
      body: data,
    );
  }
  
  Future<ApiResponse<void>> deleteRelance(String id) async {
    return await _makeRequest<void>(
      method: 'DELETE',
      endpoint: '/relances/$id',
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> marquerRelanceTraitee(String id, String note) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'PATCH',
      endpoint: '/relances/$id/traitee',
      body: {'note': note},
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getRelanceStats() async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/relances/stats',
    );
  }
  
  // ========== MARCHÉS ==========
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getMarches({Map<String, dynamic>? filters}) async {
    return await _makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/marches',
      queryParams: filters,
      fromJson: (data) => List<Map<String, dynamic>>.from(data as List),
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getMarche(String id) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/marches/$id',
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> createMarche(Map<String, dynamic> data) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/marches',
      body: data,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> updateMarche(String id, Map<String, dynamic> data) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'PUT',
      endpoint: '/marches/$id',
      body: data,
    );
  }
  
  Future<ApiResponse<void>> deleteMarche(String id) async {
    return await _makeRequest<void>(
      method: 'DELETE',
      endpoint: '/marches/$id',
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> soumettreOffreMarche(
    String marcheId, 
    Map<String, dynamic> offreData
  ) async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/marches/$marcheId/offres',
      body: offreData,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getMarcheStats() async {
    return await _makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/marches/stats',
    );
  }
}

/// Classe pour gérer les réponses API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;
  
  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });
  
  factory ApiResponse.success(T data) {
    return ApiResponse(success: true, data: data);
  }
  
  factory ApiResponse.error(String error) {
    return ApiResponse(success: false, error: error);
  }
  
  bool get isSuccess => success;
  bool get isError => !success;
}