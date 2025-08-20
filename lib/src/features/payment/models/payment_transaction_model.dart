import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/firebase_field_names.dart';

class PaymentTransactionModel {
  final String transactionId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final DateTime transactionDateTime;
  final String status;

  PaymentTransactionModel({
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.transactionDateTime,
    required this.status
  });

  /// Empty
  static PaymentTransactionModel empty() {
    return PaymentTransactionModel(
      transactionId: '',
      amount: 0.0,
      currency: '',
      paymentMethod: '',
      transactionDateTime: DateTime(0),
      status: '',
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      FirebaseFieldNames.transactionId: transactionId,
      FirebaseFieldNames.amount: amount,
      FirebaseFieldNames.currency: currency,
      FirebaseFieldNames.paymentMethod: paymentMethod,
      FirebaseFieldNames.transactionDateTime:
          Timestamp.fromDate(transactionDateTime),
      FirebaseFieldNames.status: status,
    };
  }

  /// From Snapshot
  factory PaymentTransactionModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return PaymentTransactionModel.empty();

    return PaymentTransactionModel(
      transactionId: data[FirebaseFieldNames.transactionId] ?? '',
      amount: (data[FirebaseFieldNames.amount] ?? 0).toDouble(),
      currency: data[FirebaseFieldNames.currency] ?? '',
      paymentMethod: data[FirebaseFieldNames.paymentMethod] ?? '',
      transactionDateTime:
          (data[FirebaseFieldNames.transactionDateTime] as Timestamp).toDate(),
      status: data[FirebaseFieldNames.status] ?? '',
    );
  }

  /// From Map (useful for nested docs)
  factory PaymentTransactionModel.fromMap(Map<String, dynamic> data) {
    return PaymentTransactionModel(
      transactionId: data[FirebaseFieldNames.transactionId] ?? '',
      amount: (data[FirebaseFieldNames.amount] ?? 0).toDouble(),
      currency: data[FirebaseFieldNames.currency] ?? '',
      paymentMethod: data[FirebaseFieldNames.paymentMethod] ?? '',
      transactionDateTime:
          (data[FirebaseFieldNames.transactionDateTime] as Timestamp).toDate(),
      status: data[FirebaseFieldNames.status] ?? '',
    );
  }
}
