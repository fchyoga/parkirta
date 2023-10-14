import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:parkirta/bloc/payment_bloc.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';
import 'package:parkirta/utils/contsant/parking_status.dart';
import 'package:parkirta/utils/contsant/payment_choice.dart';
import 'package:parkirta/utils/contsant/payment_methode.dart';
import 'package:parkirta/utils/contsant/payment_step.dart';
import 'package:parkirta/utils/contsant/transaction_const.dart';
import 'package:parkirta/widget/button/button_default.dart';
import 'package:parkirta/widget/loading_dialog.dart';
import 'package:sp_util/sp_util.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../data/model/retribusi.dart';


class PaymentPage extends StatefulWidget {

  PaymentPage();

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  final _loadingDialog = LoadingDialog();
  late BuildContext _context;
  Retribusi? retribution;
  Duration? duration;
  String? paymentStep = SpUtil.getString(PAYMENT_STEP, defValue: null);
  String? parkingStatus = SpUtil.getString(PARKING_STATUS, defValue: null);


  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)?.settings.arguments as Map;
    retribution = args["retribusi"];
    var time = args["jam"];
    duration = args["durasi"];
    debugPrint("cek time $time");
    debugPrint("cek hour ${duration!.inHours} : ${duration!.inMinutes.remainder(60)}");
    return BlocProvider(
        create: (context) => PaymentBloc(retribution!.id),
        child: BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) async{
              if (state is LoadingState) {
                state.show ? _loadingDialog.show(context) : _loadingDialog.hide();
                // } else if (state is CheckDetailParkingSuccessState) {
              } else if (state is PaymentChoiceSuccessState) {
                // SpUtil.putString(PAYMENT_STEP, PaymentStep.parkingStatus.name);
                // paymentStep =  PaymentStep.parkingStatus.name;
              } else if (state is LeaveParkingSuccessState) {
                SpUtil.putString(PAYMENT_STEP, PaymentStep.parkingLeave.name);
                SpUtil.putString(INVOICE_ACTIVE, state.paymentInfo.noInvoice);
                paymentStep =  PaymentStep.parkingLeave.name;
                if(state.paymentMethode == PaymentMethode.eWallet) {
                  openKeyPad(state.paymentInfo.noInvoice);
                }else{
                  showBottomSheetWaiting(context, retribution!.id, state);
                }
              } else if (state is PaymentCheckoutSuccessState) {
                SpUtil.putString(PAYMENT_STEP, PaymentStep.paymentCheckout.name);
                paymentStep =  PaymentStep.paymentCheckout.name;
              } else if (state is CheckDetailParkingSuccessState) {
                if(state.data.retribusi.statusParkir == ParkingStatus.telahKeluar.name){
                  Navigator.pushNamed(context,'/payment_success', arguments: state.data.retribusi.id);
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
            child: BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  _context = context;
                  return Scaffold(
                      backgroundColor: Colors.white,
                      appBar: AppBar(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        automaticallyImplyLeading: false,
                        centerTitle: true,
                        leading: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: AppColors.text,
                              size: 18,
                            ),
                          ),
                        ),
                        title: const Text(
                          "Pembayaran",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                      ),
                      body:   SingleChildScrollView(
                        child: Column(
                          children: [
                            retribution!=null ? buildParkingConfirmation(context, state):
                            const Text("Payment not found"),
                          ],
                        ),
                      )
                  );
                }
            )
        )
    );
  }

  Widget buildParkingConfirmation(BuildContext context, PaymentState state){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Container(
           padding: EdgeInsets.all(20),
           decoration: BoxDecoration(
             color: AppColors.cardGrey,
             borderRadius: BorderRadius.circular(10)
           ),
           child: Column(
             children: [
               Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Text("Waktu Parkir : ", style: TextStyle(fontWeight: FontWeight.normal)),
                 Text(getDurationString() ?? "-", style: const TextStyle(fontWeight: FontWeight.normal)),
               ],
             ),
               const SizedBox(height: 5),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text("Tarif Per-Jam : ", style: TextStyle(fontWeight: FontWeight.normal)),
                   Text("Rp ${retribution!.biayaParkir?.biayaParkir ?? 0}", style: TextStyle(fontWeight: FontWeight.normal)),

                 ],
               ),
               const SizedBox(height: 5),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text("Total : ", style: TextStyle(fontWeight: FontWeight.bold)),
                   Text("Rp ${getTotalPrice() ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold)),
                 ],
               ),
             ],
           ),
         ),

         const SizedBox(height: 80,),Text("Metode pembayaran", style: const TextStyle(fontWeight: FontWeight.bold)),
         const SizedBox(height: 10,),
         ButtonDefault(title: "E-Wallet", color: AppColors.green, onTap: () {
           var inv = SpUtil.getString(INVOICE_ACTIVE, defValue: null);
           debugPrint("testtt $inv ${inv==null} ${inv?.isEmpty}");
           if(inv==null) {
             context.read<PaymentBloc>().leaveParking(NOT_VIA_JUKIR_CODE, PaymentMethode.eWallet);
           }else{
             openKeyPad(inv);
           }
    }
           //   screenLock(
           // context: context,
           // correctString: 'x' * 6,
           //
           // title: const Padding(padding: EdgeInsets.only(bottom: 10), child: Text("Enter PIN", style: TextStyle(fontSize: 16),),),
           // onValidate: (value) async => await Future<bool>.delayed(
           //   const Duration(milliseconds: 500),
           //       () => true,
           // ),
           // onUnlocked: (){
           //   Navigator.of(context).pushNamed("/payment_success");
           // }

         // ),
         ),
         const SizedBox(height: 10,),
         ButtonDefault(title: "Cash", color: AppColors.greenLight, textColor: AppColors.green, onTap: (){
           if(paymentStep ==  PaymentStep.parkingLeave.name){
             showBottomSheetWaiting(context, retribution!.id, state);
           } else context.read<PaymentBloc>().leaveParking(VIA_JUKIR_CODE, PaymentMethode.cash);
         }),
         const SizedBox(height: 10,),
         ButtonDefault(title: "Card", color: AppColors.greenLight, textColor: AppColors.green, onTap: (){
           context.read<PaymentBloc>().leaveParking(VIA_JUKIR_CODE, PaymentMethode.card);
           // showBottomSheetWaiting(context);
         }),

       ],
      ),
    );
  }


  void showBottomSheetWaiting(BuildContext context, int id, PaymentState state) {

    // Timer(Duration(seconds: 5), (){
    //   Navigator.of(context).pushNamed("/payment_success");
    // });
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (ctx) {

          return SingleChildScrollView(
            child: AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets,
              duration: const Duration(milliseconds: 100),
              curve: Curves.decelerate,
              child: Container(
                constraints: const BoxConstraints(
                    minHeight: 200
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        state is LoadingState ? SizedBox.shrink():
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: IconButton(
                              onPressed: () {
                                context.read<PaymentBloc>().checkDetailParking(id.toString());
                              },
                              icon: const Icon(Icons.refresh_rounded, color: AppColors.text,)),
                        )
                      ],
                    ),
                    const SizedBox(height: 40,),
                    const Text(
                      "Menunggu Konfirmasi \nJuru Parkir",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Text(
                      "Tunggu sebentar..",
                      style: TextStyle(
                        color: AppColors.textPassive,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 50,),
                  ],
                ),
              ),
            ),
          );
        });
  }

  String? getDurationString(){
    if(duration!=null){
      var minutes = duration!.inMinutes.remainder(60) == 0 ? "1" :duration!.inMinutes.remainder(60).toString();
      return "${duration!.inHours} jam $minutes menit";
    }else{
      return null;
    }
  }

  String? getTotalPrice(){
    if(duration!=null && retribution?.biayaParkir?.biayaParkir !=null){

      var hour =  duration!.inMinutes.remainder(60) > 5 ? duration!.inHours + 1: duration!.inHours;
      debugPrint("cek hour ${duration!.inHours} : ${duration!.inMinutes.remainder(60)}");
      debugPrint("cek hour $hour * ${retribution!.biayaParkir!.biayaParkir}");
      return "${hour*retribution!.biayaParkir!.biayaParkir}";
    }else{
      return null;
    }
  }

  void openKeyPad(String inv){
    screenLock(
        context: context,
        correctString: 'x' * 6,
        title: const Padding(padding: EdgeInsets.only(bottom: 10), child: Text("Enter PIN", style: TextStyle(fontSize: 16),),),
        onValidate: (value) async => await _context.read<PaymentBloc>().paymentCheckout(inv, value),
        onUnlocked: (){
          Navigator.pushNamedAndRemoveUntil(context, '/payment_success', ModalRoute.withName('/'), arguments: retribution?.id);
        },
        onError: (value){
          Navigator.pop(context);
        }
    );
  }
}