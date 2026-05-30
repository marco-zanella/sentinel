// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipientGroupAdapter extends TypeAdapter<RecipientGroup> {
  @override
  final int typeId = 2;

  @override
  RecipientGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipientGroup(
      name: fields[0] as String,
      recipients: (fields[1] as List?)?.cast<dynamic>(),
      policyValue: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecipientGroup obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.recipients)
      ..writeByte(2)
      ..write(obj.policyValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipientGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
