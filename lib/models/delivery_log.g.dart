// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryLogAdapter extends TypeAdapter<DeliveryLog> {
  @override
  final int typeId = 4;

  @override
  DeliveryLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeliveryLog(
      timestamp: fields[0] as DateTime,
      success: fields[1] as bool,
      message: fields[2] as String,
      coords: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.success)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.coords);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
