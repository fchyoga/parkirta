import 'dart:convert';

import 'package:parkirta/data/model/wallet.dart';

WalletDetailResponse WalletDetailResponseFromJson(String str) =>
    WalletDetailResponse.fromJson(json.decode(str));

String WalletDetailResponseToJson(WalletDetailResponse data) =>
    json.encode(data.toJson());

class WalletDetailResponse {
  bool success;
  WalletDetail? data;
  String message;

  WalletDetailResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory WalletDetailResponse.fromJson(Map<String, dynamic> json) =>
      WalletDetailResponse(
        success: json["success"],
        data: json["data"] != null ? WalletDetail.fromJson(json["data"]) : null,
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

class WalletDetail {
  int saldoPelanggan;
  String saldoKartuParkir;

  WalletDetail({
    required this.saldoPelanggan,
    required this.saldoKartuParkir,
  });

  factory WalletDetail.fromJson(Map<String, dynamic> json) => WalletDetail(
        saldoPelanggan: json["saldo_pelanggan"],
        saldoKartuParkir: json["saldo_kartu_parkir"],
      );

  Map<String, dynamic> toJson() => {
        "saldo_pelanggan": saldoPelanggan,
        "saldo_kartu_parkir": saldoKartuParkir,
      };
}
