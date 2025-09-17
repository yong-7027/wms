import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/firebase_field_names.dart';
import 'invoice_item_model.dart';

class InvoiceModel {
  final String invoiceId;
  final String appointmentId;
  final String status; // 'unpaid', 'paid', 'overdue', 'void'
  final DateTime issuedAt;
  final DateTime dueAt;
  final List<InvoiceItemModel> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String? pdfUrl;
  final DateTime createdAt;

  InvoiceModel({
    required this.invoiceId,
    required this.appointmentId,
    required this.status,
    required this.issuedAt,
    required this.dueAt,
    required this.items,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    this.pdfUrl,
    required this.createdAt,
  });

  /// Empty Invoice
  static InvoiceModel empty() {
    return InvoiceModel(
      invoiceId: '',
      appointmentId: '',
      status: 'unpaid',
      issuedAt: DateTime(0),
      dueAt: DateTime(0),
      items: [],
      subtotal: 0.0,
      taxRate: 0.0,
      taxAmount: 0.0,
      totalAmount: 0.0,
      pdfUrl: null,
      createdAt: DateTime(0),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      FirebaseFieldNames.invoiceId: invoiceId,
      FirebaseFieldNames.appointmentId: appointmentId,
      FirebaseFieldNames.status: status,
      FirebaseFieldNames.issuedAt: Timestamp.fromDate(issuedAt),
      FirebaseFieldNames.dueAt: Timestamp.fromDate(dueAt),
      FirebaseFieldNames.items: items.map((item) => item.toJson()).toList(),
      FirebaseFieldNames.subtotal: subtotal,
      FirebaseFieldNames.taxRate: taxRate,
      FirebaseFieldNames.taxAmount: taxAmount,
      FirebaseFieldNames.totalAmount: totalAmount,
      FirebaseFieldNames.pdfUrl: pdfUrl,
      FirebaseFieldNames.createdAt: Timestamp.fromDate(createdAt),
    };
  }

  /// From Snapshot
  factory InvoiceModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return InvoiceModel.empty();

    // 将 Timestamp 转换为 DateTime
    Timestamp getTimestamp(String fieldName) => data[fieldName] ?? Timestamp.fromDate(DateTime(0));

    // 处理 items 数组
    List<dynamic> itemsData = data[FirebaseFieldNames.items] ?? [];
    List<InvoiceItemModel> itemsList = itemsData.map((itemMap) => InvoiceItemModel.fromMap(itemMap)).toList();

    return InvoiceModel(
      invoiceId: document.id, // 从文档ID获取
      appointmentId: data[FirebaseFieldNames.appointmentId] ?? '',
      status: data[FirebaseFieldNames.status] ?? 'unpaid',
      issuedAt: getTimestamp(FirebaseFieldNames.issuedAt).toDate(),
      dueAt: getTimestamp(FirebaseFieldNames.dueAt).toDate(),
      items: itemsList,
      subtotal: (data[FirebaseFieldNames.subtotal] ?? 0.0).toDouble(),
      taxRate: (data[FirebaseFieldNames.taxRate] ?? 0.0).toDouble(),
      taxAmount: (data[FirebaseFieldNames.taxAmount] ?? 0.0).toDouble(),
      totalAmount: (data[FirebaseFieldNames.totalAmount] ?? 0.0).toDouble(),
      pdfUrl: data[FirebaseFieldNames.pdfUrl],
      createdAt: getTimestamp(FirebaseFieldNames.createdAt).toDate(),
    );
  }

  /// CopyWith method for easy updates
  InvoiceModel copyWith({
    String? invoiceId,
    String? appointmentId,
    String? status,
    DateTime? issuedAt,
    DateTime? dueAt,
    List<InvoiceItemModel>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? totalAmount,
    String? pdfUrl,
    DateTime? createdAt,
  }) {
    return InvoiceModel(
      invoiceId: invoiceId ?? this.invoiceId,
      appointmentId: appointmentId ?? this.appointmentId,
      status: status ?? this.status,
      issuedAt: issuedAt ?? this.issuedAt,
      dueAt: dueAt ?? this.dueAt,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}