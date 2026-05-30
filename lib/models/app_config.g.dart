// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppConfigAdapter extends TypeAdapter<AppConfig> {
  @override
  final int typeId = 3;

  @override
  AppConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppConfig(
      groups: (fields[0] as List?)?.cast<RecipientGroup>(),
      intervalMinutes: fields[1] as int,
      isTracking: fields[2] as bool,
      deviceName: fields[3] as String?,
      lastDeliveryAt: fields[4] as DateTime?,
      lastDeliverySuccess: fields[5] as bool?,
      lastDeliveryMessage: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppConfig obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.groups)
      ..writeByte(1)
      ..write(obj.intervalMinutes)
      ..writeByte(2)
      ..write(obj.isTracking)
      ..writeByte(3)
      ..write(obj.deviceName)
      ..writeByte(4)
      ..write(obj.lastDeliveryAt)
      ..writeByte(5)
      ..write(obj.lastDeliverySuccess)
      ..writeByte(6)
      ..write(obj.lastDeliveryMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
