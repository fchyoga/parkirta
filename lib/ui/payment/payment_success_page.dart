import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:parkirta/bloc/parking_bloc.dart';
import 'package:parkirta/data/model/retribusi.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';
import 'package:parkirta/utils/contsant/transaction_const.dart';
import 'package:parkirta/widget/button/button_default.dart';
import 'package:parkirta/widget/loading_dialog.dart';
import 'package:sp_util/sp_util.dart';
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
    var id = ModalRoute.of(context)?.settings.arguments as int?;
    return BlocProvider(
        create: (context) => ParkingBloc()..checkDetailParking(id.toString()),
        child: BlocListener<ParkingBloc, ParkingState>(listener:
            (context, state) async {
          if (state is LoadingState) {
            state.show ? _loadingDialog.show(context) : _loadingDialog.hide();
          } else if (state is CheckDetailParkingSuccessState) {
            updateParkingData(state.data.retribusi);
            setState(() {
              retribution = state.data.retribusi;
            });
          }
        }, child:
            BlocBuilder<ParkingBloc, ParkingState>(builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/", (route) => false);
              return true;
            },
            child: Scaffold(
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
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          const Text("Pembayaran Berhasil",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.text)),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 30),
                            child: Text(
                                retribution?.pembayaran?.noInvoice ?? "",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: AppColors.colorPrimary)),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Lokasi : ",
                                      style: TextStyle(color: AppColors.text)),
                                  Text(
                                      retribution?.lokasiParkir?.namaLokasi ??
                                          "",
                                      style: TextStyle(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      retribution?.lokasiParkir?.alamatLokasi ??
                                          "",
                                      style: TextStyle(
                                          color: AppColors.textPassive)),
                                ],
                              )),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("Tarif :",
                                      style: TextStyle(color: AppColors.text)),
                                  Text(
                                      "Rp ${retribution?.subtotalBiaya ?? "0"}",
                                      style: TextStyle(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ButtonDefault(
                              title: "Selesai",
                              color: AppColors.green,
                              onTap: () {
                                SpUtil.remove(RETRIBUTION_ID_ACTIVE);
                                Navigator.pushNamedAndRemoveUntil(
                                    context, "/", (route) => false);
                              }),
                        ],
                      ),
                    )
                  ],
                )),
          );
        })));
  }

  Future<void> updateParkingData(Retribusi retribution) async {
    var retributions = await Hive.openBox<Retribusi>(RETRIBUTION_BOX);
    retributions.put(0, retribution);
    // SpUtil.remove(RETRIBUTION_ID_ACTIVE);
    // SpUtil.remove(PAYMENT_STEP);
    // SpUtil.remove(INVOICE_ACTIVE);
  }
}
