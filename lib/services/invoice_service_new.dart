import 'package:appgestion/models/invoice.dart';
import 'package:appgestion/services/api_service.dart';
import 'package:appgestion/services/response/api_response.dart';

class InvoiceService {
  final ApiService _apiService = ApiService();
  final String _basePath = '/api/v1/invoices';

  // Récupérer toutes les factures
  Future<ApiResponse<List<Invoice>>> getInvoices({String? status}) async {
    final path = status != null ? '$_basePath?status=$status' : _basePath;
    
    return _apiService.get<List<Invoice>>(
      path,
      fromJson: (json) => (json as List)
          .map((item) => Invoice.fromJson(item))
          .toList(),
    );
  }

  // Créer une nouvelle facture
  Future<ApiResponse<Invoice>> createInvoice(Invoice invoice) async {
    return _apiService.post<Invoice>(
      _basePath,
      body: invoice.toJson(),
      fromJson: (json) => Invoice.fromJson(json),
    );
  }

  // Marquer une facture comme payée
  Future<ApiResponse<Invoice>> markAsPaid(String id) async {
    return _apiService.post<Invoice>(
      '$_basePath/$id/pay',
      fromJson: (json) => Invoice.fromJson(json),
    );
  }

  // Récupérer une facture par son ID
  Future<ApiResponse<Invoice>> getInvoice(String id) async {
    return _apiService.get<Invoice>(
      '$_basePath/$id',
      fromJson: (json) => Invoice.fromJson(json),
    );
  }
}
