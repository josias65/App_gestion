import 'package:appgestion/config/api_config.dart';
import 'package:appgestion/models/delivery.dart';
import 'package:appgestion/services/api_service.dart';
import 'package:appgestion/services/response/api_response.dart';

class DeliveryService {
  final ApiService _apiService = ApiService();

  // Récupérer la liste des livraisons
  Future<ApiResponse<List<Delivery>>> getDeliveries() async {
    try {
      final response = await _apiService.get(
        ApiConfig.livraisonsEndpoint,
      ) as Map<String, dynamic>;
      
      final deliveries = (response['data'] as List)
          .map((e) => Delivery.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(deliveries);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des livraisons: $e');
    }
  }

  // Créer une nouvelle livraison
  Future<ApiResponse<Delivery>> createDelivery(Map<String, dynamic> deliveryData) async {
    try {
      final response = await _apiService.post(
        ApiConfig.livraisonsEndpoint,
        body: deliveryData,
      ) as Map<String, dynamic>;
      
      final delivery = Delivery.fromJson(response['data'] as Map<String, dynamic>);
      return ApiResponse.success(delivery);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la création de la livraison: $e');
    }
  }

  // Mettre à jour le statut d'une livraison
  Future<ApiResponse<Delivery>> updateDeliveryStatus(String id, String status) async {
    try {
      final response = await _apiService.patch(
        '${ApiConfig.livraisonsEndpoint}/$id',
        body: {'status': status},
      ) as Map<String, dynamic>;
      
      final delivery = Delivery.fromJson(response['data'] as Map<String, dynamic>);
      return ApiResponse.success(delivery);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la mise à jour du statut de la livraison: $e');
    }
  }

  // Récupérer les détails d'une livraison
  Future<ApiResponse<Delivery>> getDeliveryDetails(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.livraisonsEndpoint}/$id',
      ) as Map<String, dynamic>;
      
      final delivery = Delivery.fromJson(response['data'] as Map<String, dynamic>);
      return ApiResponse.success(delivery);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des détails de la livraison: $e');
    }
  }
}
