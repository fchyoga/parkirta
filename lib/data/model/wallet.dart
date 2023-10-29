class Wallet {
  int saldoPelanggan;
  String saldoKartuParkir;

  Wallet({
    required this.saldoPelanggan,
    required this.saldoKartuParkir,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        saldoPelanggan: json["saldo_pelanggan"],
        saldoKartuParkir: json["saldo_kartu_parkir"],
      );

  Map<String, dynamic> toJson() => {
        "saldo_pelanggan": saldoPelanggan,
        "saldo_kartu_parkir": saldoKartuParkir,
      };
}
