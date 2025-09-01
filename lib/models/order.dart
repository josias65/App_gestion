import 'package:appgestion/models/customer.dart';
import 'package:appgestion/models/proforma.dart';

class OrderItem {
  final String id;
  final String articleId;
  final String articleName;
  final String? articleCode;
  final int quantity;
  final double unitPrice;
  final double total;
  final double? discount;
  final String? notes;

  OrderItem({
    required this.id,
    required this.articleId,
    required this.articleName,
    this.articleCode,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.discount,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      articleId: json['article_id'] as String,
      articleName: json['article_name'] as String,
      articleCode: json['article_code'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'article_id': articleId,
      'article_name': articleName,
      if (articleCode != null) 'article_code': articleCode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': total,
      if (discount != null) 'discount': discount,
      if (notes != null) 'notes': notes,
    };
  }
}

class Order {
  final String id;
  final String orderNumber;
  final Customer customer;
  final Proforma? proforma;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final String status;
  final double subtotal;
  final double total;
  final double? discount;
  final double? tax;
  final String? notes;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customer,
    this.proforma,
    required this.orderDate,
    this.expectedDeliveryDate,
    required this.status,
    required this.subtotal,
    required this.total,
    this.discount,
    this.tax,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
      proforma: json['proforma'] != null 
          ? Proforma.fromJson(json['proforma'] as Map<String, dynamic>)
          : null,
      orderDate: DateTime.parse(json['order_date'] as String),
      expectedDeliveryDate: json['expected_delivery_date'] != null
          ? DateTime.parse(json['expected_delivery_date'] as String)
          : null,
      status: json['status'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      tax: json['tax'] != null ? (json['tax'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer': customer.toJson(),
      if (proforma != null) 'proforma': proforma!.toJson(),
      'order_date': orderDate.toIso8601String(),
      if (expectedDeliveryDate != null)
        'expected_delivery_date': expectedDeliveryDate!.toIso8601String(),
      'status': status,
      'subtotal': subtotal,
      'total': total,
      if (discount != null) 'discount': discount,
      if (tax != null) 'tax': tax,
      if (notes != null) 'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
