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
      body:Padding(
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
                      ),)
                ),
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
                        'Rp 128,000',
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
                                // Aksi untuk tombol Topup
                              },
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: Red500,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
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
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
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
            Expanded(child: ListView.separated(
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
                          color: transaction.title == "Top Up" ? AppColors.green: AppColors.colorPrimary,
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
                          color: transaction.title == "Top Up" ? AppColors.green: AppColors.colorPrimary,
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
