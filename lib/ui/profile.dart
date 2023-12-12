import 'package:flutter/material.dart';
import 'package:parkirta/color.dart';
import 'package:http/http.dart' as http;
import 'package:parkirta/ui/auth/pre_login_page.dart';
import 'package:parkirta/ui/profile_edit.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};

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
      });
    } else {
      print(response.body); // Cetak pesan respons yang diterima dari API
      throw Exception('Failed to fetch user data');
    }
  }

  void _showChangePinPopup() {
    String oldPin = '';
    String newPin = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Old PIN'),
                onChanged: (value) {
                  oldPin = value;
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'New PIN'),
                onChanged: (value) {
                  newPin = value;
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
                  color: Red500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _updatePin(oldPin, newPin);
                Navigator.pop(context); // Close the popup
              },
              style: ElevatedButton.styleFrom(primary: Red500),
              child: Text('Change PIN'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePin(String oldPin, String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idPelanggan = userData['id']; // Ambil ID pelanggan dari userData

    try {
      // Ganti null dengan string kosong jika oldPin adalah null
      oldPin ??= "";

      // Tambahkan pengecekan jika newPin adalah null atau kosong
      if (newPin == null || newPin.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New PIN cannot be empty'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('https://parkirta.com/api/profile/pin/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_pelanggan': idPelanggan,
          'pin_lama': oldPin,
          'pin_baru': newPin,
        }),
      );

      if (response.statusCode == 200) {
        // Handle success response
        print('PIN updated successfully');

        // Tampilkan notifikasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PIN updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Failed to update PIN. Status code: ${response.statusCode}');
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to update PIN. Status code: ${response.statusCode}'),
            duration: Duration(seconds: 2),
          ),
        );
        // Handle errors as needed
      }
    } catch (e) {
      print('Error updating PIN: $e');
      // Handle errors as needed
    }
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
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Red900,
            ),
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Red900,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: userData['foto_pelanggan'] != null
                    ? NetworkImage(
                            'https://parkirta.com/storage/uploads/foto/${userData['foto_pelanggan']}')
                        as ImageProvider<Object>
                    : const AssetImage('assets/images/profile.png'),
              ),
              SizedBox(height: 16),
              Text(
                userData['nama_lengkap'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                userData['email'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Gray500,
                ),
              ),
              SizedBox(height: 24),
              buildRoundedButton(
                text: 'Change PIN',
                icon: Icons.arrow_forward_ios_rounded,
                onPressed: _showChangePinPopup,
                height: 48,
              ),
              SizedBox(height: 8),
              buildRoundedButton(
                text: 'Edit Profile',
                icon: Icons.arrow_forward_ios_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileEdit(
                            userName: userData.isNotEmpty
                                ? userData['nama_lengkap']
                                : '',
                            userEmail:
                                userData.isNotEmpty ? userData['email'] : '')),
                  );
                },
                height: 48,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isLoggedIn', false);
                  prefs.remove('userRole');
                  prefs.remove('token');

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PreLoginPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Red500),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all<Size>(
                    const Size(double.infinity, 48),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoundedButton({
    required String text,
    IconData? icon,
    Color backgroundColor = Colors.white,
    required VoidCallback onPressed,
    double height = 48,
  }) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Red900,
                fontSize: 14,
              ),
            ),
            Icon(
              icon,
              color: Red900,
            ),
          ],
        ),
      ),
    );
  }
}
