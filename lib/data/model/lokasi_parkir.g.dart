// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lokasi_parkir.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LokasiParkirAdapter extends TypeAdapter<LokasiParkir> {
  @override
  final int typeId = 2;

  @override
  LokasiParkir read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LokasiParkir(
      id: fields[0] as int,
      namaLokasi: fields[1] as String,
      alamatLokasi: fields[2] as String,
      lat: fields[3] as String,
      long: fields[4] as String,
      areaLatlong: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LokasiParkir obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaLokasi)
      ..writeByte(2)
      ..write(obj.alamatLokasi)
      ..writeByte(3)
      ..write(obj.lat)
      ..writeByte(4)
      ..write(obj.long)
      ..writeByte(5)
      ..write(obj.areaLatlong);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LokasiParkirAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
