import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final AuthService _authService = AuthService();

  // Headers de base
  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers avec authentification
  Future<Map<String, String>> get _authHeaders async {
    final token = await _authService.getToken();
    return {
      ..._baseHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Méthode générique pour les requêtes GET
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final requestHeaders = headers ?? await _authHeaders;
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint'),
            headers: requestHeaders,
          )
          .timeout(ApiConfig.requestTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Méthode générique pour les requêtes POST
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final requestHeaders = headers ?? await _authHeaders;
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint'),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.requestTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Méthode générique pour les requêtes PUT
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final requestHeaders = headers ?? await _authHeaders;
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint'),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.requestTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Méthode générique pour les requêtes DELETE
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final requestHeaders = headers ?? await _authHeaders;
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint'),
            headers: requestHeaders,
          )
          .timeout(ApiConfig.requestTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Méthode générique pour les requêtes PATCH
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final requestHeaders = headers ?? await _authHeaders;
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint'),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.requestTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Gestion de la réponse
  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    try {
      final body = jsonDecode(response.body);

      // Si le token a expiré, essayer de le rafraîchir
      if (response.statusCode == 401) {
        final refreshed = await _authService.refreshToken();
        if (refreshed) {
          // Retourner une erreur pour que l'appelant puisse réessayer
          return ApiResponse.error('Token expiré, veuillez réessayer');
        } else {
          return ApiResponse.error('Session expirée, veuillez vous reconnecter');
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (fromJson != null && body is Map<String, dynamic>) {
          return ApiResponse.success(fromJson(body));
        } else {
          return ApiResponse.success(body as T);
        }
      } else {
        final errorMessage = _extractErrorMessage(body);
        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      return ApiResponse.error('Erreur de parsing de la réponse: ${e.toString()}');
    }
  }

  // Extraction du message d'erreur
  String _extractErrorMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['message'] ?? 
             body['error'] ?? 
             body['detail'] ?? 
             'Erreur inconnue';
    }
    return 'Erreur inconnue';
  }

  // Gestion des erreurs
  String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'Erreur de connexion réseau';
    } else if (error is HttpException) {
      return 'Erreur HTTP: ${error.message}';
    } else if (error is FormatException) {
      return 'Erreur de format de données';
    } else {
      return 'Erreur inattendue: ${error.toString()}';
    }
  }

  // Upload de fichier
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    String filePath, {
    Map<String, String>? fields,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrlForEnvironment}$endpoint'),
      );

      // Ajouter les headers d'authentification
      final token = await _authService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Ajouter le fichier
      final file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      // Ajouter les champs supplémentaires
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }
}

// Classe pour encapsuler les réponses API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse._({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse._(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse._(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  // Méthodes utilitaires
  bool get hasError => !success;
  bool get hasData => success && data != null;

  // Conversion de type
  ApiResponse<R> map<R>(R Function(T) transform) {
    if (success && data != null) {
      return ApiResponse.success(transform(data!));
    } else {
      return ApiResponse.error(error ?? 'Erreur inconnue');
    }
  }
}

// Exceptions personnalisées
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
