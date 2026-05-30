// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telegram_recipient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TelegramRecipientAdapter extends TypeAdapter<TelegramRecipient> {
  @override
  final int typeId = 1;

  @override
  TelegramRecipient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TelegramRecipient(
      label: fields[0] as String,
      botToken: fields[1] as String,
      chatId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TelegramRecipient obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.botToken)
      ..writeByte(2)
      ..write(obj.chatId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TelegramRecipientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
