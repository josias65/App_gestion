import 'package:appgestion/config/api_config.dart';
import 'package:appgestion/models/models.dart';
import 'package:appgestion/services/api_service.dart';
import 'package:appgestion/services/response/api_response.dart';

class CustomerService {
  final ApiService _apiService = ApiService();

  // Récupérer la liste des clients
  Future<ApiResponse<List<Customer>>> getCustomers() async {
    try {
      final response = await _apiService.get(
        ApiConfig.clientsEndpoint,
      ) as Map<String, dynamic>;
      
      final customers = (response['data'] as List)
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(customers);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des clients: $e');
    }
  }

  // Récupérer les statistiques des clients
  Future<ApiResponse<Map<String, dynamic>>> getCustomerStats() async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.clientsEndpoint}/stats',
      ) as Map<String, dynamic>;
      
      return ApiResponse.success(response);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des statistiques: $e');
    }
  }

  // Créer un nouveau client
  Future<ApiResponse<Customer>> createCustomer(Map<String, dynamic> customerData) async {
    try {
      final response = await _apiService.post(
        ApiConfig.clientsEndpoint,
        body: customerData,
      ) as Map<String, dynamic>;
      
      return ApiResponse.success(Customer.fromJson(response));
    } catch (e) {
      return ApiResponse.error('Erreur lors de la création du client: $e');
    }
  }

  // Mettre à jour un client existant
  Future<ApiResponse<Customer>> updateCustomer(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.clientsEndpoint}/$id',
        body: updates,
      ) as Map<String, dynamic>;
      
      return ApiResponse.success(Customer.fromJson(response));
    } catch (e) {
      return ApiResponse.error('Erreur lors de la mise à jour du client: $e');
    }
  }

  // Supprimer un client
  Future<ApiResponse<void>> deleteCustomer(String id) async {
    try {
      await _apiService.delete(
        '${ApiConfig.clientsEndpoint}/$id',
      );
      
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la suppression du client: $e');
    }
  }
}
