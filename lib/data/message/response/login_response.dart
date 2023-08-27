// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

import 'package:parkirta/data/model/user.dart';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  LoginResponse({
    required this.success,
    this.message,
    this.data,
  });

  bool success;
  String? message;
  LoginData? data;


  LoginResponse.withError(this.success, this.message);

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    success: json["success"],
    message: json["message"],
    data: LoginData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}



class LoginData {
  LoginData({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  String accessToken;
  String tokenType;
  User user;

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
    accessToken: json["access_token"],
    tokenType: json["token_type"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "token_type": tokenType,
    "user": user.toJson(),
  };
}


