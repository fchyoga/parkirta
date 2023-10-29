import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:parkirta/data/endpoint.dart';
import 'package:parkirta/data/message/response/general_response.dart';
import 'package:parkirta/data/message/response/login_response.dart';
import 'package:parkirta/data/message/response/wallet/wallet_detail_response.dart';
import 'package:parkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class WalletRepository {
  String? token = SpUtil.getString(API_TOKEN);

  Future<WalletDetailResponse> checkDetailWallet(String id) async {
    try {
      var response = await http.get(
        Uri.parse("${Endpoint.urlWalletDetail}"),
        headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("request id $id");
      debugPrint("response ${response.body}");
      return response.statusCode == 200
          ? WalletDetailResponseFromJson(response.body)
          : WalletDetailResponse(success: false, message: "Failed get data");
    } on HttpException catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return WalletDetailResponse(success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return WalletDetailResponse(success: false, message: e.toString());
    }
  }
}
