import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:parkirta/data/endpoint.dart';
import 'package:parkirta/data/message/response/login_response.dart';
import 'package:parkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:parkirta/data/message/response/parking/submit_arrive_response.dart';
import 'package:parkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class ParkingRepository {

  String? token = SpUtil.getString(API_TOKEN);

  Future<SubmitArriveResponse> submitArrival(String locationId, String userId, String lat, String lng) async {
    try {
      Map<String, dynamic> data = {
        'id_lokasi_parkir': locationId.toString(),
        'id_pelanggan': userId.toString(),
        'lat': lat,
        'long': lng
      };
      var response = await http.post(
          Uri.parse(Endpoint.urlArrival),
          body: data,
          headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200 ? submitArriveResponseFromJson(response.body)
      : SubmitArriveResponse( success: false, message: "Failed submit arrival");
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return SubmitArriveResponse( success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return SubmitArriveResponse( success: false, message:  e.toString());
    }
  }

  Future<ParkingCheckDetailResponse> checkDetailParking(String id) async {
    try {
      var response = await http.get(
          Uri.parse("${Endpoint.urlCheckDetailParking}/$id"),
          headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("response ${response.body}");
      return response.statusCode == 200 ? parkingCheckDetailResponseFromJson(response.body)
      : ParkingCheckDetailResponse( success: false, message: "Failed get data");
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ParkingCheckDetailResponse( success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ParkingCheckDetailResponse( success: false, message:  e.toString());
    }
  }




}
