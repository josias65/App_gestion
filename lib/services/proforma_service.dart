import 'package:appgestion/config/api_config.dart';
import 'package:appgestion/models/proforma.dart';
import 'package:appgestion/services/api_service.dart';
import 'package:appgestion/services/response/api_response.dart';

class ProformaService {
  final ApiService _apiService = ApiService();

  // Récupérer la liste des factures pro forma
  Future<ApiResponse<List<Proforma>>> getProformas() async {
    try {
      final response = await _apiService.get(
        ApiConfig.proformasEndpoint,
      ) as Map<String, dynamic>;
      
      final proformas = (response['data'] as List)
          .map((e) => Proforma.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(proformas);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des proformas: $e');
    }
  }

  // Créer une nouvelle facture pro forma
  Future<ApiResponse<Proforma>> createProforma(Map<String, dynamic> proformaData) async {
    try {
      final response = await _apiService.post(
        ApiConfig.proformasEndpoint,
        body: proformaData,
      ) as Map<String, dynamic>;
      
      final proforma = Proforma.fromJson(response['data'] as Map<String, dynamic>);
      return ApiResponse.success(proforma);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la création de la proforma: $e');
    }
  }

  // Récupérer une facture pro forma par son ID
  Future<ApiResponse<Proforma>> getProformaById(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.proformasEndpoint}/$id',
      ) as Map<String, dynamic>;
      
      final proforma = Proforma.fromJson(response['data'] as Map<String, dynamic>);
      return ApiResponse.success(proforma);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération de la proforma: $e');
    }
  }
}
