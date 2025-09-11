import 'package:appgestion/models/appel_offre_model.dart';
import 'package:appgestion/services/api_client.dart';

class AppelOffreService {
  final ApiClient _apiClient = ApiClient.instance;

  // Récupérer tous les appels d'offre
  Future<List<AppelOffre>> getAppelsOffre() async {
    final response = await _apiClient.makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/appels-offre',
      fromJson: (json) => (json as List).cast<Map<String, dynamic>>(),
    );
    
    if (response.success && response.data != null) {
      return response.data!.map((json) => AppelOffre.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Échec du chargement des appels d\'offre');
    }
  }

  // Récupérer un appel d'offre par son ID
  Future<AppelOffre> getAppelOffreById(String id) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/appels-offre/$id',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    
    if (response.success && response.data != null) {
      return AppelOffre.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec du chargement de l\'appel d\'offre');
    }
  }

  // Créer un nouvel appel d'offre
  Future<AppelOffre> createAppelOffre(AppelOffre appelOffre) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/appels-offre',
      body: appelOffre.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    if (response.success && response.data != null) {
      return AppelOffre.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec de la création de l\'appel d\'offre');
    }
  }

  // Mettre à jour un appel d'offre
  Future<AppelOffre> updateAppelOffre(String id, AppelOffre appelOffre) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'PUT',
      endpoint: '/appels-offre/$id',
      body: appelOffre.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    if (response.success && response.data != null) {
      return AppelOffre.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec de la mise à jour de l\'appel d\'offre');
    }
  }

  // Supprimer un appel d'offre
  Future<bool> deleteAppelOffre(String id) async {
    final response = await _apiClient.makeRequest<void>(
      method: 'DELETE',
      endpoint: '/appels-offre/$id',
    );
    
    if (response.success) {
      return true;
    } else {
      throw Exception(response.message ?? 'Échec de la suppression de l\'appel d\'offre');
    }
  }
}
