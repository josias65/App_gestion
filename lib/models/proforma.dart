import 'package:appgestion/models/customer.dart';

class ProformaItem {
  final String id;
  final String articleId;
  final String articleName;
  final String? articleDescription;
  final int quantity;
  final double unitPrice;
  final double total;
  final double? discount;
  final double? taxRate;

  ProformaItem({
    required this.id,
    required this.articleId,
    required this.articleName,
    this.articleDescription,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.discount,
    this.taxRate,
  });

  factory ProformaItem.fromJson(Map<String, dynamic> json) {
    return ProformaItem(
      id: json['id'] as String,
      articleId: json['article_id'] as String,
      articleName: json['article_name'] as String,
      articleDescription: json['article_description'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      taxRate: json['tax_rate'] != null ? (json['tax_rate'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'article_id': articleId,
      'article_name': articleName,
      if (articleDescription != null) 'article_description': articleDescription,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': total,
      if (discount != null) 'discount': discount,
      if (taxRate != null) 'tax_rate': taxRate,
    };
  }
}

class Proforma {
  final String id;
  final String number;
  final Customer customer;
  final DateTime issueDate;
  final DateTime dueDate;
  final double subtotal;
  final double total;
  final double? discount;
  final double? tax;
  final String status;
  final String? notes;
  final List<ProformaItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Proforma({
    required this.id,
    required this.number,
    required this.customer,
    required this.issueDate,
    required this.dueDate,
    required this.subtotal,
    required this.total,
    this.discount,
    this.tax,
    required this.status,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Proforma.fromJson(Map<String, dynamic> json) {
    return Proforma(
      id: json['id'] as String,
      number: json['number'] as String,
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      tax: json['tax'] != null ? (json['tax'] as num).toDouble() : null,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => ProformaItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'customer': customer.toJson(),
      'issue_date': issueDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'subtotal': subtotal,
      'total': total,
      if (discount != null) 'discount': discount,
      if (tax != null) 'tax': tax,
      'status': status,
      if (notes != null) 'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
