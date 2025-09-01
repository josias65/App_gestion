import 'package:appgestion/config/api_config.dart';
import 'package:appgestion/models/order.dart';
import 'package:appgestion/services/api_service.dart';
import 'package:appgestion/services/response/api_response.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  // Récupérer la liste des commandes
  Future<ApiResponse<List<Order>>> getOrders() async {
    try {
      final response = await _apiService.get(
        ApiConfig.commandesEndpoint,
      ) as Map<String, dynamic>;
      
      final orders = (response['data'] as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(orders);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des commandes: $e');
    }
  }

  // Créer une nouvelle commande
  Future<ApiResponse<Order>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _apiService.post(
        ApiConfig.commandesEndpoint,
        body: orderData,
      ) as Map<String, dynamic>;
      
      final order = Order.fromJson(response['data'] as Map<String, dynamic>);
      return ApiResponse.success(order);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la création de la commande: $e');
    }
  }

  // Mettre à jour le statut d'une commande
  Future<ApiResponse<Order>> updateOrderStatus(String id, String status) async {
    try {
      final response = await _apiService.patch(
        '${ApiConfig.commandesEndpoint}/$id',
        body: {'status': status},
      ) as Map<String, dynamic>;
      
      final order = Order.fromJson(response['data'] as Map<String, dynamic>);
      return ApiResponse.success(order);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la mise à jour du statut de la commande: $e');
    }
  }
}
