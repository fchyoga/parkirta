// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retribusi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RetribusiAdapter extends TypeAdapter<Retribusi> {
  @override
  final int typeId = 0;

  @override
  Retribusi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Retribusi(
      id: fields[0] as int,
      idPelanggan: fields[1] as int,
      idJukir: fields[2] as int?,
      idLokasiParkir: fields[3] as int,
      lat: fields[4] as String,
      long: fields[5] as String,
      nopol: fields[6] as String?,
      statusParkir: fields[7] as String,
      createdAt: fields[8] as DateTime,
      pelanggan: fields[9] as Member?,
      lokasiParkir: fields[10] as LokasiParkir?,
      biayaParkir: fields[11] as BiayaParkir?,
    );
  }

  @override
  void write(BinaryWriter writer, Retribusi obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idPelanggan)
      ..writeByte(2)
      ..write(obj.idJukir)
      ..writeByte(3)
      ..write(obj.idLokasiParkir)
      ..writeByte(4)
      ..write(obj.lat)
      ..writeByte(5)
      ..write(obj.long)
      ..writeByte(6)
      ..write(obj.nopol)
      ..writeByte(7)
      ..write(obj.statusParkir)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.pelanggan)
      ..writeByte(10)
      ..write(obj.lokasiParkir)
      ..writeByte(11)
      ..write(obj.biayaParkir);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetribusiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
