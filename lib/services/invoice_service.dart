import 'package:appgestion/config/api_config.dart';
import 'package:appgestion/models/invoice.dart';
import 'package:appgestion/services/api_service.dart';
import 'package:appgestion/services/response/api_response.dart';

class InvoiceService {
  final ApiService _apiService = ApiService();

  // Récupérer la liste des factures d'acompte
  Future<ApiResponse<List<Invoice>>> getDepositInvoices() async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.facturesEndpoint}/acompte',
      ) as Map<String, dynamic>;
      
      final invoices = (response['data'] as List)
          .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(invoices);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des factures d\'acompte: $e');
    }
  }

  // Créer une nouvelle facture d'acompte
  Future<ApiResponse<Invoice>> createDepositInvoice(Map<String, dynamic> invoiceData) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.facturesEndpoint}/acompte',
        body: invoiceData,
      ) as Map<String, dynamic>;
      
      final invoice = Invoice.fromJson(response['data'] as Map<String, dynamic>);
      return ApiResponse.success(invoice);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la création de la facture d\'acompte: $e');
    }
  }

  // Récupérer la liste des factures définitives
  Future<ApiResponse<List<Invoice>>> getFinalInvoices() async {
    try {
      final response = await _apiService.get(
        ApiConfig.facturesEndpoint,
      ) as Map<String, dynamic>;
      
      final invoices = (response['data'] as List)
          .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(invoices);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des factures définitives: $e');
    }
  }

  // Créer une nouvelle facture définitive
  Future<ApiResponse<Invoice>> createFinalInvoice(Map<String, dynamic> invoiceData) async {
    try {
      final response = await _apiService.post(
        ApiConfig.facturesEndpoint,
        body: invoiceData,
      ) as Map<String, dynamic>;
      
      final invoice = Invoice.fromJson(response['data'] as Map<String, dynamic>);
      return ApiResponse.success(invoice);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la création de la facture définitive: $e');
    }
  }

  // Télécharger une facture au format PDF
  Future<ApiResponse<String>> downloadInvoicePdf(String invoiceId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.facturesEndpoint}/$invoiceId/download',
      ) as Map<String, dynamic>;
      
      final pdfUrl = response['data']['pdf_url'] as String;
      return ApiResponse.success(pdfUrl);
    } catch (e) {
      return ApiResponse.error('Erreur lors du téléchargement du PDF: $e');
    }
  }
}
