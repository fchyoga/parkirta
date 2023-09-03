import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:parkirta/data/endpoint.dart';
import 'package:parkirta/data/message/response/general_response.dart';
import 'package:parkirta/data/message/response/login_response.dart';
import 'package:parkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:parkirta/data/message/response/parking/submit_arrive_response.dart';
import 'package:parkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class PaymentRepository {

  String? token = SpUtil.getString(API_TOKEN);

  Future<GeneralResponse> paymentCheck(int retributionId, int payNow) async {
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

  Future<GeneralResponse> paymentEntry(int retributionId, int totalHours, int viaJukir) async {
    try {
      Map<String, dynamic> data = {
        'id_retribusi_parkir': retributionId,
        'jumlah_jam': totalHours,
        'is_via_jukir': viaJukir
      };
      var response = await http.post(
          Uri.parse(Endpoint.urlPaymentEntry),
          body: data,
          headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("response ${response.body}");
      return response.statusCode == 200 ? generalResponseFromJson(response.body)
      : GeneralResponse( success: false, message: "Failed submit payment check");
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse( success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse( success: false, message:  e.toString());
    }
  }

  Future<GeneralResponse> paymentCheckout(String inv, int pin) async {
    try {
      Map<String, dynamic> data = {
        'no_invoice': inv,
        'pin': pin.toString()
      };
      var response = await http.post(
          Uri.parse(Endpoint.urlPaymentCheck),
          body: data,
          headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("response ${response.body}");
      return response.statusCode == 200 ? generalResponseFromJson(response.body)
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
