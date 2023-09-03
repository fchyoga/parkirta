import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:parkirta/bloc/payment_bloc.dart';
import 'package:parkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:parkirta/color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:parkirta/utils/contsant/app_colors.dart';
import 'package:parkirta/utils/contsant/transaction_const.dart';
import 'package:parkirta/widget/button/button_default.dart';
import 'package:parkirta/widget/loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';


class PaymentSuccessPage extends StatefulWidget {

  PaymentSuccessPage();

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {

  final _loadingDialog = LoadingDialog();
  Retribusi? retribution;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.colorPrimary,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                children: [
                  Text("Pembayaran Berhasil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text)),
                  Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 30),
                    child: Text("TRX-0203AF23", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.colorPrimary)),
                  ),
                  Row(

                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Expanded(child:  Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text("Lokasi : ", style: TextStyle(color: AppColors.text)),
                         Text("Ratu Indah Mall", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                         Text("Jl. DR. Ratulangi No.35, Mangkura", style: TextStyle(color: AppColors.textPassive)),
                       ],
                     )),
                      SizedBox(width: 20,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Tarif :", style: TextStyle(color: AppColors.text)),
                          Text("Rp 5000", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                        ],
                      )

                    ],
                  ),
                  SizedBox(height: 20,),
                  ButtonDefault(title: "Selesai", color: AppColors.green,  onTap: (){
                    SpUtil.remove(RETRIBUTION_ID_ACTIVE);
                    Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
                  }),
                ],
              ),
            )
          ],
        )
    );
  }

}