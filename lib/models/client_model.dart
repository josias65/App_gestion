import 'package:hive/hive.dart';

part 'client_model.g.dart';

@HiveType(typeId: 0)
class ClientModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String company;
  
  @HiveField(3)
  String status;
  
  @HiveField(4)
  double revenue;

  ClientModel({
    required this.id,
    required this.name,
    required this.company,
    required this.status,
    required this.revenue,
  });
}
