import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:parkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:parkirta/data/repository/parking_repository.dart';
import 'package:parkirta/data/repository/payment_repository.dart';
import 'package:parkirta/data/repository/user_repository.dart';
import 'package:parkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class PaymentBloc extends Cubit<PaymentState> {
  PaymentRepository _paymentRepository = PaymentRepository();

  PaymentBloc() : super(ArriveInitial());

  Future<void> paymentEntry(int retributionId, int totalHours, int viaJukir) async {
    emit(LoadingState(true));
    final response =
    await _paymentRepository.paymentEntry(retributionId, totalHours, viaJukir);
    emit(LoadingState(false));
    if (response.success) {
      emit(PaymentEntrySuccessState());
    } else {
      emit(ErrorState(error: response.message));
    }
  }

  Future<void> paymentCheckout(String inv, int pin) async {
    emit(LoadingState(true));
    final response =
    await _paymentRepository.paymentCheckout(inv, pin);
    emit(LoadingState(false));
    if (response.success) {
      emit(PaymentCheckoutSuccessState());
    } else {
      emit(ErrorState(error: response.message));
    }
  }
}

abstract class PaymentState {
  const PaymentState();
}

class ArriveInitial extends PaymentState {
}

class PaymentEntrySuccessState extends PaymentState {
  // final ParkingCheckDetail data;
  // const PaymentCheckSuccessState({required this.data});
}

class PaymentCheckoutSuccessState extends PaymentState {
  // final ParkingCheckDetail data;
  // const PaymentCheckSuccessState({required this.data});
}

class ErrorState extends PaymentState {
  final String error;
  const ErrorState({required this.error});

}

class LoadingState extends PaymentState {
  final show;
  LoadingState(this.show);
}


