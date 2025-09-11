import 'package:appgestion/models/order.dart';
import 'package:appgestion/services/api_service.dart';
import 'package:appgestion/services/response/api_response.dart';

class OrderService {
  final ApiService _apiService = ApiService();
  final String _basePath = '/api/v1/orders';

  // Récupérer toutes les commandes
  Future<ApiResponse<List<Order>>> getOrders() async {
    return _apiService.get<List<Order>>(
      _basePath,
      fromJson: (json) => (json as List)
          .map((item) => Order.fromJson(item))
          .toList(),
    );
  }

  // Créer une nouvelle commande
  Future<ApiResponse<Order>> createOrder(Order order) async {
    return _apiService.post<Order>(
      _basePath,
      body: order.toJson(),
      fromJson: (json) => Order.fromJson(json),
    );
  }

  // Mettre à jour le statut d'une commande
  Future<ApiResponse<Order>> updateOrderStatus(String id, String status) async {
    return _apiService.put<Order>(
      '$_basePath/$id/status',
      body: {'status': status},
      fromJson: (json) => Order.fromJson(json),
    );
  }

  // Récupérer une commande par son ID
  Future<ApiResponse<Order>> getOrder(String id) async {
    return _apiService.get<Order>(
      '$_basePath/$id',
      fromJson: (json) => Order.fromJson(json),
    );
  }
}
