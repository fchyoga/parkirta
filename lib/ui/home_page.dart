import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:parkirta/bloc/home_bloc.dart';
import 'package:parkirta/color.dart';
import 'package:parkirta/data/message/response/parking/parking_location_response.dart';
import 'package:parkirta/data/model/retribusi.dart';
import 'package:parkirta/ui/profile.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';
import 'package:parkirta/utils/contsant/parking_status.dart';
import 'package:parkirta/utils/contsant/transaction_const.dart';
import 'package:parkirta/widget/card/card_timer.dart';
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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  late BuildContext _context;
  final _loadingDialog = LoadingDialog();
  GoogleMapController? _mapController;
  List<ParkingLocation> _parkingLocations = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _myLocationMarker = {};
  LatLng? _myLocation;
  ParkingLocation? selectedLocation;
  PolylinePoints polylinePoints = PolylinePoints();
  bool _isLoading = true;
  Polyline _polyline = Polyline(polylineId: PolylineId('route'), points: []);
  loc.Location _location = loc.Location();
  String? parkingStatus = SpUtil.getString(PARKING_STATUS, defValue: null);
  Retribusi? retribution;
  DateTime? parkingTime;
  CardTimer? cardTimer;

  // Add the code for parkIcon here
  late BitmapDescriptor parkIcon;
  late Uint8List customMarker;
  late BitmapDescriptor defaultIcon;
  late BitmapDescriptor myLocationIcon;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }


  @override
  void initState(){
    Timer(const Duration(milliseconds: 500), () async{

      getLocalData();
      // SpUtil.putInt(RETRIBUTION_ID_ACTIVE, 34);
      // parkingStatus = ParkingStatus.menungguJukir.name;
      // SpUtil.remove(RETRIBUTION_ID_ACTIVE);
      // SpUtil.remove(PAYMENT_STEP);
      var retributionActive = SpUtil.getInt(RETRIBUTION_ID_ACTIVE, defValue: null);
      debugPrint("parking status ${parkingStatus}");
      if(retributionActive!=null) _context.read<HomeBloc>().checkDetailParking(retributionActive.toString());
      if(retributionActive!=null && parkingStatus == ParkingStatus.menungguJukir.name ){
        var parkingStatus = await Navigator.pushNamed(
            _context,
            "/arrive",
          arguments: retributionActive
        );
        if(parkingStatus is String){
          setState(() {
            parkingStatus = parkingStatus;
          });
          getLocalData();
        }

      }
    });
    _loadParkIcon();
    // _fetchParkingLocations();
    _getUserLocation();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("Lifecycle State --> ${state} ");
    if(state == AppLifecycleState.resumed){
      setState(() {
        parkingStatus = SpUtil.getString(PARKING_STATUS, defValue: null);
      });
      getLocalData();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // getLocalData();
    return BlocProvider(
        create: (context) => HomeBloc()..getParkingLocation(),
        child: BlocListener<HomeBloc, HomeState>(
            listener: (context, state) async{
              if (state is LoadingState) {
                state.show ? _loadingDialog.show(context) : _loadingDialog.hide();
              } else if (state is SuccessGetParkingLocationState) {
                setState(() {
                  _parkingLocations = state.data;
                });
              } else if (state is SuccessSubmitArrivalState) {
                SpUtil.putInt(RETRIBUTION_ID_ACTIVE, state.data.idRetribusiParkir);
                var parkingStatus = await Navigator.pushNamed(
                    context,
                    "/arrive",
                    arguments: state.data.idRetribusiParkir
                );
                if(parkingStatus is String){
                  setState(() {
                    parkingStatus = parkingStatus;
                  });
                  getLocalData();
                }

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
                              padding: const EdgeInsets.only(left: 20),
                              child: Image.asset(
                                'assets/images/logo-parkirta2.png',
                                height: 40,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                        actions: [

                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 35,
                            height: 35,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                border: Border.all(width: 0.5, color: Colors.white.withOpacity(0.5))),
                            child: IconButton(
                              onPressed: (){
                                Navigator.pushNamed(context, '/notification');
                              },
                              icon: SvgPicture.asset("assets/images/ic_notification.svg", width: 14),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
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
                      body: SafeArea(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: GoogleMap(
                                onMapCreated: _onMapCreated,
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: true,
                                mapToolbarEnabled: false,
                                mapType: MapType.normal,
                                initialCameraPosition: const CameraPosition(
                                  target: LatLng(-5.143648100120257, 119.48282708990482), // Ganti dengan posisi awal peta
                                  zoom: 20.0,
                                ),
                                markers: Set<Marker>.from(_parkingLocations.map((location) => Marker(
                                  markerId: MarkerId(location.id.toString()),
                                  position: LatLng(
                                    double.parse(location.lat),
                                    double.parse(location.long),
                                  ),
                                  icon: defaultIcon,
                                  onTap: () {
                                    _showParkingLocationPopup(context, location);
                                  },
                                ))).union(_myLocationMarker),
                                polylines: _polylines,
                                polygons: Set<Polygon>.from(_parkingLocations.where((e) => e.areaLatlong!=null).toList().map((location) {
                                  List<String> areaLatLongStrings = location.areaLatlong!.split('},{');
                                  List<LatLng> polygonCoordinates = areaLatLongStrings.map<LatLng>((areaLatLongString) {
                                    String latLngString = areaLatLongString.replaceAll('{', '').replaceAll('}', '');
                                    List<String> latLngList = latLngString.split(',');

                                    double lat = double.parse(latLngList[0].split(':')[1]);
                                    double lng = double.parse(latLngList[1].split(':')[1]);

                                    return LatLng(lat, lng);
                                  }).toList();

                                  return Polygon(
                                    polygonId: PolygonId(location.id.toString()),
                                    points: polygonCoordinates,
                                    fillColor: Colors.blue.withOpacity(0.3),
                                    strokeColor: Colors.blue,
                                    strokeWidth: 2,
                                  );
                                })),

                              ),
                            ),
                            // Positioned(
                            //   top: 16.0,
                            //   right: 16.0,
                            //   child: FloatingActionButton(
                            //     backgroundColor: Colors.white,
                            //     onPressed: () {
                            //       _cancelRoute();
                            //     },
                            //     child: const Icon(Icons.cancel_rounded),
                            //   ),
                            // ),
                            Positioned(
                                bottom: 16.0,
                                right: 16.0,
                                child: InkWell(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.01),
                                          blurRadius: 5,
                                          offset: const Offset(0, 12),),
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 7),),
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.09),
                                          blurRadius: 3,
                                          offset: const Offset(0, 3),),
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.10),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),),
                                      ],

                                    ),
                                    child: const Icon(Icons.my_location_outlined, color: AppColors.textPassive,),
                                  ),
                                  onTap: () {
                                    if(_myLocation!=null) {
                                      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_myLocation!, 20));
                                    } else {
                                      _getUserLocation();
                                    }
                                  },
                                )
                            ),
                            Positioned(
                                top: 16,
                                right: 16,
                                child: cardTimer ?? Container()
                            )

                          ],
                        ),
                      )
                  );
                })
        )
    );
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

  void _startLocationUpdates() {
    _location.onLocationChanged.listen((loc.LocationData currentLocation) {
      // setState(() {
        _myLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        _myLocationMarker = <Marker>{
          Marker(
            markerId: const MarkerId('my_location'),
            position: _myLocation!,
            icon: myLocationIcon,
            infoWindow: const InfoWindow(title: 'My Location'),
          ),
        };
        getLocalData();

      //   parkingStatus = SpUtil.getString(PARKING_STATUS, defValue: null);
      //   if(parkingTime!= null && parkingStatus!= null && parkingStatus != ParkingStatus.menungguJukir.name && parkingStatus != ParkingStatus.telahKeluar.name) {
      //
      //     debugPrint("show cardTimer $parkingStatus ");
      //     cardTimer = buildCardTimer(_context, parkingTime, retribution!);
      //   } else {
      //     cardTimer = null;
      //   }
      // });
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
    loc.LocationData? locationData;
    perm.PermissionStatus permissionStatus;

    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Handle if location service is not enabled
        return;
      }
    }

    permissionStatus = await perm.Permission.locationWhenInUse.status;
    if (permissionStatus.isDenied) {
      permissionStatus = await perm.Permission.locationWhenInUse.request();
      if (permissionStatus.isDenied) {
        // Handle if location permission is not granted
        return;
      }
    }

    locationData = await location.getLocation();
    _startLocationUpdates();

    if(locationData==null) return;
    setState(() {
      _myLocation = LatLng(locationData!.latitude!, locationData!.longitude!);
      _myLocationMarker = <Marker>{
        Marker(
          markerId: MarkerId('my_location'),
          position: _myLocation!,
          icon: myLocationIcon,
          infoWindow: InfoWindow(title: 'My Location'),
        ),
      };
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_myLocation!, 20));
  }

  // Future<void> _fetchParkingLocations() async {
  //   try {
  //     debugPrint("get parking");
  //     List<dynamic> locations = await getLocations();
  //     debugPrint("loc parking ${locations.length}");
  //     setState(() {
  //       _parkingLocations = locations;
  //     });
  //   } catch (error, stackTrace) {
  //     // Handle error fetching parking locations
  //     debugPrintStack(label: 'Error fetching parking locations: $error',stackTrace: stackTrace);
  //   }
  // }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    debugPrint("map created");

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_mapController != null && _myLocation!=null) {
        setState(() {
          _myLocationMarker = <Marker>{
            Marker(
              markerId: MarkerId('my_location'),
              position: _myLocation!,
              icon: myLocationIcon,
              infoWindow: InfoWindow(title: 'My Location'),
            ),
          };
        });
      }
    });

  }


  
  void _showParkingLocationPopup(BuildContext _context, ParkingLocation location) {
    debugPrint("_showParkingLocationPopup");
    String title = location.namaLokasi;
    String fotoProfileUrl = 'assets/images/profile.png';
    if(location.relasiJukir.isEmpty){
      showTopSnackBar(
        context,
        const CustomSnackBar.error(
          message: "Jukir tidak tersedia dia area ini",
        ),
      );
      return;
    }

    String namaJukir = location.relasiJukir[0].jukir.namaLengkap;
    String statusJukir =  location.relasiJukir[0].jukir.statusJukir;
    String statusParkir = location.status;

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
              const SizedBox(height: 8),
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
                      style: const TextStyle(
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


  void _navigateToArrivePage(ParkingLocation location) async {
    try {
      if(location.areaLatlong==null) return;
      selectedLocation = location;
      // Mendapatkan koordinat tujuan (lokasi parkir)
      LatLng destination = LatLng(double.parse(location.lat), double.parse(location.long));

      // Menggambar polyline antara posisi Anda saat ini dan lokasi parkir yang dipilih
      _updatePolyline(destination);

      // Konversi data polygon ke objek PolygonOptions
      List<String> areaLatLongStrings = location.areaLatlong!.split('},{');
      List<LatLng> polygonCoordinates = areaLatLongStrings.map<LatLng>((areaLatLongString) {
        String latLngString = areaLatLongString.replaceAll('{', '').replaceAll('}', '');
        List<String> latLngList = latLngString.split(',');

        double lat = double.parse(latLngList[0].split(':')[1]);
        double lng = double.parse(latLngList[1].split(':')[1]);

        return LatLng(lat, lng);
      }).toList();

      bool isInLocationAreaResult = _myLocation!=null ? isInLocationArea(
        _myLocation!,
        polygonCoordinates,
      ): false;


      if (isInLocationAreaResult && _myLocation!=null) {
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
                      location.namaLokasi,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(location.alamatLokasi),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        int userId = await getUserId();
                        _context.read<HomeBloc>().submitArrival(
                          location.id.toString(),
                          userId.toString(),
                          _myLocation!.latitude.toString(),
                          _myLocation!.longitude.toString(),
                        );

                        Navigator.pop(context);

                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Red500),
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
      PointLatLng(_myLocation?.latitude ?? 0, _myLocation?.longitude ?? 0),
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

  CardTimer buildCardTimer(BuildContext context, DateTime? parkingTime, Retribusi retribution){
    return  CardTimer(dateTime: parkingTime, onClick:  (value){
      showDialog(context: context, builder: (_) =>
          ParkingTimerDialog(
            entryDate: parkingTime!,
            duration: value,
            name: retribution.pelanggan?.namaLengkap ?? "-",
            policeNumber: retribution.nopol ?? "-",
            location: retribution.lokasiParkir?.namaLokasi ?? "-",
            address:retribution.lokasiParkir?.alamatLokasi ?? "-",
            price: (retribution.biayaParkir?.biayaParkir ?? 0).toString(),
            onClickStop: (){
              debugPrint("cekkk $parkingTime $value");
              Navigator.pushNamed(_context, "/payment", arguments: {
                "retribusi": retribution,
                "jam": parkingTime,
                "durasi": DateTime.now().difference(parkingTime)
              });
            },
          )
      );
    });
  }

  void _cancelRoute() {
    setState(() {
      _polylines.remove(_polyline);
      _polyline = Polyline(polylineId: PolylineId('route'), points: []);
    });
  }

  Future<void> clearLocalData() async{
    SpUtil.remove(RETRIBUTION_ID_ACTIVE);
    SpUtil.remove(PAYMENT_STEP);
    SpUtil.remove(INVOICE_ACTIVE);
    SpUtil.remove(PARKING_STATUS);
    retribution = null;
    parkingTime = null;
    parkingStatus = null;
    debugPrint("remove LocalData $parkingTime ${retribution}");
  }
  Future<void> getLocalData() async{
    var retributions = await Hive.openBox<Retribusi>('retribusiBox');
    debugPrint("getLocalData ${retributions.length}");
    if(retributions.isNotEmpty && retributions.getAt(0)?.statusParkir == ParkingStatus.telahKeluar.name) {
      retributions.deleteAt(0);
      retributions.clear();
      await clearLocalData();
    }else if(retributions.isNotEmpty){
      retribution = retributions.getAt(0);
      parkingTime = retribution?.createdAt;
      debugPrint("getLocalData $parkingTime ${retributions.getAt(0)?.toJson()}");

    }
    setState(() {
      parkingStatus = SpUtil.getString(PARKING_STATUS, defValue: null);
      if(parkingTime!= null && parkingStatus!= null && parkingStatus != ParkingStatus.menungguJukir.name && parkingStatus != ParkingStatus.telahKeluar.name) {
        debugPrint("show cardTimer $parkingStatus ");
        cardTimer = buildCardTimer(_context, parkingTime, retribution!);
      } else {
        cardTimer = null;
      }
    });
  }



}