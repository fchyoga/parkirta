import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:parkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:parkirta/data/message/response/payment/payment_entry_response.dart';
import 'package:parkirta/data/repository/parking_repository.dart';
import 'package:parkirta/data/repository/payment_repository.dart';
import 'package:parkirta/data/repository/user_repository.dart';
import 'package:parkirta/utils/contsant/transaction_const.dart';
import 'package:parkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class PaymentBloc extends Cubit<PaymentState> {
  PaymentRepository _paymentRepository = PaymentRepository();
  ParkingRepository _parkingRepository = ParkingRepository();

  PaymentBloc() : super(ArriveInitial());

  Future<void> paymentChoice(int retributionId, int payNow) async {
    debugPrint("pay now $payNow");
    emit(LoadingState(true));
    final response =
    await _paymentRepository.paymentChoice(retributionId, payNow);
    emit(LoadingState(false));
    // emit(paymentChoiceSuccessState(payNow: payNow));

    if (response.success) {
      emit(PaymentChoiceSuccessState(payNow: payNow));
    } else {
      emit(ErrorState(error: response.message));
    }
  }

  Future<void> paymentEntry(int retributionId, int totalHours, int viaJukir) async {
    emit(LoadingState(true));
    final response =
    await _paymentRepository.paymentEntry(retributionId, totalHours, viaJukir);
    emit(LoadingState(false));
    if (response.success) {
      SpUtil.putString(INVOICE_ACTIVE, response.data!.pembayaran.noInvoice);
      emit(PaymentEntrySuccessState(viaJukir: viaJukir == VIA_JUKIR_CODE, paymentInfo: response.data!.pembayaran));
    } else {
      emit(ErrorState(error: response.message));
    }
  }

  Future<bool> paymentCheckout(String inv, String pin) async {
    emit(LoadingState(true));
    final response =
    await _paymentRepository.paymentCheckout(inv, pin);
    emit(LoadingState(false));
    if (response.success) {
      SpUtil.remove(RETRIBUTION_ID_ACTIVE);
      SpUtil.remove(INVOICE_ACTIVE);
      return true;
    } else {
      emit(ErrorState(error: response.message));
      return false;
    }
  }

  Future<void> leaveParking(int id, int viaJukir) async {
    emit(LoadingState(true));
    final response = await _parkingRepository.leaveParking(id, viaJukir);
    emit(LoadingState(false));
    if (response.success) {
      SpUtil.putString(INVOICE_ACTIVE, response.data!.pembayaran.noInvoice);
      emit(LeaveParkingSuccessState(viaJukir: viaJukir == VIA_JUKIR_CODE, paymentInfo: response.data!.pembayaran));
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

class PaymentChoiceSuccessState extends PaymentState {
  final int payNow;
  const PaymentChoiceSuccessState({required this.payNow});
}

class PaymentEntrySuccessState extends PaymentState {
  final bool viaJukir;
  final PaymentEntry paymentInfo;
  const PaymentEntrySuccessState({required this.viaJukir, required this.paymentInfo});
}

class PaymentCheckoutSuccessState extends PaymentState {
  // final ParkingCheckDetail data;
  // const paymentChoiceSuccessState({required this.data});
}

class LeaveParkingSuccessState extends PaymentState {
  final bool viaJukir;
  final PaymentEntry paymentInfo;
  const LeaveParkingSuccessState({required this.viaJukir, required this.paymentInfo});
}




class ErrorState extends PaymentState {
  final String error;
  const ErrorState({required this.error});

}

class LoadingState extends PaymentState {
  final show;
  LoadingState(this.show);
}


