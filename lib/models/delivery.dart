import 'package:appgestion/models/customer.dart';
import 'package:appgestion/models/order.dart';

class DeliveryItem {
  final String id;
  final String articleId;
  final String articleName;
  final String? articleCode;
  final int quantity;
  final int? quantityDelivered;
  final String? serialNumber;
  final String? batchNumber;
  final String? notes;

  DeliveryItem({
    required this.id,
    required this.articleId,
    required this.articleName,
    this.articleCode,
    required this.quantity,
    this.quantityDelivered,
    this.serialNumber,
    this.batchNumber,
    this.notes,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      id: json['id'] as String,
      articleId: json['article_id'] as String,
      articleName: json['article_name'] as String,
      articleCode: json['article_code'] as String?,
      quantity: json['quantity'] as int,
      quantityDelivered: json['quantity_delivered'] as int?,
      serialNumber: json['serial_number'] as String?,
      batchNumber: json['batch_number'] as String?,
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
      if (quantityDelivered != null) 'quantity_delivered': quantityDelivered,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (notes != null) 'notes': notes,
    };
  }
}

class Delivery {
  final String id;
  final String deliveryNumber;
  final Order order;
  final Customer customer;
  final DateTime deliveryDate;
  final String status; // 'preparing', 'in_transit', 'delivered', 'partially_delivered', 'cancelled'
  final String? trackingNumber;
  final String? carrier;
  final String? deliveryAddress;
  final String? contactPerson;
  final String? contactPhone;
  final String? notes;
  final List<DeliveryItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Delivery({
    required this.id,
    required this.deliveryNumber,
    required this.order,
    required this.customer,
    required this.deliveryDate,
    required this.status,
    this.trackingNumber,
    this.carrier,
    this.deliveryAddress,
    this.contactPerson,
    this.contactPhone,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      deliveryNumber: json['delivery_number'] as String,
      order: Order.fromJson(json['order'] as Map<String, dynamic>),
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
      deliveryDate: DateTime.parse(json['delivery_date'] as String),
      status: json['status'] as String,
      trackingNumber: json['tracking_number'] as String?,
      carrier: json['carrier'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      contactPerson: json['contact_person'] as String?,
      contactPhone: json['contact_phone'] as String?,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => DeliveryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delivery_number': deliveryNumber,
      'order': order.toJson(),
      'customer': customer.toJson(),
      'delivery_date': deliveryDate.toIso8601String(),
      'status': status,
      if (trackingNumber != null) 'tracking_number': trackingNumber,
      if (carrier != null) 'carrier': carrier,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (notes != null) 'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Méthode pour vérifier si la livraison est complète
  bool get isComplete {
    return status == 'delivered' || status == 'partially_delivered';
  }

  // Méthode pour obtenir la quantité totale d'articles livrés
  int get totalItemsDelivered {
    return items.fold(0, (sum, item) => sum + (item.quantityDelivered ?? 0));
  }
}
