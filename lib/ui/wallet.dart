import 'package:flutter/material.dart';
import 'package:parkirta/color.dart';
import 'package:parkirta/ui/aktivasi.dart';
import 'package:parkirta/ui/submitted.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WalletPage extends StatefulWidget {
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // checkFotoKtp();
  }

  // Future<void> checkFotoKtp() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');

  //   final response = await http.get(
  //     Uri.parse('https://parkirta.com/api/profile/detail'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body)['data'];
  //     final fotoKtp = data['foto_ktp'];

  //     setState(() {
  //       isLoading = false;
  //     });

  //     if (fotoKtp != null && fotoKtp.isNotEmpty) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => SubmittedPage()),
  //       );
  //     }
  //   } else {
  //     setState(() {
  //       isLoading = false;
  //     });

  //     throw Exception('Failed to fetch user profile');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        'Aktifkan Kartu Parkirta Anda!',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Red800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Nikmati kemudahan dalam membayar parkir di tempat-tempat parkir yang telah bekerja sama dengan kami.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Red900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  _buildContainer(
                    Icons.loyalty_outlined, 
                    'Bebas Antre',
                    'Tambah saldo kartu E-Money Parkirta Anda di menu Top Up pada Dompet'
                  ),
                  SizedBox(height: 16),
                  _buildContainer(
                    Icons.add_circle_outline_rounded, 
                    'Top Up',
                    'Cek riwayat transaksi parkir Anda di menu Dompet Parkirta'
                  ),
                  SizedBox(height: 16),
                  _buildContainer(
                    Icons.swap_vert_rounded, 
                    'Riwayat Transaksi',
                    'Manage your finances'
                  ),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AktivasiPage()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Red500),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      minimumSize: MaterialStateProperty.all<Size>(
                        const Size(double.infinity, 48),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), 
                        ),
                      ),
                    ),
                    child: const Text('Aktifkan Kartu Kamu'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildContainer(IconData icon, String title, String subtitle) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.transparent,
        width: 1.0,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Red500,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ),
    ),
  );
}
