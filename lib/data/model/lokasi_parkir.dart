class LokasiParkir {
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

    LokasiParkir({
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
    });

    factory LokasiParkir.fromJson(Map<String, dynamic> json) => LokasiParkir(
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
    };
}