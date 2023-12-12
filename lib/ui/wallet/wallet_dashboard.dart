import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> transactionHistory = [];
  String topUpInvoice = '';
  bool _isLoading = false;

  int saldo = 0;

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/profile/detail'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        userData = jsonDecode(response.body)['data'];
      });
    } else {
      print(response.body);
      throw Exception('Failed to fetch user data');
    }
  }

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

  Future<void> fetchTransactionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/profile/transaksi'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Response Body: ${response.body}');
      try {
        final jsonData = jsonDecode(response.body);
        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          setState(() {
            transactionHistory =
                List<Map<String, dynamic>>.from(jsonData['data']);
          });
        } else {
          print('Response does not contain a valid data field.');
        }
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      print(
          'Failed to fetch transaction history. Status code: ${response.statusCode}');
      print(response.body);
      // You might want to handle errors more gracefully here.
    }
  }

  // Function to initiate the top-up process
  Future<void> _initiateTopUp(double totalTopUp) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('https://parkirta.com/api/dompet/topup/entry'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tujuan': 'akun',
          'total_topup': totalTopUp,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['pembayaran'] != null &&
            responseData['data']['pembayaran']['no_invoice'] != null) {
          final topUpInvoice = responseData['data']['pembayaran']['no_invoice'];
          setState(() {
            this.topUpInvoice = topUpInvoice;
          });

          // Show Payment Options
          _showPaymentOptions();
        } else {
          print('Failed to get top-up invoice from the response data.');
          print('Response data: $responseData');
          // Handle errors as needed
        }
      } else {
        print('Failed to initiate top-up. Status code: ${response.statusCode}');
        print(response.body);
        // Handle errors as needed
      }
    } catch (e) {
      print('Error initiating top-up: $e');
      // Handle errors as needed
    }
  }

  // Function to show the top-up popup
  void _showTopUpPopup() {
    double amount = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Top-Up Amount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Sesuaikan dengan angka yang diinginkan
                  ),
                ),
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Red500, // Change to your desired color
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _initiateTopUp(amount);
                Navigator.pop(context); // Close the popup
              },
              style: ElevatedButton.styleFrom(primary: Red500),
              child: Text(
                'Top Up',
                style: TextStyle(
                  color: Colors.white, // Change to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPaymentButton(
                'Pay with Bank Transfer (BCA)',
                'bca',
                'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Bank_Central_Asia.svg/1200px-Bank_Central_Asia.svg.png',
                isGoPayButton: false,
              ),
              _buildPaymentButton(
                'Pay with Bank Transfer (BNI)',
                'bni',
                'https://seeklogo.com/images/B/bank-bni-logo-737EE0F32C-seeklogo.com.png',
                isGoPayButton: false,
              ),
              _buildPaymentButton(
                'Pay with Bank Transfer (BRI)',
                'bri',
                'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/BRI_2020.svg/2560px-BRI_2020.svg.png',
                isGoPayButton: false,
              ),
              _buildPaymentButton(
                'Pay with GoPay',
                'gopay',
                'https://datangjikasempat.com/wp-content/uploads/2022/08/LOGO-GOPAY.png',
                isGoPayButton: true,
              ),
            ],
          ),
        );
      },
    );
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Widget _buildPaymentButton(String label, String method, String imageUrl,
      {bool isGoPayButton = false}) {
    return ElevatedButton(
      onPressed: () async {
        // Set status loading menjadi true saat memulai pembayaran
        _setLoading(true);

        if (isGoPayButton) {
          await _performPayment('gopay');
        } else {
          await _performPayment('bank_transfer', method);
        }

        // Setelah pembayaran selesai, set status loading kembali menjadi false
        _setLoading(false);
      },
      style: ElevatedButton.styleFrom(primary: Red500, elevation: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.network(
                imageUrl,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white, // Change to your desired color
                ),
              ),
            ],
          ),
          // Tampilkan indikator loading jika sedang loading
          if (_isLoading)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          else
            Icon(Icons.arrow_forward_ios, color: Colors.white),
        ],
      ),
    );
  }

  // Function to perform payment
  Future<void> _performPayment(String paymentType, [String bank = '']) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('https://parkirta.com/api/dompet/topup/payment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'no_invoice': topUpInvoice,
          'payment_type': paymentType,
          if (paymentType == 'bank_transfer') 'bank': bank,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['pembayaran'] != null) {
          final paymentData = responseData['data']['pembayaran'];
          _showPaymentDetails(paymentData, paymentType);
        } else {
          print('Failed to get payment details from the response data.');
          print('Response data: $responseData');
          // Handle errors as needed
        }
      } else {
        print('Failed to perform payment. Status code: ${response.statusCode}');
        print(response.body);
        // Handle errors as needed
      }
    } catch (e) {
      print('Error performing payment: $e');
      // Handle errors as needed
    }
  }

  void _showPaymentDetails(
      Map<String, dynamic> paymentData, String paymentType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'INV. ${paymentData['no_invoice']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (paymentData['payment_type'] == 'bank_transfer')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bank: ${paymentData['bank']}',
                            style: TextStyle(
                              color: Gray700,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(48),
                                  border: Border.all(color: Gray500),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      paymentData['va_number'],
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Gray700,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: paymentData['va_number'] ??
                                                ''));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Kode Bayar copied to clipboard'),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.content_copy,
                                            color: Colors.white,
                                          ),
                                          // SizedBox(width: 8),
                                          // Text(
                                          //   "Copy",
                                          //   style: TextStyle(
                                          //     color: Colors
                                          //         .white, // Change to your desired color
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          primary: Red500, elevation: 0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    if (paymentData['payment_type'] == 'gopay')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QR Code',
                            style: TextStyle(
                              color: Gray700,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 200.0,
                                  height: 200.0,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Gray500),
                                  ),
                                  child: QrImageView(
                                    data: paymentData['qris'],
                                    version: QrVersions.auto,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 16),
                    Text(
                      'Jumlah Bayar',
                      style: TextStyle(
                        color: Gray700,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Gray500),
                      ),
                      child: Text(
                        'Rp. ${paymentData['gross_amount']}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Red500,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchSaldo();
    fetchUserData();
    fetchTransactionHistory();
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
                            userData['email'] ??
                                '', // Ganti dengan email dari data pengguna
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
                                _showTopUpPopup();
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
                            color: transaction['payment_type'] == "Top Up"
                                ? AppColors.green
                                : AppColors.colorPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            transaction['payment_type'] == "Top Up"
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction['payment_type'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: transaction['payment_type'] == "Top Up"
                                      ? AppColors.green
                                      : AppColors.colorPrimary,
                                ),
                              ),
                              Text(
                                transaction['settlement_time'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${transaction['gross_amount']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: transaction['payment_type'] == "Top Up"
                                ? AppColors.green
                                : AppColors.colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
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
