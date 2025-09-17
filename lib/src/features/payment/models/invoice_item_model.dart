import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/firebase_field_names.dart';

class InvoiceItemModel {
  final String description;
  final String type; // 'service' or 'part'
  final int quantity;
  final double unitPrice;
  final double itemTotal;

  InvoiceItemModel({
    required this.description,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.itemTotal,
  });

  Map<String, dynamic> toJson() {
    return {
      FirebaseFieldNames.description: description,
      FirebaseFieldNames.type: type,
      FirebaseFieldNames.quantity: quantity,
      FirebaseFieldNames.unitPrice: unitPrice,
      FirebaseFieldNames.itemTotal: itemTotal,
    };
  }

  factory InvoiceItemModel.fromMap(Map<String, dynamic> data) {
    return InvoiceItemModel(
      description: data[FirebaseFieldNames.description] ?? '',
      type: data[FirebaseFieldNames.type] ?? '',
      quantity: (data[FirebaseFieldNames.quantity] ?? 0).toInt(),
      unitPrice: (data[FirebaseFieldNames.unitPrice] ?? 0.0).toDouble(),
      itemTotal: (data[FirebaseFieldNames.itemTotal] ?? 0.0).toDouble(),
    );
  }
}