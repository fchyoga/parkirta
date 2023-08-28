import 'package:flutter/material.dart';
import 'package:parkirta/ui/api.dart'; // Import file API yang telah kita buat sebelumnya
import 'package:parkirta/color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Paket untuk menampilkan peta
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ArrivePage extends StatefulWidget {
  final dynamic location;
  final String status;

  ArrivePage({required this.location, required this.status});

  @override
  State<ArrivePage> createState() => _ArrivePageState();
}

class _ArrivePageState extends State<ArrivePage> {

  Future<void> cancelParking(String idLokasiParkir) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      var url = Uri.parse('https://parkirta.test/api/retribusi/parking/cancel');
      var response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
        body: {'id_lokasi_parkir': idLokasiParkir},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        print('Parkir berhasil dibatalkan');
      } else {
        // Jika request gagal, tangani kesalahan
        print('Gagal membatalkan parkir');
      }
    } catch (error) {
      // Jika terjadi kesalahan saat melakukan request, tangani kesalahan
      print('Terjadi kesalahan saat membatalkan parkir: $error');
    }
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Batalkan Parkir'),
          content: Text('Anda yakin ingin membatalkan parkir?'),
          actions: [
            TextButton(
              child: Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop();
                cancelParking(widget.location['id'].toString());
              },
            ),
            TextButton(
              child: Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            _showCancelConfirmationDialog();
          },
          child: Container(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.cancel,
              color: Red900,
            ),
          ),
        ),
        title: Text(
          'Parkiran ${widget.location['nama_lokasi']}',
          style: TextStyle(
            color: Red900,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ArrivePage(
                    location: widget.location,
                    status: widget.status,
                  ),
                ),
              );
            },
            icon: Icon(Icons.refresh),
            color: Red900,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Location: ${widget.location['nama_lokasi']}'),
            Text('Status: ${widget.status}'),
            Text('ID Lokasi: ${widget.location['id']}'),
          ],
        ),
      ),
    );
  }
}