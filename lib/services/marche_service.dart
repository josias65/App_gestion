import 'package:appgestion/models/marche_model.dart';
import 'package:appgestion/services/api_client.dart';

class MarcheService {
  final ApiClient _apiClient = ApiClient.instance;

  // Récupérer tous les marchés
  Future<List<Marche>> getMarches() async {
    final response = await _apiClient.makeRequest<List<Map<String, dynamic>>>(
      method: 'GET',
      endpoint: '/marches',
      fromJson: (json) => (json as List).cast<Map<String, dynamic>>(),
    );
    
    if (response.success && response.data != null) {
      return response.data!.map((json) => Marche.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Échec du chargement des marchés');
    }
  }

  // Récupérer un marché par son ID
  Future<Marche> getMarcheById(String id) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/marches/$id',
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return Marche.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec du chargement du marché');
    }
  }

  // Créer un nouveau marché
  Future<Marche> createMarche(Marche marche) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/marches',
      body: marche.toJson(),
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return Marche.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec de la création du marché');
    }
  }

  // Mettre à jour un marché
  Future<Marche> updateMarche(String id, Marche marche) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'PUT',
      endpoint: '/marches/$id',
      body: marche.toJson(),
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return Marche.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Échec de la mise à jour du marché');
    }
  }

  // Supprimer un marché
  Future<bool> deleteMarche(String id) async {
    final response = await _apiClient.makeRequest<void>(
      method: 'DELETE',
      endpoint: '/marches/$id',
    );
    
    if (response.success) {
      return true;
    } else {
      throw Exception(response.message ?? 'Échec de la suppression du marché');
    }
  }

  // Soumettre une offre pour un marché
  Future<bool> soumettreOffre(String marcheId, Map<String, dynamic> offre) async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'POST',
      endpoint: '/marches/$marcheId/soumissions',
      body: offre,
      fromJson: (json) => json,
    );
    
    if (response.success) {
      return true;
    } else {
      throw Exception(response.message ?? 'Échec de la soumission de l\'offre');
    }
  }

  // Obtenir les statistiques des marchés
  Future<Map<String, dynamic>> getStatistiques() async {
    final response = await _apiClient.makeRequest<Map<String, dynamic>>(
      method: 'GET',
      endpoint: '/marches/statistiques',
      fromJson: (json) => json,
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Échec du chargement des statistiques des marchés');
    }
  }
}
