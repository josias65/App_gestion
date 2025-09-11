import 'package:appgestion/models/recouvrement_model.dart';
import 'package:appgestion/services/api_client.dart';

class RecouvrementService {
  final ApiClient _apiClient = ApiClient.instance;

  // Récupérer tous les recouvrements
  Future<List<Recouvrement>> getRecouvrements() async {
    final response = await _apiClient.makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/recouvrements',
      fromJson: (json) => (json as List).cast<Map<String, dynamic>>(),
    );
    
    if (response.success && response.data != null) {
      return response.data!.map((json) => Recouvrement.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Échec du chargement des recouvrements');
    }
  }

  // Récupérer un recouvrement par son ID
  Future<Recouvrement> getRecouvrementById(String id) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/recouvrements/$id',
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return Recouvrement.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec du chargement du recouvrement');
    }
  }

  // Créer un nouveau recouvrement
  Future<Recouvrement> createRecouvrement(Recouvrement recouvrement) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/recouvrements',
      body: recouvrement.toJson(),
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return Recouvrement.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec de la création du recouvrement');
    }
  }

  // Mettre à jour un recouvrement
  Future<Recouvrement> updateRecouvrement(String id, Recouvrement recouvrement) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'PUT',
      endpoint: '/recouvrements/$id',
      body: recouvrement.toJson(),
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return Recouvrement.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec de la mise à jour du recouvrement');
    }
  }

  // Supprimer un recouvrement
  Future<bool> deleteRecouvrement(String id) async {
    final response = await _apiClient.makeRequest<void>(
      method: 'DELETE',
      endpoint: '/recouvrements/$id',
    );
    
    if (response.success) {
      return true;
    } else {
      throw Exception(response.message ?? 'Échec de la suppression du recouvrement');
    }
  }

  // Obtenir les statistiques de recouvrement
  Future<Map<String, dynamic>> getStatistiques() async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/recouvrements/statistiques',
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Échec du chargement des statistiques de recouvrement');
    }
  }
}
