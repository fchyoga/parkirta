import 'package:flutter/material.dart';
import 'package:parkirta/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DompetPage extends StatefulWidget {
  @override
  State<DompetPage> createState() => _DompetPageState();
}

class _DompetPageState extends State<DompetPage> {
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
              color: Red900,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Red500,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Saldo',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'email@example.com', // Ganti dengan email dari data pengguna
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Rp 128,000',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Aksi untuk tombol Topup
                              },
                              style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                                primary: Colors.white,
                                onPrimary: Red500,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_rounded), // Ikonya disini
                                  SizedBox(
                                      width: 8), // Jarak antara ikon dan teks
                                  Text('Top Up'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Aksi untuk tombol Transfer
                              },
                              style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                                primary: Colors.white,
                                onPrimary: Red500,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons
                                      .import_export_rounded), // Ikonya disini
                                  SizedBox(
                                      width: 8), // Jarak antara ikon dan teks
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Red900,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 415,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: transactionHistory.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final transaction = transactionHistory[index];
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Red500,
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
                                    SizedBox(height: 4),
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
                                  color: Red500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
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
