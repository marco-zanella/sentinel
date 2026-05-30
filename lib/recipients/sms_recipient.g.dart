// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_recipient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SmsRecipientAdapter extends TypeAdapter<SmsRecipient> {
  @override
  final int typeId = 0;

  @override
  SmsRecipient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmsRecipient(
      label: fields[0] as String,
      phoneNumber: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SmsRecipient obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.phoneNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmsRecipientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
