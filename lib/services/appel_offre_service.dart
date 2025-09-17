import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class AppelOffreService {
  static const String _storageKey = 'appel_offre_cache';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ===== GESTION DES APPELS D'OFFRE =====

  /// Récupérer tous les appels d'offre avec filtres
  Future<Map<String, dynamic>> getAppelsOffre({
    int page = 1,
    int limit = 10,
    String? status,
    String? category,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? dateFrom,
    String? dateTo,
    double? budgetMin,
    double? budgetMax,
  }) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final uri = Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (status != null && status.isNotEmpty) 'status': status,
          if (category != null && category.isNotEmpty) 'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
          if (sortBy != null) 'sortBy': sortBy,
          if (sortOrder != null) 'sortOrder': sortOrder,
          if (dateFrom != null) 'dateFrom': dateFrom,
          if (dateTo != null) 'dateTo': dateTo,
          if (budgetMin != null) 'budgetMin': budgetMin.toString(),
          if (budgetMax != null) 'budgetMax': budgetMax.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Mettre en cache
        await _cacheAppelsOffre(data);
        
        return data;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur getAppelsOffre: $e');
      // Retourner les données en cache en cas d'erreur
      return await _getCachedAppelsOffre();
    }
  }

  /// Récupérer un appel d'offre par ID
  Future<Map<String, dynamic>> getAppelOffreById(int id) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Mettre en cache individuellement
        await _cacheAppelOffre(id, data);
        
        return data;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur getAppelOffreById: $e');
      // Retourner les données en cache en cas d'erreur
      return await _getCachedAppelOffre(id);
    }
  }

  /// Créer un nouvel appel d'offre
  Future<Map<String, dynamic>> createAppelOffre(Map<String, dynamic> appelOffreData) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(appelOffreData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        
        // Invalider le cache
        await _clearCache();
        
        return data;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur createAppelOffre: $e');
      rethrow;
    }
  }

  /// Mettre à jour un appel d'offre
  Future<Map<String, dynamic>> updateAppelOffre(int id, Map<String, dynamic> updates) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Invalider le cache
        await _clearCache();
        
        return data;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur updateAppelOffre: $e');
      rethrow;
    }
  }

  /// Supprimer un appel d'offre
  Future<Map<String, dynamic>> deleteAppelOffre(int id) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Invalider le cache
        await _clearCache();
        
        return data;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur deleteAppelOffre: $e');
      rethrow;
    }
  }

  // ===== GESTION DES DOCUMENTS =====

  /// Uploader des documents pour un appel d'offre
  Future<Map<String, dynamic>> uploadDocuments(int appelOffreId, List<File> files) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final uri = Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre/$appelOffreId/documents');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // Ajouter les fichiers
      for (final file in files) {
        request.files.add(await http.MultipartFile.fromPath(
          'documents',
          file.path,
          filename: file.path.split('/').last,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Invalider le cache de cet appel d'offre
        await _clearAppelOffreCache(appelOffreId);
        
        return data;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur uploadDocuments: $e');
      rethrow;
    }
  }

  /// Télécharger un document
  Future<Map<String, dynamic>> downloadDocument(int appelOffreId, int documentId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre/$appelOffreId/documents/$documentId/download'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.bodyBytes,
        };
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur downloadDocument: $e');
      rethrow;
    }
  }

  /// Supprimer un document
  Future<Map<String, dynamic>> deleteDocument(int appelOffreId, int documentId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre/$appelOffreId/documents/$documentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Invalider le cache de cet appel d'offre
        await _clearAppelOffreCache(appelOffreId);
        
        return data;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur deleteDocument: $e');
      rethrow;
    }
  }

  // ===== GESTION DES COMMENTAIRES =====

  /// Ajouter un commentaire
  Future<Map<String, dynamic>> addComment(int appelOffreId, String content) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre/$appelOffreId/comments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        
        // Invalider le cache de cet appel d'offre
        await _clearAppelOffreCache(appelOffreId);
        
        return data;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur addComment: $e');
      rethrow;
    }
  }

  // ===== GESTION DES SOUMISSIONS =====

  /// Soumettre une offre
  Future<Map<String, dynamic>> submitOffer(int appelOffreId, Map<String, dynamic> soumissionData) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre/$appelOffreId/soumissions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(soumissionData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        
        // Invalider le cache de cet appel d'offre
        await _clearAppelOffreCache(appelOffreId);
        
        return data;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur submitOffer: $e');
      rethrow;
    }
  }

  /// Évaluer une soumission
  Future<Map<String, dynamic>> evaluateSubmission(
    int appelOffreId, 
    int soumissionId, 
    Map<String, dynamic> evaluationData
  ) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre/$appelOffreId/soumissions/$soumissionId/evaluate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(evaluationData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Invalider le cache de cet appel d'offre
        await _clearAppelOffreCache(appelOffreId);
        
        return data;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur evaluateSubmission: $e');
      rethrow;
    }
  }

  // ===== STATISTIQUES ET RAPPORTS =====

  /// Récupérer les statistiques détaillées
  Future<Map<String, dynamic>> getDetailedStats({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final uri = Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre/stats/detailed').replace(
        queryParameters: {
          if (dateFrom != null) 'dateFrom': dateFrom,
          if (dateTo != null) 'dateTo': dateTo,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur getDetailedStats: $e');
      rethrow;
    }
  }

  /// Exporter les données
  Future<List<int>> exportData(String format, {String? dateFrom, String? dateTo}) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('Token non disponible');

      final uri = Uri.parse('${ApiConfig.baseUrlForEnvironment}/appels-offre/export/$format').replace(
        queryParameters: {
          if (dateFrom != null) 'dateFrom': dateFrom,
          if (dateTo != null) 'dateTo': dateTo,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur exportData: $e');
      rethrow;
    }
  }

  // ===== GESTION DU CACHE =====

  /// Mettre en cache les appels d'offre
  Future<void> _cacheAppelsOffre(Map<String, dynamic> data) async {
    try {
      await _storage.write(key: _storageKey, value: json.encode(data));
    } catch (e) {
      print('Erreur cache appels d\'offre: $e');
    }
  }

  /// Récupérer les appels d'offre du cache
  Future<Map<String, dynamic>> _getCachedAppelsOffre() async {
    try {
      final cached = await _storage.read(key: _storageKey);
      if (cached != null) {
        return json.decode(cached);
      }
    } catch (e) {
      print('Erreur récupération cache: $e');
    }
    return {'success': false, 'message': 'Données non disponibles'};
  }

  /// Mettre en cache un appel d'offre individuel
  Future<void> _cacheAppelOffre(int id, Map<String, dynamic> data) async {
    try {
      await _storage.write(key: 'appel_offre_$id', value: json.encode(data));
    } catch (e) {
      print('Erreur cache appel d\'offre $id: $e');
    }
  }

  /// Récupérer un appel d'offre du cache
  Future<Map<String, dynamic>> _getCachedAppelOffre(int id) async {
    try {
      final cached = await _storage.read(key: 'appel_offre_$id');
      if (cached != null) {
        return json.decode(cached);
      }
    } catch (e) {
      print('Erreur récupération cache appel d\'offre $id: $e');
    }
    return {'success': false, 'message': 'Données non disponibles'};
  }

  /// Vider le cache
  Future<void> _clearCache() async {
    try {
      await _storage.delete(key: _storageKey);
      // Supprimer aussi tous les caches individuels
      final keys = await _storage.readAll();
      for (final key in keys.keys) {
        if (key.startsWith('appel_offre_')) {
          await _storage.delete(key: key);
        }
      }
    } catch (e) {
      print('Erreur suppression cache: $e');
    }
  }

  /// Vider le cache d'un appel d'offre spécifique
  Future<void> _clearAppelOffreCache(int id) async {
    try {
      await _storage.delete(key: 'appel_offre_$id');
    } catch (e) {
      print('Erreur suppression cache appel d\'offre $id: $e');
    }
  }

  // ===== UTILITAIRES =====

  /// Formater le budget pour l'affichage
  static String formatBudget(double? budget) {
    if (budget == null) return 'Non spécifié';
    
    if (budget >= 1000000) {
      return '${(budget / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (budget >= 1000) {
      return '${(budget / 1000).toStringAsFixed(0)}K FCFA';
    } else {
      return '${budget.toStringAsFixed(0)} FCFA';
    }
  }

  /// Formater la date pour l'affichage
  static String formatDate(String? dateString) {
    if (dateString == null) return 'Non spécifié';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  /// Obtenir la couleur selon le statut
  static int getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'ouvert':
        return 0xFF4CAF50; // Vert
      case 'closed':
      case 'clôturé':
        return 0xFF9E9E9E; // Gris
      case 'awarded':
      case 'attribué':
        return 0xFF2196F3; // Bleu
      case 'cancelled':
      case 'annulé':
        return 0xFFF44336; // Rouge
      default:
        return 0xFF9E9E9E; // Gris par défaut
    }
  }

  /// Obtenir la couleur selon l'urgence
  static int getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'urgente':
        return 0xFFF44336; // Rouge
      case 'haute':
        return 0xFFFF9800; // Orange
      case 'normale':
        return 0xFF2196F3; // Bleu
      case 'basse':
        return 0xFF4CAF50; // Vert
      default:
        return 0xFF9E9E9E; // Gris par défaut
    }
  }
}