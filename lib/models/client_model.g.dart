// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClientModelAdapter extends TypeAdapter<ClientModel> {
  @override
  final int typeId = 0;

  @override
  ClientModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClientModel(
      id: fields[0] as String,
      name: fields[1] as String,
      company: fields[2] as String,
      status: fields[3] as String,
      revenue: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ClientModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.company)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.revenue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
