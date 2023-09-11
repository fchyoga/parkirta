// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biaya_parkir.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BiayaParkirAdapter extends TypeAdapter<BiayaParkir> {
  @override
  final int typeId = 3;

  @override
  BiayaParkir read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BiayaParkir(
      id: fields[0] as int,
      idLokasiParkir: fields[1] as int,
      kendaraan: fields[2] as String,
      biayaParkir: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BiayaParkir obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idLokasiParkir)
      ..writeByte(2)
      ..write(obj.kendaraan)
      ..writeByte(3)
      ..write(obj.biayaParkir);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiayaParkirAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
