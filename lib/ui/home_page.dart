import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:parkirta/bloc/home_bloc.dart';
import 'package:parkirta/color.dart';
import 'package:parkirta/ui/api.dart';
import 'package:parkirta/ui/profile.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';
import 'package:parkirta/utils/contsant/transaction_const.dart';
import 'package:parkirta/widget/dialog/parking_timer_dialog.dart';
import 'package:parkirta/widget/loading_dialog.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late BuildContext _context;
  final _loadingDialog = LoadingDialog();
  late GoogleMapController _mapController;
  List<dynamic> _parkingLocations = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _myLocationMarker = {};
  LatLng _myLocation = LatLng(0, 0);
  Map<String, dynamic>? selectedLocation;
  PolylinePoints polylinePoints = PolylinePoints();
  bool _isLoading = true;
  Polyline _polyline = Polyline(polylineId: PolylineId('route'), points: []);
  loc.Location _location = loc.Location();
  var paymentStep = SpUtil.getString(PAYMENT_STEP, defValue: null);

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  bool isInLocationArea(LatLng userPosition, List<LatLng> polygonCoordinates) {
    // Buat variabel untuk menyimpan jumlah persimpangan dengan batas poligon
    int intersectCount = 0;

    // Loop melalui semua sisi poligon
    for (int i = 0; i < polygonCoordinates.length; i++) {
      LatLng vertex1 = polygonCoordinates[i];
      LatLng vertex2 = polygonCoordinates[(i + 1) % polygonCoordinates.length];

      // Periksa apakah garis dari posisi pengguna ke atas berpotongan dengan sisi poligon
      if (((vertex1.latitude >= userPosition.latitude) !=
              (vertex2.latitude >= userPosition.latitude)) &&
          (userPosition.longitude <=
              (vertex2.longitude - vertex1.longitude) *
                      (userPosition.latitude - vertex1.latitude) /
                      (vertex2.latitude - vertex1.latitude) +
                  vertex1.longitude)) {
        // Jika ada persimpangan, tambahkan ke jumlah persimpangan
        intersectCount++;
      }
    }

    // Jika jumlah persimpangan adalah bilangan ganjil, berarti posisi pengguna berada di dalam area poligon
    return intersectCount % 2 == 1;
  }

  // Add the code for parkIcon here
  late BitmapDescriptor parkIcon;
  late Uint8List customMarker;
  late BitmapDescriptor defaultIcon;
  late BitmapDescriptor myLocationIcon;

  @override
  void initState() {
    Timer(const Duration(seconds: 1), (){
      var retributionActive = SpUtil.getInt(RETRIBUTION_ID_ACTIVE, defValue: null);
      if(retributionActive!=null && paymentStep!=PAY_LATER){
        Navigator.pushNamed(
            _context,
            "/arrive"
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _startLocationUpdates() {
    _location.onLocationChanged.listen((loc.LocationData currentLocation) {
      setState(() {
        _myLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        _myLocationMarker = <Marker>{
          Marker(
            markerId: const MarkerId('my_location'),
            position: _myLocation,
            icon: myLocationIcon,
            infoWindow: const InfoWindow(title: 'My Location'),
          ),
        };
      });
    });
  }

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/profile/detail'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final id = data['data']['id'];
      return id;
    } else {
      throw Exception('Failed to fetch user ID');
    }
  }


  Future<Uint8List> _getBytesFromAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  void _loadParkIcon() async {
    parkIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 100),
      'assets/images/park.png',
    );

    final Uint8List defaultIconBytes =
        await _getBytesFromAsset('assets/images/park.png');
    final Uint8List myLocationIconBytes =
        await _getBytesFromAsset('assets/images/yourloc.png');
    defaultIcon = BitmapDescriptor.fromBytes(defaultIconBytes);
    myLocationIcon = BitmapDescriptor.fromBytes(myLocationIconBytes);

    setState(() {
      _isLoading = false;
    });
  }


  Future<void> _getUserLocation() async {
    loc.LocationData? _locationData;
    perm.PermissionStatus _permissionStatus;

    loc.Location location = loc.Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // Handle if location service is not enabled
        return;
      }
    }

    _permissionStatus = await perm.Permission.locationWhenInUse.status;
    if (_permissionStatus.isDenied) {
      _permissionStatus = await perm.Permission.locationWhenInUse.request();
      if (_permissionStatus.isDenied) {
        // Handle if location permission is not granted
        return;
      }
    }

    _locationData = await location.getLocation();
    _startLocationUpdates();
    setState(() {
      _myLocation = _locationData != null
        ? LatLng(_locationData.latitude!, _locationData.longitude!)
        : LatLng(0, 0);
      _myLocationMarker = <Marker>{
        Marker(
          markerId: MarkerId('my_location'),
          position: _myLocation,
          icon: myLocationIcon,
          infoWindow: InfoWindow(title: 'My Location'),
        ),
      };
    });

    _mapController.animateCamera(CameraUpdate.newLatLng(_myLocation));
  }

  Future<void> _fetchParkingLocations() async {
    try {
      List<dynamic> locations = await getLocations();
      setState(() {
        _parkingLocations = locations;
      });
    } catch (error, stackTrace) {
      // Handle error fetching parking locations
      debugPrintStack(label: 'Error fetching parking locations: $error',stackTrace: stackTrace);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    debugPrint("map created");

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_mapController != '') {
        setState(() {
          _myLocationMarker = <Marker>{
            Marker(
              markerId: MarkerId('my_location'),
              position: _myLocation,
              icon: myLocationIcon,
              infoWindow: InfoWindow(title: 'My Location'),
            ),
          };
        });
      }
    });

    _loadParkIcon();
    _fetchParkingLocations();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => HomeBloc(),
        child: BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is LoadingState) {
                state.show ? _loadingDialog.show(context) : _loadingDialog.hide();
                } else if (state is SuccessSubmitArrivalState) {
                SpUtil.putInt(RETRIBUTION_ID_ACTIVE, state.data.idRetribusiParkir);
                Navigator.pushNamed(
                    context,
                    "/arrive"
                );
              } else if (state is ErrorState) {
                showTopSnackBar(
                  context,
                  CustomSnackBar.error(
                    message: state.error,
                  ),
                );
              }
            },
            child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  _context = context;
                  return Scaffold(
                    extendBodyBehindAppBar: true,
                    appBar: AppBar(
                      backgroundColor: Red500,
                      toolbarHeight: 84,
                      titleSpacing: 0,
                      automaticallyImplyLeading: false,
                      title: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Image.asset(
                              'assets/images/logo-parkirta2.png',
                              height: 40,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProfilePage()),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              child: Image.asset('assets/images/profile.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    body:_buildMap(context),
                  );
                })
        )
    );
  }

  Widget _buildMap(BuildContext context) {
    // if ((_parkingLocations??[]).isEmpty) { // Periksa apakah _parkingLocations adalah null atau kosong
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: GoogleMap(
              onMapCreated: _onMapCreated,

              mapType: MapType.normal,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-5.143648100120257, 119.48282708990482), // Ganti dengan posisi awal peta
                zoom: 20.0,
              ),
              markers: Set<Marker>.from(_parkingLocations.map((location) => Marker(
                markerId: MarkerId(location['id'].toString()),
                position: LatLng(
                  double.parse(location['lat']),
                  double.parse(location['long']),
                ),
                icon: defaultIcon,
                onTap: () {
                  _showParkingLocationPopup(context, location);
                },
              ))).union(_myLocationMarker),
              polylines: _polylines,
              polygons: Set<Polygon>.from(_parkingLocations!.map((location) {
                List<String> areaLatLongStrings = location['area_latlong'].split('},{');
                List<LatLng> polygonCoordinates = areaLatLongStrings.map<LatLng>((areaLatLongString) {
                  String latLngString = areaLatLongString.replaceAll('{', '').replaceAll('}', '');
                  List<String> latLngList = latLngString.split(',');

                  double lat = double.parse(latLngList[0].split(':')[1]);
                  double lng = double.parse(latLngList[1].split(':')[1]);

                  return LatLng(lat, lng);
                }).toList();

                return Polygon(
                  polygonId: PolygonId(location['id'].toString()),
                  points: polygonCoordinates,
                  fillColor: Colors.blue.withOpacity(0.3),
                  strokeColor: Colors.blue,
                  strokeWidth: 2,
                );
              })),

            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                _cancelRoute();
              },
              child: Icon(Icons.cancel_rounded),
            ),
          ),
          paymentStep == PAY_LATER ? Positioned(
              bottom: 50,
              child: InkWell(
                child: Container(
                  width: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Text("Waktu Parkir", style: TextStyle(color: AppColors.textPassive, fontSize: 12),),
                      SizedBox(height: 10,),
                      Text("10:30", style: TextStyle(color: AppColors.colorPrimary, fontSize: 28, fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                    ],
                  ),
                ),
                onTap: (){
                  showDialog(context: context, builder: (_) =>
                      ParkingTimerDialog()
                  );
                },
              )
          ): Container()
        ],
      );
    // }
  }
  
  void _showParkingLocationPopup(BuildContext _context, Map<String, dynamic> location) {
    debugPrint("_showParkingLocationPopup");
    String title = location['nama_lokasi'];
    String fotoProfileUrl = 'assets/images/profile.png';
    String namaJukir = location['relasi_jukir'][0]['jukir']['nama_lengkap'];
    String statusJukir = location['relasi_jukir'][0]['jukir']['status_jukir'];
    String statusParkir = location['status'];

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Gray500,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(fotoProfileUrl),
                    radius: 20,
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaJukir,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Red900,
                        ),
                      ),
                      Text(
                        'Status: $statusJukir',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                          color: Gray500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Status: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Gray500,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      statusParkir,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToArrivePage(location);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Red500),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    minimumSize: MaterialStateProperty.all<Size>(Size(88, 36)),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(8)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  child: const Text('Arahkan saya'),
                ),
              ),
            ],
          ),
        );
      },
    );


  }

  Set<Marker> _buildMarkers() {
    if (_isLoading) {
      return {}; // Return an empty set of markers while loading
    }

    return _parkingLocations!.map((location) {
      double lat = double.parse(location['lat']);
      double lng = double.parse(location['long']);

      BitmapDescriptor icon = defaultIcon;

      return Marker(
        markerId: MarkerId(location['id'].toString()),
        position: LatLng(lat, lng),
        icon: icon,
        onTap: () {
          _showParkingInfo(context, location);
        },
      );
    }).toSet();
  }

  void _showParkingInfo(BuildContext _context, Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Parkir Disini',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anda sudah dekat dengan lokasi parkir.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Apakah Anda ingin parkir di sini?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToArrivePage(location);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Red500),
                foregroundColor: MaterialStateProperty.all<Color>(Red50),
                minimumSize: MaterialStateProperty.all<Size>(
                  const Size(double.infinity, 48),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              child: const Text('Parkir Disini'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToArrivePage(Map<String, dynamic> location) async {
    try {
      selectedLocation = location;
      // Mendapatkan koordinat tujuan (lokasi parkir)
      LatLng destination = LatLng(double.parse(location['lat']), double.parse(location['long']));

      // Menggambar polyline antara posisi Anda saat ini dan lokasi parkir yang dipilih
      _updatePolyline(destination);

      // Konversi data polygon ke objek PolygonOptions
      List<String> areaLatLongStrings = location['area_latlong'].split('},{');
      List<LatLng> polygonCoordinates = areaLatLongStrings.map<LatLng>((areaLatLongString) {
        String latLngString = areaLatLongString.replaceAll('{', '').replaceAll('}', '');
        List<String> latLngList = latLngString.split(',');

        double lat = double.parse(latLngList[0].split(':')[1]);
        double lng = double.parse(latLngList[1].split(':')[1]);

        return LatLng(lat, lng);
      }).toList();

      bool isInLocationAreaResult = isInLocationArea(
        LatLng(_myLocation.latitude, _myLocation.longitude),
        polygonCoordinates,
      );

      if (isInLocationAreaResult) {
        // Tampilkan dialog lokasi parkir
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      location['nama_lokasi'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(location['alamat_lokasi']),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        int userId = await getUserId();
                        _context.read<HomeBloc>().submitArrival(
                          location['id'].toString(),
                          userId.toString(),
                          _myLocation.latitude.toString(),
                          _myLocation.longitude.toString(),
                        );

                        Navigator.pop(context);

                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        minimumSize: MaterialStateProperty.all<Size>(Size(120, 40)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      child: Text('Parkir Disini'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        // Tampilkan notifikasi bahwa pengguna belum dekat dengan lokasi parkir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anda belum dekat dengan lokasi parkir'),
          ),
        );
      }
    } catch (error) {
      // Tangani kesalahan saat mengonfirmasi kedatangan parkir
      print('Error confirming parking arrival: $error');
    }
  }

  void _updatePolyline(LatLng destination) async {
    // Mendapatkan rute antara posisi pengguna dan tujuan (lokasi parkir)
    PolylineResult polylineResult = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyA92HfpnxtX1kHsozA0ACaxpq5IQfq9GqI', // Ganti dengan kunci API Google Maps Anda
      PointLatLng(_myLocation.latitude, _myLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    // Menghapus polyline sebelumnya (jika ada)
    setState(() {
      _polylines.remove(_polyline);
    });

    if (polylineResult.points.isNotEmpty) {
      // Mengonversi koordinat polyline ke LatLng
      List<LatLng> polylineCoordinates = polylineResult.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      // Membuat polyline baru
      setState(() {
        _polyline = Polyline(
          polylineId: PolylineId('route'),
          color: Colors.red,
          points: polylineCoordinates,
        );
        _polylines.add(_polyline);
      });
    }
  }

  void _cancelRoute() {
    setState(() {
      _polylines.remove(_polyline);
      _polyline = Polyline(polylineId: PolylineId('route'), points: []);
    });
  }

}