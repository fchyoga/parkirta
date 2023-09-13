import 'package:flutter/material.dart';
import 'package:parkirta/data/model/retribusi.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';
import 'package:parkirta/utils/contsant/transaction_const.dart';
import 'package:parkirta/widget/button/button_default.dart';
import 'package:parkirta/widget/loading_dialog.dart';
import 'package:sp_util/sp_util.dart';


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
                  const Text("Pembayaran Berhasil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text)),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 30),
                    child: Text("TRX-0203AF23", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.colorPrimary)),
                  ),
                  const Row(

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
                          Text("Tarif :", style: TextStyle(color: AppColors.text)),
                          Text("Rp 5000", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                        ],
                      )

                    ],
                  ),
                  const SizedBox(height: 20,),
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