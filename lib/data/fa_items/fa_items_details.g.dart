// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fa_items_details.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FaItemsDetailsAdapter extends TypeAdapter<FaItemsDetails> {
  @override
  final int typeId = 1;

  @override
  FaItemsDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FaItemsDetails(
      itemId: fields[0] as int,
      itemDesc: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FaItemsDetails obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.itemDesc);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaItemsDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
