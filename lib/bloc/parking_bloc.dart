import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:parkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:parkirta/data/model/retribusi.dart';
import 'package:parkirta/data/repository/parking_repository.dart';
import 'package:parkirta/data/repository/payment_repository.dart';
import 'package:parkirta/data/repository/user_repository.dart';
import 'package:parkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class ParkingBloc extends Cubit<ParkingState> {
  ParkingRepository _parkingRepository = ParkingRepository();
  PaymentRepository _paymentRepository = PaymentRepository();

  ParkingBloc() : super(ParkingInitial());

  Future<void> checkDetailParking(String id) async {
    emit(LoadingState(true));
    final response =
    await _parkingRepository.checkDetailParking(id);
    emit(LoadingState(false));
    if (response.success) {
      var retributions = await Hive.openBox<Retribusi>('retribusiBox');
      retributions.put(0, response.data!.retribusi);

      emit(CheckDetailParkingSuccessState(data: response.data!));
    } else {
      emit(ErrorState(error: response.message));
    }
  }

  Future<void> cancelParking(String id) async {
    emit(LoadingState(true));
    final response =
    await _parkingRepository.cancelParking(id);
    emit(LoadingState(false));
    if (response.success || response.message == "Data Tidak Ditemukan.") {
      emit(CancelParkingSuccessState());
    } else {
      emit(ErrorState(error: response.message));
    }
  }

  // Future<void> paymentChoice(int retributionId, int payNow) async {
  //   debugPrint("pay now $payNow");
  //   emit(LoadingState(true));
  //   final response =
  //   await _paymentRepository.paymentChoice(retributionId, payNow);
  //   emit(LoadingState(false));
  //   // emit(PaymentCheckSuccessState(payNow: payNow));
  //
  //   if (response.success) {
  //     emit(PaymentCheckSuccessState(payNow: payNow));
  //   } else {
  //     emit(ErrorState(error: response.message));
  //   }
  // }


  // Future<void> paymentEntry(int retributionId, int totalHours, int viaJukir) async {
  //   emit(LoadingState(true));
  //   final response =
  //   await _paymentRepository.paymentEntry(retributionId, totalHours, viaJukir);
  //   emit(LoadingState(false));
  //   if (response.success) {
  //     emit(PaymentEntrySuccessState());
  //   } else {
  //     emit(ErrorState(error: response.message));
  //   }
  // }
}

abstract class ParkingState {
  const ParkingState();
}

class ParkingInitial extends ParkingState {
}

class CheckDetailParkingSuccessState extends ParkingState {
  final ParkingCheckDetail data;
  const CheckDetailParkingSuccessState({required this.data});
}

class  CancelParkingSuccessState extends ParkingState {
}

// class PaymentCheckSuccessState extends ParkingState {
//   final int payNow;
//   const PaymentCheckSuccessState({required this.payNow});
// }

// class PaymentEntrySuccessState extends ParkingState {
// }

class ErrorState extends ParkingState {
  final String error;
  const ErrorState({required this.error});

}

class LoadingState extends ParkingState {
  final show;
  LoadingState(this.show);
}


