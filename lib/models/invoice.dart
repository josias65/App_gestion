import 'package:appgestion/models/customer.dart';
import 'package:appgestion/models/order.dart';

class InvoiceItem {
  final String id;
  final String articleId;
  final String articleName;
  final String? articleCode;
  final int quantity;
  final double unitPrice;
  final double total;
  final double? discount;
  final double? taxRate;
  final double? taxAmount;

  InvoiceItem({
    required this.id,
    required this.articleId,
    required this.articleName,
    this.articleCode,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.discount,
    this.taxRate,
    this.taxAmount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String,
      articleId: json['article_id'] as String,
      articleName: json['article_name'] as String,
      articleCode: json['article_code'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      taxRate: json['tax_rate'] != null ? (json['tax_rate'] as num).toDouble() : null,
      taxAmount: json['tax_amount'] != null ? (json['tax_amount'] as num).toDouble() : null,
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
      if (taxRate != null) 'tax_rate': taxRate,
      if (taxAmount != null) 'tax_amount': taxAmount,
    };
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String type; // 'acompte' ou 'definitive'
  final Customer customer;
  final Order? order;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status; // 'draft', 'sent', 'paid', 'overdue', 'cancelled'
  final double subtotal;
  final double total;
  final double? discount;
  final double? tax;
  final double? amountPaid;
  final double? balanceDue;
  final String? notes;
  final String? paymentTerms;
  final List<InvoiceItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    required this.customer,
    this.order,
    required this.issueDate,
    required this.dueDate,
    this.paidDate,
    required this.status,
    required this.subtotal,
    required this.total,
    this.discount,
    this.tax,
    this.amountPaid,
    this.balanceDue,
    this.notes,
    this.paymentTerms,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      type: json['type'] as String,
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
      order: json['order'] != null 
          ? Order.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      paidDate: json['paid_date'] != null 
          ? DateTime.parse(json['paid_date'] as String)
          : null,
      status: json['status'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      tax: json['tax'] != null ? (json['tax'] as num).toDouble() : null,
      amountPaid: json['amount_paid'] != null ? (json['amount_paid'] as num).toDouble() : null,
      balanceDue: json['balance_due'] != null ? (json['balance_due'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      paymentTerms: json['payment_terms'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'type': type,
      'customer': customer.toJson(),
      if (order != null) 'order': order!.toJson(),
      'issue_date': issueDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      if (paidDate != null) 'paid_date': paidDate!.toIso8601String(),
      'status': status,
      'subtotal': subtotal,
      'total': total,
      if (discount != null) 'discount': discount,
      if (tax != null) 'tax': tax,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (balanceDue != null) 'balance_due': balanceDue,
      if (notes != null) 'notes': notes,
      if (paymentTerms != null) 'payment_terms': paymentTerms,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Méthode pour vérifier si la facture est en retard
  bool get isOverdue {
    if (status == 'paid' || status == 'cancelled') return false;
    return DateTime.now().isAfter(dueDate);
  }

  // Méthode pour calculer le solde restant
  double get remainingBalance {
    return balanceDue ?? (total - (amountPaid ?? 0));
  }
}
