import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:parkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:parkirta/data/message/response/parking/parking_location_response.dart';
import 'package:parkirta/data/message/response/parking/submit_arrive_response.dart';
import 'package:parkirta/data/repository/parking_repository.dart';
import 'package:parkirta/utils/contsant/transaction_const.dart';
import 'package:sp_util/sp_util.dart';

class HomeBloc extends Cubit<HomeState> {
  final ParkingRepository _parkingRepository = ParkingRepository();

  HomeBloc() : super(Initial());

  void initial(){
    emit(Initial());
  }

  Future<void> submitArrival(String locationId, String userId, String lat, String lng) async {
    emit(LoadingState(true));
    final response =
        await _parkingRepository.submitArrival(locationId, userId, lat, lng);
    emit(LoadingState(false));
    if (response.success) {
      emit(SuccessSubmitArrivalState(data: response.data!));
    } else {
      emit(ErrorState(error: response.message));
    }
  }

  Future<void> getParkingLocation() async {
    emit(LoadingState(true));
    final response =
        await _parkingRepository.parkingLocation();
    emit(LoadingState(false));
    if (response.success) {
      emit(SuccessGetParkingLocationState(data: response.data));
    } else {
      emit(ErrorState(error: response.message));
    }
  }


  Future<void> checkDetailParking(String id) async {
    emit(LoadingState(true));
    final response =
    await _parkingRepository.checkDetailParking(id);
    emit(LoadingState(false));
    if (response.success) {
      SpUtil.putString(PARKING_STATUS, response.data!.retribusi.statusParkir);
      emit(CheckDetailParkingSuccessState(data: response.data!));
    } else {
      emit(ErrorState(error: response.message));
    }
  }
}

abstract class HomeState {
  const HomeState();
}

class Initial extends HomeState {
}

class SuccessGetParkingLocationState extends HomeState {
  final List<ParkingLocation> data;
  const SuccessGetParkingLocationState({required this.data});
}

class SuccessSubmitArrivalState extends HomeState {
  final SubmitArrival data;
  const SuccessSubmitArrivalState({required this.data});
}

class CheckDetailParkingSuccessState extends HomeState {
  final ParkingCheckDetail data;
  const CheckDetailParkingSuccessState({required this.data});
}

class ErrorState extends HomeState {
  final String error;
  const ErrorState({required this.error});

}

class LoadingState extends HomeState {
  final show;
  LoadingState(this.show);
}

class PasswordState extends HomeState {
}

