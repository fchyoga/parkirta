import 'dart:convert';

PaymentEntryResponse paymentEntryResponseFromJson(String str) => PaymentEntryResponse.fromJson(json.decode(str));

String paymentEntryResponseToJson(PaymentEntryResponse data) => json.encode(data.toJson());

class PaymentEntryResponse {
    bool success;
    PaymentEntryData? data;
    String message;

    PaymentEntryResponse({
        required this.success,
        this.data,
        required this.message,
    });

    factory PaymentEntryResponse.fromJson(Map<String, dynamic> json) => PaymentEntryResponse(
        success: json["success"],
        data: json["data"]!=null ? PaymentEntryData.fromJson(json["data"]): null,
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
    };
}

class PaymentEntryData {
    PaymentEntry pembayaran;

    PaymentEntryData({
        required this.pembayaran,
    });

    factory PaymentEntryData.fromJson(Map<String, dynamic> json) => PaymentEntryData(
        pembayaran: PaymentEntry.fromJson(json["pembayaran"]),
    );

    Map<String, dynamic> toJson() => {
        "pembayaran": pembayaran.toJson(),
    };
}

class PaymentEntry {
    int idRetribusiParkir;
    String noInvoice;
    String isViaJukir;
    int grossAmount;
    String status;

    PaymentEntry({
        required this.idRetribusiParkir,
        required this.noInvoice,
        required this.isViaJukir,
        required this.grossAmount,
        required this.status,
    });

    factory PaymentEntry.fromJson(Map<String, dynamic> json) => PaymentEntry(
        idRetribusiParkir: json["id_retribusi_parkir"],
        noInvoice: json["no_invoice"],
        isViaJukir: json["is_via_jukir"],
        grossAmount: json["gross_amount"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id_retribusi_parkir": idRetribusiParkir,
        "no_invoice": noInvoice,
        "is_via_jukir": isViaJukir,
        "gross_amount": grossAmount,
        "status": status,
    };
}

