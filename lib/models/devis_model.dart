class DevisModel {
  final String reference;
  final String client;
  final String date;
  final String status;
  final double total;
  final List<Map<String, dynamic>> articles;

  DevisModel({
    required this.reference,
    required this.client,
    required this.date,
    required this.status,
    required this.total,
    this.articles = const [],
  });

  factory DevisModel.fromJson(Map<String, dynamic> json) {
    return DevisModel(
      reference: json['reference'] as String,
      client: json['client'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      articles:
          (json['articles'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'client': client,
      'date': date,
      'status': status,
      'total': total,
      'articles': articles,
    };
  }

  double get totalFromArticles {
    if (articles.isEmpty) {
      return total;
    }
    return articles.fold(0.0, (sum, article) {
      final qte = (article['quantite'] as num?) ?? 1;
      final prix = (article['prix'] as num?) ?? 0;
      return sum + (qte * prix);
    });
  }
}
