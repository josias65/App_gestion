import 'package:hive/hive.dart';

part 'article.g.dart';

@HiveType(typeId: 2)
class Article extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String code;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final double price;
  
  @HiveField(5)
  final String? unit;
  
  @HiveField(6)
  int stockQuantity;
  
  @HiveField(7)
  final String? category;
  
  @HiveField(8)
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    this.unit,
    this.stockQuantity = 0,
    this.category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String?,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      category: json['category'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
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
