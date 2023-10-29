import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:parkirta/data/message/response/wallet/wallet_detail_response.dart';
import 'package:parkirta/data/model/wallet.dart';
import 'package:parkirta/data/repository/wallet_repository.dart';
import 'package:sp_util/sp_util.dart';

class WalletBloc extends Cubit<WalletState> {
  WalletRepository _walletRepository = WalletRepository();

  WalletBloc() : super(WalletInitial());

  // Future<void> checkDetailWallet() async {
  //   emit(LoadingState(true));
  //   final response =
  //   await _walletRepository.checkDetailWallet();
  //   emit(LoadingState(false));
  //   if (response.success) {
  //     var wallets = await Hive.openBox<Wallet>('walletBox');
  //     wallets.put(0, Wallet(
  //       saldoPelanggan: response.data!.saldoPelanggan,
  //       saldoKartuParkir: response.data!.saldoKartuParkir,
  //     ));

  //     emit(CheckDetailWalletSuccessState(data: WalletDetailResponse(data: response.data!)));
  //   } else {
  //     emit(ErrorState(error: response.message));
  //   }
  // }
}

abstract class WalletState {
  const WalletState();
}

class WalletInitial extends WalletState {}

class CheckDetailWalletSuccessState extends WalletState {
  final WalletDetailResponse data;
  const CheckDetailWalletSuccessState({required this.data});
}

class ErrorState extends WalletState {
  final String error;
  const ErrorState({required this.error});
}

class LoadingState extends WalletState {
  final show;
  LoadingState(this.show);
}
