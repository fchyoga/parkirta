import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parkirta/bloc/auth_bloc.dart';
import 'package:parkirta/color.dart';
import 'package:parkirta/main.dart';
import 'package:parkirta/ui/home_page.dart';
import 'package:parkirta/ui/submitted.dart';
import 'package:http/http.dart' as http;
import 'package:parkirta/ui/wallet/wallet_dashboard.dart';
import 'package:parkirta/ui/wallet/wallet_intro_page.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  HomePage? homePage;
  late BuildContext _context;
  Map<String, dynamic> userData = {};
  late List<Widget> _pages = [
    HomePage(),
    WalletIntroPage(),
  ];

  @override
  void initState() {
    _requestPermissions();
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
            WalletDashboardPage()
          else
            if (userData['foto_ktp'] != null)
              SubmittedPage()
            else
              WalletIntroPage(),
        ];
      });
    }  else if (response.statusCode == 403) {
      showTopSnackBar(_context, CustomSnackBar.error(
        message: "Sesi anda telah habis. Silakan login kembali",
      ));
      _context.read<AuthenticationBloc>().authenticationExpiredEvent();
      Navigator.pushNamedAndRemoveUntil(_context, "/", (route) => false);
    } else {
      print(response.body);
      throw Exception('Failed to fetch user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      key: NavigationService.navigatorKey,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: Colors.white,
        height: 70,
        child: Column(
          children: [
            const Divider(
              thickness: 1,
              height: 1,
              color: AppColors.cardGrey,
            ),
            const SizedBox(height: 8,),
            Row(
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
                      icon:  SvgPicture.asset( _currentIndex == 0 ? "assets/images/ic_home.svg": "assets/images/ic_home_outline.svg"),
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
                      icon:  SvgPicture.asset( _currentIndex == 1 ? "assets/images/ic_wallet.svg": "assets/images/ic_wallet_outline.svg"),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 1,
              child: Container(
            width: 55,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColors.colorPrimary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.colorPrimary.withOpacity(0.25),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),)
          ),
          Container(
            width: 65,
            height: 65,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColors.colorPrimary,

            ),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                 "/",
                );
              },
              child: SvgPicture.asset("assets/images/ic_discovery.svg"),
            ) ,
          )
        ],
      ): null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      // setState(() {
      //   _notificationsEnabled = granted ?? false;
      // });
    }
  }
}
