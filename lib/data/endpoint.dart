class Endpoint {
  static const _baseUrl = 'https://parkirta.com/api/';
  // static const _baseUrl = 'https://prd.parkirta.test/api/';

  get baseUrl => _baseUrl;
  bool isDevelopment = _baseUrl == 'https://parkirta.com/api/';

  static const String urlLogin = '${_baseUrl}login/pelanggan';
  static const String urlNotification= '${_baseUrl}notifikasi/pelanggan';
  static const String urlReadNotification= '${_baseUrl}notifikasi/pelanggan/read/update';
  static const String urlParkingLocation = '${_baseUrl}master/lokasi_parkir';
  static const String urlArrival = '${_baseUrl}retribusi/parking/arrive';
  static const String urlCheckDetailParking =
      '${_baseUrl}retribusi/parking/check/detail';
  static const String urlCancelParking = '${_baseUrl}retribusi/parking/cancel';
  static const String urlLeaveParking = '${_baseUrl}retribusi/parking/leave';
  static const String urlPaymentCheck = '${_baseUrl}retribusi/payment/choice';
  static const String urlPaymentEntry = '${_baseUrl}retribusi/payment/entry';
  static const String urlPaymentCheckout =
      '${_baseUrl}retribusi/payment/checkout';
  static const String urlPaymentJukir = '${_baseUrl}retribusi/payment/jukir';
  static const String urlWalletDetail = '${_baseUrl}dompet/detail';
}
