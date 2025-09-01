import 'package:appgestion/config/api_config.dart';
import 'package:appgestion/models/article.dart';
import 'package:appgestion/services/api_service.dart';
import 'package:appgestion/services/response/api_response.dart';

class ArticleService {
  final ApiService _apiService = ApiService();

  // Récupérer la liste des articles
  Future<ApiResponse<List<Article>>> getArticles() async {
    try {
      final response = await _apiService.get(
        ApiConfig.articlesEndpoint,
      ) as Map<String, dynamic>;
      
      final articles = (response['data'] as List)
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(articles);
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des articles: $e');
    }
  }
}
