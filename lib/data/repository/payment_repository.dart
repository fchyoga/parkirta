import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:parkirta/data/endpoint.dart';
import 'package:parkirta/data/message/response/general_response.dart';
import 'package:parkirta/data/message/response/login_response.dart';
import 'package:parkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:parkirta/data/message/response/parking/submit_arrive_response.dart';
import 'package:parkirta/data/message/response/payment/payment_entry_response.dart';
import 'package:parkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class PaymentRepository {

  String? token = SpUtil.getString(API_TOKEN);

  Future<GeneralResponse> paymentChoice(int retributionId, int payNow) async {
    try {
      Map<String, dynamic> data = {
        'id_retribusi_parkir': retributionId.toString(),
        'is_pay_now': payNow.toString()
      };
      var response = await http.post(
          Uri.parse(Endpoint.urlPaymentCheck),
          body: data,
          headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("request $data");
      debugPrint("response ${response.body}");
      return response.statusCode == 200 || response.statusCode == 404 ? generalResponseFromJson(response.body)
      : GeneralResponse( success: false, message: "Failed submit payment check");
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse( success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse( success: false, message:  e.toString());
    }
  }

  Future<PaymentEntryResponse> paymentEntry(int retributionId, int totalHours, int viaJukir) async {
    try {
      Map<String, dynamic> data = {
        'id_retribusi_parkir': retributionId.toString(),
        'jumlah_jam': totalHours.toString(),
        'is_via_jukir': viaJukir.toString()
      };
      var response = await http.post(
          Uri.parse(Endpoint.urlPaymentEntry),
          body: data,
          headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("request $data");
      debugPrint("response ${response.body}");
      return response.statusCode == 200 ? paymentEntryResponseFromJson(response.body)
      : paymentEntryResponseFromJson(response.body);
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return PaymentEntryResponse( success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return PaymentEntryResponse( success: false, message:  e.toString());
    }
  }

  Future<GeneralResponse> paymentCheckout(String inv, String pin) async {
    try {
      Map<String, dynamic> data = {
        'no_invoice': inv,
        'pin': pin
      };
      var response = await http.post(
          Uri.parse(Endpoint.urlPaymentCheckout),
          body: data,
          headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("request $data");
      debugPrint("response ${response.body}");
      debugPrint("response code ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 404 ? generalResponseFromJson(response.body)
      : GeneralResponse( success: false, message: "Failed submit payment checkout");
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse( success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse( success: false, message:  e.toString());
    }
  }



}
