import 'package:appgestion/models/relance_model.dart';
import 'package:appgestion/services/api_client.dart';

class RelanceService {
  final ApiClient _apiClient = ApiClient.instance;

  // Récupérer toutes les relances
  Future<List<Relance>> getRelances() async {
    final response = await _apiClient.makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/relances',
      fromJson: (json) => (json as List).cast<Map<String, dynamic>>(),
    );
    
    if (response.success && response.data != null) {
      return response.data!.map((json) => Relance.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Échec du chargement des relances');
    }
  }

  // Récupérer une relance par son ID
  Future<Relance> getRelanceById(String id) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/relances/$id',
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return Relance.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec du chargement de la relance');
    }
  }

  // Créer une nouvelle relance
  Future<Relance> createRelance(Relance relance) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/relances',
      body: relance.toJson(),
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return Relance.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec de la création de la relance');
    }
  }

  // Mettre à jour une relance
  Future<Relance> updateRelance(String id, Relance relance) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'PUT',
      endpoint: '/relances/$id',
      body: relance.toJson(),
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return Relance.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec de la mise à jour de la relance');
    }
  }

  // Supprimer une relance
  Future<bool> deleteRelance(String id) async {
    final response = await _apiClient.makeRequest<void>(
      method: 'DELETE',
      endpoint: '/relances/$id',
    );
    
    if (response.success) {
      return true;
    } else {
      throw Exception(response.message ?? 'Échec de la suppression de la relance');
    }
  }

  // Marquer une relance comme traitée
  Future<Relance> marquerCommeTraitee(String id, String commentaire) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'PATCH',
      endpoint: '/relances/$id/traiter',
      body: {'commentaire': commentaire},
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return Relance.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec de la mise à jour du statut de la relance');
    }
  }

  // Obtenir les statistiques de relances
  Future<Map<String, dynamic>> getStatistiques() async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/relances/statistiques',
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Échec du chargement des statistiques de relances');
    }
  }
}
