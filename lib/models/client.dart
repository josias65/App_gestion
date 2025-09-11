import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 0)
class Client extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? phone;

  @HiveField(4)
  String? address;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    DateTime? createdAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = DateTime.now();

  // Convertir en Map pour la sérialisation
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Créer un Client à partir d'un Map
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      createdAt: DateTime.parse(map['createdAt']),
    )..updatedAt = DateTime.parse(map['updatedAt']);
  }
}
