import 'dart:convert';

import 'package:parkirta/data/model/relasi_jukir.dart';

ParkingLocationDetailResponse parkingLocationDetailResponseFromJson(String str) => ParkingLocationDetailResponse.fromJson(json.decode(str));

String parkingLocationDetailResponseToJson(ParkingLocationDetailResponse ParkingLocationDetail) => json.encode(ParkingLocationDetail.toJson());

class ParkingLocationDetailResponse {
    bool success;
    ParkingLocationDetail? data;
    String message;

    ParkingLocationDetailResponse({
        required this.success,
        this.data,
        required this.message,
    });

    factory ParkingLocationDetailResponse.fromJson(Map<String, dynamic> json) => ParkingLocationDetailResponse(
        success: json["success"],
        data: json["data"]==null ? null: ParkingLocationDetail.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
    };
}

class ParkingLocationDetail {
    int id;
    String namaLokasi;
    String alamatLokasi;
    String lat;
    String long;
    String areaLatlong;
    String url;
    String status;
    String statusOperasional;
    DateTime createdAt;
    DateTime updatedAt;
    List<RelasiJukir> relasiJukir;

    ParkingLocationDetail({
        required this.id,
        required this.namaLokasi,
        required this.alamatLokasi,
        required this.lat,
        required this.long,
        required this.areaLatlong,
        required this.url,
        required this.status,
        required this.statusOperasional,
        required this.createdAt,
        required this.updatedAt,
        required this.relasiJukir,
    });

    factory ParkingLocationDetail.fromJson(Map<String, dynamic> json) => ParkingLocationDetail(
        id: json["id"],
        namaLokasi: json["nama_lokasi"],
        alamatLokasi: json["alamat_lokasi"],
        lat: json["lat"],
        long: json["long"],
        areaLatlong: json["area_latlong"],
        url: json["url"],
        status: json["status"],
        statusOperasional: json["status_operasional"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        relasiJukir: List<RelasiJukir>.from(json["relasi_jukir"].map((x) => RelasiJukir.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama_lokasi": namaLokasi,
        "alamat_lokasi": alamatLokasi,
        "lat": lat,
        "long": long,
        "area_latlong": areaLatlong,
        "url": url,
        "status": status,
        "status_operasional": statusOperasional,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "relasi_jukir": List<dynamic>.from(relasiJukir.map((x) => x.toJson())),
    };
}


