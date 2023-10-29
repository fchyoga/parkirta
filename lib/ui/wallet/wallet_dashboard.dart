import 'package:flutter/material.dart';
import 'package:parkirta/color.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WalletDashboardPage extends StatefulWidget {
  @override
  State<WalletDashboardPage> createState() => _WalletDashboardPageState();
}

class _WalletDashboardPageState extends State<WalletDashboardPage> {
  List<Transaction> transactionHistory = [
    Transaction(
      icon: Icons.arrow_circle_down_rounded,
      title: 'Top Up',
      date: '20 Juni 2023',
      amount: 'Rp 50,000',
    ),
    Transaction(
      icon: Icons.arrow_circle_up_rounded,
      title: 'Transfer',
      date: '19 Juni 2023',
      amount: '-Rp 25,000',
    ),
    Transaction(
      icon: Icons.arrow_circle_up_rounded,
      title: 'Transfer',
      date: '18 Juni 2023',
      amount: '-Rp 30,000',
    ),
    Transaction(
      icon: Icons.arrow_circle_down_rounded,
      title: 'Top Up',
      date: '20 Juni 2023',
      amount: 'Rp 50,000',
    ),
    Transaction(
      icon: Icons.arrow_circle_up_rounded,
      title: 'Transfer',
      date: '19 Juni 2023',
      amount: '-Rp 25,000',
    ),
    Transaction(
      icon: Icons.arrow_circle_up_rounded,
      title: 'Transfer',
      date: '18 Juni 2023',
      amount: '-Rp 30,000',
    ),
    Transaction(
      icon: Icons.arrow_circle_down_rounded,
      title: 'Top Up',
      date: '20 Juni 2023',
      amount: 'Rp 50,000',
    ),
    Transaction(
      icon: Icons.arrow_circle_up_rounded,
      title: 'Transfer',
      date: '19 Juni 2023',
      amount: '-Rp 25,000',
    ),
    Transaction(
      icon: Icons.arrow_circle_up_rounded,
      title: 'Transfer',
      date: '18 Juni 2023',
      amount: '-Rp 30,000',
    ),
  ];

  int saldo = 0;

  Future<String?> getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchSaldo() async {
    String? token = await getTokenFromSharedPreferences();

    if (token == null) {
      // Token tidak tersedia, handle sesuai kebutuhan
      return;
    }

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/dompet/detail'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        saldo = responseData['data']['saldo_pelanggan'];
      });
    } else {
      throw Exception('Gagal mendapatkan data saldo');
    }
  }

  Future<void> getBalance() async {
    String? token = await getTokenFromSharedPreferences();

    if (token == null) {
      // Token tidak tersedia, handle sesuai kebutuhan
      return;
    }

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/dompet/detail'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Berhasil mendapatkan data saldo, lakukan sesuatu dengan respons
      final responseData = jsonDecode(response.body);
      final saldo = responseData['data']['saldo_pelanggan'];
      print('Saldo Pengguna: $saldo');
    } else {
      throw Exception('Gagal mendapatkan data saldo');
    }
  }

  Future<void> topUp() async {
    String? token = await getTokenFromSharedPreferences();

    if (token == null) {
      // Token tidak tersedia, handle sesuai kebutuhan
      return;
    }

    final requestBody = {
      // Isi sesuai kebutuhan dengan data untuk top up
    };

    final response = await http.post(
      Uri.parse('https://parkirta.com/api/dompet/topup/entry'),
      body: jsonEncode(requestBody),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Berhasil melakukan top up, lakukan sesuatu dengan respons
      final responseData = jsonDecode(response.body);
      // Proses respons sesuai kebutuhan
    } else {
      throw Exception('Gagal melakukan top up');
    }
  }

  // Fungsi untuk menampilkan dialog pilihan tujuan (akun/kartu)
  Future<void> _showTujuanDialog() async {
    String tujuan;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pilih Tujuan Top Up'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Akun'),
                onTap: () {
                  tujuan = 'akun';
                  Navigator.of(context).pop();
                  _showPaymentInfoDialog(double.tryParse("0"), tujuan, null);
                },
              ),
              ListTile(
                title: Text('Kartu'),
                onTap: () {
                  tujuan = 'kartu';
                  Navigator.of(context).pop();
                  _showIdKartuDialog(tujuan);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog input id kartu
  Future<void> _showIdKartuDialog(String tujuan) async {
    String? idKartu;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Masukkan ID Kartu'),
          content: TextField(
            onChanged: (value) {
              idKartu = value;
            },
            decoration: InputDecoration(
              hintText: 'Masukkan ID Kartu',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Panggil fungsi untuk melakukan top up
                _entryTopUp(tujuan, idKartu ?? "0");
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk melakukan entry top up
  Future<void> _entryTopUp(String tujuan, String? idKartu) async {
    double? jumlahTopUp;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Masukkan Jumlah Top Up'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              jumlahTopUp = double.tryParse(value);
            },
            decoration: InputDecoration(
              hintText: 'Masukkan Jumlah Top Up',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Panggil fungsi untuk menampilkan dialog pembayaran
                _showPaymentInfoDialog(jumlahTopUp, tujuan, idKartu);
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog pembayaran
  Future<void> _showPaymentInfoDialog(
      double? jumlahTopUp, String tujuan, String? idKartu) async {
    String? noTransaksi;
    String? tipePembayaran;
    String? bank;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Informasi Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  noTransaksi = value;
                },
                decoration: InputDecoration(
                  hintText: 'Masukkan No Transaksi',
                ),
              ),
              SizedBox(height: 8),
              TextField(
                onChanged: (value) {
                  tipePembayaran = value;
                },
                decoration: InputDecoration(
                  hintText: 'Masukkan Tipe Pembayaran (bank_transfer/gopay)',
                ),
              ),
              SizedBox(height: 8),
              TextField(
                onChanged: (value) {
                  bank = value;
                },
                decoration: InputDecoration(
                  hintText: 'Masukkan Bank (Jika menggunakan bank)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Panggil fungsi untuk melakukan pembayaran
                _payment(jumlahTopUp, tujuan, idKartu, noTransaksi,
                    tipePembayaran, bank);
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _payment(
    double? jumlahTopUp,
    String tujuan,
    String? idKartu,
    String? noTransaksi,
    String? tipePembayaran,
    String? bank,
  ) async {
    // Menyiapkan data untuk API
    final Map<String, dynamic> paymentData = {
      'no_invoice': noTransaksi,
      'payment_type': tipePembayaran,
      'bank': bank,
    };

    String? token = await getTokenFromSharedPreferences();

    try {
      final response = await http.post(
        Uri.parse('https://parkirta.com/api/dompet/topup/payment'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Gantikan dengan token Anda
        },
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200) {
        // Berhasil melakukan pembayaran, Anda dapat menanggapi hasil di sini
        final responseData = jsonDecode(response.body);
        // Proses hasil pembayaran sesuai kebutuhan aplikasi Anda
      } else {
        throw Exception('Failed to make payment');
      }
    } catch (error) {
      print('Error in payment: $error');
      // Handle error, misalnya tampilkan pesan kepada pengguna
    }
  }

  Future<void> _topUp(
    double? jumlahTopUp,
    String tujuan,
    String? idKartu,
  ) async {
    // Menyiapkan data untuk API
    final Map<String, dynamic> topUpData = {
      'tujuan': tujuan,
      'id_kartu_parkir': idKartu,
      'total_topup': jumlahTopUp.toString(),
    };

    String? token = await getTokenFromSharedPreferences();

    try {
      final response = await http.post(
        Uri.parse('https://parkirta.com/api/dompet/topup/entry'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Gantikan dengan token Anda
        },
        body: jsonEncode(topUpData),
      );

      if (response.statusCode == 200) {
        // Berhasil melakukan entry top up, Anda dapat menanggapi hasil di sini
        final responseData = jsonDecode(response.body);
        // Proses hasil entry top up sesuai kebutuhan aplikasi Anda
      } else {
        throw Exception('Failed to perform top up');
      }
    } catch (error) {
      print('Error in top up: $error');
      // Handle error, misalnya tampilkan pesan kepada pengguna
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSaldo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Gray100,
      appBar: AppBar(
        backgroundColor: Gray100,
        toolbarHeight: 84,
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Dompet Saya',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              fit: StackFit.passthrough,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                    bottom: 1,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 60,
                      height: 50,
                      margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: AppColors.colorPrimary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.colorPrimary.withOpacity(0.25),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    )),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Saldo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            'email@example.com', // Ganti dengan email dari data pengguna
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Rp ${saldo.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _showTujuanDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: Red500,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_rounded),
                                  SizedBox(width: 8),
                                  Text('Top Up'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Aksi untuk tombol Transfer
                              },
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: Red500,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.import_export_rounded),
                                  SizedBox(width: 8),
                                  Text('Transfer'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Riwayat Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
            Expanded(
                child: ListView.separated(
              shrinkWrap: true,
              itemCount: transactionHistory.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final transaction = transactionHistory[index];
                return Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: transaction.title == "Top Up"
                              ? AppColors.green
                              : AppColors.colorPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          transaction.icon,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Red900,
                              ),
                            ),
                            Text(
                              transaction.date,
                              style: TextStyle(
                                fontSize: 14,
                                color: Gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        transaction.amount,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: transaction.title == "Top Up"
                              ? AppColors.green
                              : AppColors.colorPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}

class Transaction {
  final IconData icon;
  final String title;
  final String date;
  final String amount;

  Transaction({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
  });
}
