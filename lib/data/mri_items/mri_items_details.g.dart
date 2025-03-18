// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mri_items_details.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MriItemsDetailsAdapter extends TypeAdapter<MriItemsDetails> {
  @override
  final int typeId = 2;

  @override
  MriItemsDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MriItemsDetails(
      itemId: fields[0] as int,
      onHandQty: fields[1] as double,
      glAccountId: fields[2] as int,
      qty: fields[3] as double,
      itemRemark: fields[4] as String,
      faItemId: fields[5] as int,
      dimensionId: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MriItemsDetails obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.onHandQty)
      ..writeByte(2)
      ..write(obj.glAccountId)
      ..writeByte(3)
      ..write(obj.qty)
      ..writeByte(4)
      ..write(obj.itemRemark)
      ..writeByte(5)
      ..write(obj.faItemId)
      ..writeByte(6)
      ..write(obj.dimensionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MriItemsDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
