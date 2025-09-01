class Article {
  final String id;
  final String code;
  final String name;
  final String description;
  final double price;
  final String? unit;
  final int stockQuantity;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    this.unit,
    required this.stockQuantity,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String?,
      stockQuantity: json['stock_quantity'] as int,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'stock_quantity': stockQuantity,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
