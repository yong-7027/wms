class APIConstants {
  APIConstants._();

  // Base URL for your backend API
  static const String baseUrl = 'https://us-central1-workshop-management-syst-b9cec.cloudfunctions.net/api';

  // Stripe endpoints
  static const String createPaymentIntent = '$baseUrl/create-payment-intent';
  static const String confirmPayment = '$baseUrl/confirm-payment';

  // Other payment endpoints
  static const String paypalPayment = '$baseUrl/paypal-payment';
  static const String razorpayPayment = '$baseUrl/razorpay-payment';

  // Subscription endpoints
  static const String subscriptionPlans = '$baseUrl/subscription-plans';
  static const String userSubscription = '$baseUrl/user-subscription';
}