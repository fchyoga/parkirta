import 'dart:convert';

SubmitArriveResponse submitArriveResponseFromJson(String str) => SubmitArriveResponse.fromJson(json.decode(str));

String submitArriveResponseToJson(SubmitArriveResponse data) => json.encode(data.toJson());

class SubmitArriveResponse {
    bool success;
    SubmitArrival? data;
    String message;

    SubmitArriveResponse({
        required this.success,
        this.data,
        required this.message,
    });

    factory SubmitArriveResponse.fromJson(Map<String, dynamic> json) => SubmitArriveResponse(
        success: json["success"],
        data: json["data"]==null ? null : SubmitArrival.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
    };
}

class SubmitArrival {
    int idRetribusiParkir;
    int idPelanggan;
    String idLokasiParkir;
    String lat;
    String long;
    String statusParkir;

    SubmitArrival({
        required this.idRetribusiParkir,
        required this.idPelanggan,
        required this.idLokasiParkir,
        required this.lat,
        required this.long,
        required this.statusParkir,
    });

    factory SubmitArrival.fromJson(Map<String, dynamic> json) => SubmitArrival(
        idRetribusiParkir: json["id_retribusi_parkir"],
        idPelanggan: json["id_pelanggan"],
        idLokasiParkir: json["id_lokasi_parkir"],
        lat: json["lat"],
        long: json["long"],
        statusParkir: json["status_parkir"],
    );

    Map<String, dynamic> toJson() => {
        "id_retribusi_parkir": idRetribusiParkir,
        "id_pelanggan": idPelanggan,
        "id_lokasi_parkir": idLokasiParkir,
        "lat": lat,
        "long": long,
        "status_parkir": statusParkir,
    };
}
