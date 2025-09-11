import 'package:appgestion/models/article.dart';
import 'package:appgestion/services/api_service.dart';
import 'package:appgestion/services/response/api_response.dart';

class ArticleService {
  final ApiService _apiService = ApiService();
  final String _basePath = '/api/v1/articles';

  // Récupérer tous les articles
  Future<ApiResponse<List<Article>>> getArticles() async {
    return _apiService.get<List<Article>>(
      _basePath,
      fromJson: (json) => (json as List)
          .map((item) => Article.fromJson(item))
          .toList(),
    );
  }

  // Récupérer un article par son ID
  Future<ApiResponse<Article>> getArticle(String id) async {
    return _apiService.get<Article>(
      '$_basePath/$id',
      fromJson: (json) => Article.fromJson(json),
    );
  }

  // Créer un nouvel article
  Future<ApiResponse<Article>> createArticle(Article article) async {
    return _apiService.post<Article>(
      _basePath,
      body: article.toJson(),
      fromJson: (json) => Article.fromJson(json),
    );
  }

  // Mettre à jour un article
  Future<ApiResponse<Article>> updateArticle(String id, Article article) async {
    return _apiService.put<Article>(
      '$_basePath/$id',
      body: article.toJson(),
      fromJson: (json) => Article.fromJson(json),
    );
  }

  // Supprimer un article
  Future<ApiResponse<void>> deleteArticle(String id) async {
    return _apiService.delete('$_basePath/$id');
  }
}
