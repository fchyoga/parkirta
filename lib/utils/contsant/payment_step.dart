enum PaymentStep {
  paymentChoice("Payment Choice"),
  paymentEntry("Payment Entry"),
  firstPaymentCheckout("First Payment Checkout"),
  parkingLeave("Parking Leave"),
  paymentCheckout("Payment Checkout");

  final String name;
  const PaymentStep(this.name);
}
