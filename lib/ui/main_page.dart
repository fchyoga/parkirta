import 'package:flutter/material.dart';
import 'package:parkirta/color.dart';
import 'package:parkirta/ui/wallet.dart';
import 'package:parkirta/ui/dompet.dart';
import 'package:parkirta/ui/home_page.dart';
import 'package:parkirta/ui/submitted.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  HomePage? homePage;
  Map<String, dynamic> userData = {};
  late List<Widget> _pages = [
    HomePage(),
    WalletPage(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

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
        _pages = [
          HomePage(),
          if (userData['status_pelanggan'] == 'Aktif')
            DompetPage()
          else
            if (userData['foto_ktp'] != null)
              SubmittedPage()
            else
              WalletPage(),
        ];
      });
    } else {
      print(response.body);
      throw Exception('Failed to fetch user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                  icon: Icon(Icons.home_rounded),
                  color: _currentIndex == 0 ? Red500 : Gray500,
                ),
                Text(
                  'Home', // Label untuk IconButton ini
                  style: TextStyle(
                    color: _currentIndex == 0 ? Red500 : Gray500,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  icon: Icon(Icons.account_balance_wallet_rounded),
                  color: _currentIndex == 1 ? Red500 : Gray500,
                ),
                Text(
                  'Wallet', // Label untuk IconButton ini
                  style: TextStyle(
                    color: _currentIndex == 1 ? Red500 : Gray500,
                  ),
                ),
              ],
            ),
          ],
        ),
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        },
        backgroundColor: Red500,
        child: Icon(Icons.near_me_rounded),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
