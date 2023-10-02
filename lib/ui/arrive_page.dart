
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkirta/bloc/parking_bloc.dart';
import 'package:parkirta/color.dart';
import 'package:parkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';
import 'package:parkirta/utils/contsant/payment_choice.dart';
import 'package:parkirta/utils/contsant/transaction_const.dart';
import 'package:parkirta/widget/button/button_default.dart';
import 'package:parkirta/widget/loading_dialog.dart';
import 'package:sp_util/sp_util.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';


class ArrivePage extends StatefulWidget {

  ArrivePage();

  @override
  State<ArrivePage> createState() => _ArrivePageState();
}

class _ArrivePageState extends State<ArrivePage> {

  final _loadingDialog = LoadingDialog();
  late BuildContext _context;
  late int retributionId;
  ParkingCheckDetail? parkingCheckDetail;
  List<Marker> markers = [];
  bool payNow = false;
  String? timeSelected;
  Duration? duration;
  // late Timer periodic;

  @override
  void initState() {
    // periodic = Timer.periodic(Duration(seconds: 1), (timer) {
    //   var parkingCheck = SpUtil.getString(PARKING_ACCEPTED);
    //   if(parkingCheck == retributionId.toString()){
    //     SpUtil.remove(PARKING_ACCEPTED);
    //     _context.read<ParkingBloc>().checkDetailParking(retributionId.toString());
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    retributionId = ModalRoute.of(context)?.settings.arguments as int;

    return BlocProvider(
        create: (context) => ParkingBloc()..checkDetailParking(retributionId.toString()),
        child: BlocListener<ParkingBloc, ParkingState>(
            listener: (context, state) async{
              if (state is LoadingState) {
                state.show ? _loadingDialog.show(context) : _loadingDialog.hide();
              } else if (state is CheckDetailParkingSuccessState) {
                var iconMarker = await _loadParkIcon();
                setState(() {
                  parkingCheckDetail = state.data;
                  markers = [
                    Marker(
                      markerId: const MarkerId("1"),
                      position: LatLng(
                        double.parse(state.data.retribusi.lat),
                        double.parse(state.data.retribusi.long),
                      ),
                      icon: iconMarker,
                    )
                  ];
                });
              // } else if (state is PaymentCheckSuccessState) {
              //   debugPrint("pay now ${state.payNow}");
              //   if(state.payNow == PAY_NOW_CODE){
              //     await SpUtil.putString(PAYMENT_STEP, PAY_LATER);
              //     Navigator.pushNamed(context, "/payment", arguments: {
              //       "retribusi": parkingCheckDetail?.retribusi,
              //       "jam": timeSelected,
              //       "durasi": duration,
              //       PAYMENT_STEP: PAY_NOW
              //     });
              //   }else{
              //     await SpUtil.putString(PAYMENT_STEP, PAY_LATER);
              //     Navigator.of(context).pop(PAY_LATER);
              //   }
              } else if (state is CancelParkingSuccessState) {
                showTopSnackBar(
                  context,
                  const CustomSnackBar.success(
                    message: "Parkir berhasil dibatalkan",
                  ),
                );
                SpUtil.remove(RETRIBUTION_ID_ACTIVE);
                Navigator.of(context).pop();
              } else if (state is ErrorState) {
                showTopSnackBar(
                  context,
                  CustomSnackBar.error(
                    message: state.error,
                  ),
                );
              }
            },
            child: BlocBuilder<ParkingBloc, ParkingState>(
                builder: (context, state) {
                  _context = context;
                  return Scaffold(
                      extendBodyBehindAppBar: true,
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        toolbarHeight: 84,
                        titleSpacing: 0,
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        centerTitle: true,
                        leading: InkWell(
                          onTap: () {
                            _showCancelConfirmationDialog(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.cancel,
                              color: Red900,
                            ),
                          ),
                        ),
                        title: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Text(
                                parkingCheckDetail?.retribusi.lokasiParkir?.namaLokasi ?? "",
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.colorPrimary,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                parkingCheckDetail?.retribusi.lokasiParkir?.alamatLokasi ?? "",
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textPassive,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              debugPrint("id ret ${retributionId}");
                              context.read<ParkingBloc>().checkDetailParking(retributionId.toString());
                            },
                            icon: const Icon(Icons.refresh),
                            color: Red900,
                          ),
                        ],
                      ),
                      body: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          parkingCheckDetail?.retribusi.lat != null? GoogleMap(
                              mapType: MapType.normal,
                              zoomControlsEnabled: false,
                              initialCameraPosition:  CameraPosition(
                                target: LatLng(
                                  double.parse(parkingCheckDetail!.retribusi.lat),
                                  double.parse(parkingCheckDetail!.retribusi.long),
                                ),
                                zoom: 15.0,
                              ),
                              markers: Set<Marker>.from(markers),
                          ): Container(),
                          parkingCheckDetail?.retribusi.idJukir == null ? Container(
                            color: Colors.white,
                            height: 200,
                            constraints: const BoxConstraints(
                              maxHeight: 200
                            ),
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Menunggu Juru Parkir",
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Tunggu sebentar..",
                                  style: TextStyle(
                                    color: AppColors.textPassive,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          ): payNow ? buildSelectTime(context, state)
                          : buildParkingConfirmation(context),
                        ],
                      )
                  );
                }
            )
        )
    );
  }


  void _showCancelConfirmationDialog(BuildContext _context) {
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
                _context.read<ParkingBloc>().cancelParking((parkingCheckDetail?.retribusi.lokasiParkir?.id ?? 0).toString());
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

  Widget buildParkingConfirmation(BuildContext context){
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
       mainAxisSize: MainAxisSize.min,
       children: [
         const Text("Kendaran Kamu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
         const SizedBox(height: 20,),
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const Text("Jenis : ", style: TextStyle(fontWeight: FontWeight.normal)),
             Text(parkingCheckDetail!.retribusi.jenisKendaraan.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
           ],
         ),
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Text("No. Polisi : ", style: TextStyle(fontWeight: FontWeight.normal)),
             Text(parkingCheckDetail!.retribusi.nopol.toString(), style: TextStyle(fontWeight: FontWeight.bold)),

           ],
         ),
         const SizedBox(height: 50,),
         ButtonDefault(title: "Bayar Nanti", color: AppColors.greenLight, textColor: AppColors.green, onTap: () async{
           // context.read<ParkingBloc>().paymentChoice(retributionId, PAY_LATER_CODE);

           await SpUtil.putString(PAYMENT_CHOICE, PaymentChoice.payLater.name);
           Navigator.of(context).pop(PAYMENT_CHOICE);
         }),
         const SizedBox(height: 10,),
         ButtonDefault(title: "Bayar Sekarang", color: AppColors.green, onTap: (){
           setState(() {
             payNow = true;
           });
         }),
       ],
      ),
    );
  }
  Widget buildSelectTime(BuildContext context, ParkingState state){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
       children: [
         const Text("Kendaran Kamu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
         const SizedBox(height: 20,),
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const Text("Jenis : ", style: TextStyle(fontWeight: FontWeight.normal)),
             Text(parkingCheckDetail!.retribusi.jenisKendaraan.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
           ],
         ),
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Text("No. Polisi : ", style: TextStyle(fontWeight: FontWeight.normal)),
             Text(parkingCheckDetail!.retribusi.nopol.toString(), style: TextStyle(fontWeight: FontWeight.bold)),

           ],
         ),
         const SizedBox(height: 30,),
         ButtonDefault(title: timeSelected ?? "Pilih Jam", color: AppColors.cardGrey, textColor: AppColors.text, onTap: () async{
           TimeOfDay? pickedTime =  await showTimePicker(
             initialTime: TimeOfDay.now(),
             initialEntryMode: TimePickerEntryMode.inputOnly,
             context: context, //context of current state
           );

           if(pickedTime != null ){

             var now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, pickedTime.hour, pickedTime.minute);
             if( DateTime.now().hour> pickedTime.hour){
               now = now.add(Duration(days: 1));
             }
             print("Time is ${ pickedTime.hour}, ${pickedTime.minute} $now ${parkingCheckDetail!.retribusi.createdAt}");
             setState(() {
               timeSelected = "${pickedTime.hour}:${pickedTime.minute}";
               duration = now.difference(parkingCheckDetail!.retribusi.createdAt);
               print("duration is ${ duration?.inHours.toString()},${duration?.inMinutes.toString()} ${ duration?.inMinutes.remainder(60).toString()}");
             });
           }else{
             print("Time is not selected");
           }
         }),
         const SizedBox(height: 20,),
         Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisSize: MainAxisSize.min,
               children: [
                 Text("Lokasi : ", style: TextStyle(color: AppColors.text)),
                 Text(parkingCheckDetail!.retribusi.lokasiParkir?.namaLokasi ?? "-", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                 Text(parkingCheckDetail!.retribusi.lokasiParkir?.alamatLokasi ?? "-", style: TextStyle(color: AppColors.text)),
               ],
             ),
             SizedBox(width: 20,),
             Column(
               crossAxisAlignment: CrossAxisAlignment.end,
               children: [
                 const Text("Tarif :", style: TextStyle(color: AppColors.text)),
                 Text("Rp ${parkingCheckDetail!.retribusi.biayaParkir?.biayaParkir ?? 0}", style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
               ],
             )

           ],
         ),
         const SizedBox(height: 30,),
         ButtonDefault(title: "Bayar Sekarang", color: AppColors.green, disable: state is LoadingState, onTap: (){
           if(timeSelected == null){
             showTopSnackBar(
               context,
               const CustomSnackBar.error(
                 message: "Pilih jam terlebih dahulu",
               ),
             );
           }else{

             // context.read<ParkingBloc>().paymentChoice(retributionId, PAY_NOW_CODE);
             SpUtil.putString(PAYMENT_CHOICE, PaymentChoice.payNow.name);
             Navigator.pushNamed(context, "/payment", arguments: {
               "retribusi": parkingCheckDetail?.retribusi,
               "jam": timeSelected,
               "durasi": duration,
               PAYMENT_CHOICE: PaymentChoice.payNow.name
             });
           }
         }),
       ],
      ),
    );
  }

  Future<BitmapDescriptor> _loadParkIcon() async {
    final ByteData data = await rootBundle.load('assets/images/yourloc.png');
    return  BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }
}