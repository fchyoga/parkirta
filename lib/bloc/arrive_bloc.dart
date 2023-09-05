import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:parkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:parkirta/data/repository/parking_repository.dart';
import 'package:parkirta/data/repository/payment_repository.dart';
import 'package:parkirta/data/repository/user_repository.dart';
import 'package:parkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class ArriveBloc extends Cubit<ArriveState> {
  ParkingRepository _parkingRepository = ParkingRepository();
  PaymentRepository _paymentRepository = PaymentRepository();

  ArriveBloc() : super(ArriveInitial());

  Future<void> checkDetailParking(String id) async {
    emit(LoadingState(true));
    final response =
    await _parkingRepository.checkDetailParking(id);
    emit(LoadingState(false));
    if (response.success) {
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

  Future<void> paymentCheck(int retributionId, int payNow) async {
    emit(LoadingState(true));
    final response =
    await _paymentRepository.paymentCheck(retributionId, payNow);
    emit(LoadingState(false));
    if (response.success) {
      emit(PaymentCheckSuccessState());
    } else {
      emit(ErrorState(error: response.message));
    }
  }


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

abstract class ArriveState {
  const ArriveState();
}

class ArriveInitial extends ArriveState {
}

class CheckDetailParkingSuccessState extends ArriveState {
  final ParkingCheckDetail data;
  const CheckDetailParkingSuccessState({required this.data});
}

class  CancelParkingSuccessState extends ArriveState {
}

class PaymentCheckSuccessState extends ArriveState {
  // final ParkingCheckDetail data;
  // const PaymentCheckSuccessState({required this.data});
}

// class PaymentEntrySuccessState extends ArriveState {
// }

class ErrorState extends ArriveState {
  final String error;
  const ErrorState({required this.error});

}

class LoadingState extends ArriveState {
  final show;
  LoadingState(this.show);
}


