enum PaymentChoice {
  payNow("Pay Now", "1"),
  payLater("Pay Later", "0"),
  viaJukir("Via Jukir", "1"),
  notViaJukir("Not Via Jukir", "0");

  final String name;
  final String value;
  const PaymentChoice(this.name, this.value);
}
