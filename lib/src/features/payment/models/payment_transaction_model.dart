import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/firebase_field_names.dart';

class PaymentTransactionModel {
  final String transactionId;
  final String type; // 'payment', 'refund'
  final String? originalPaymentId; // 仅退款时使用，指向原支付ID
  final String invoiceId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final DateTime transactionDateTime;
  final String status;  // 'succeeded', 'pending', 'failed', 'refunded'
  final String? refundReason; // 退款原因
  final List<String>? refundMedias; // 退款相关媒体文件URL
  final String? refundStatus; // 'approved', 'rejected', 'processing'
  final DateTime? updatedAt; // 最后更新时间

  PaymentTransactionModel({
    required this.transactionId,
    this.type = 'payment',
    this.originalPaymentId,
    required this.invoiceId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.transactionDateTime,
    required this.status,
    this.refundReason,
    this.refundMedias,
    this.refundStatus,
    this.updatedAt,
  });

  /// Empty
  static PaymentTransactionModel empty() {
    return PaymentTransactionModel(
      transactionId: '',
      type: 'payment',
      invoiceId: '',
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
      'type': type,
      if (originalPaymentId != null) 'originalPaymentId': originalPaymentId,
      FirebaseFieldNames.invoiceId: invoiceId,
      FirebaseFieldNames.amount: amount,
      FirebaseFieldNames.currency: currency,
      FirebaseFieldNames.paymentMethod: paymentMethod,
      FirebaseFieldNames.transactionDateTime:
      Timestamp.fromDate(transactionDateTime),
      FirebaseFieldNames.status: status,
      if (refundReason != null) 'refundReason': refundReason,
      if (refundMedias != null) 'refundMedias': refundMedias,
      if (refundStatus != null) 'refundStatus': refundStatus,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// From Snapshot
  factory PaymentTransactionModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return PaymentTransactionModel.empty();

    return PaymentTransactionModel(
      transactionId: data[FirebaseFieldNames.transactionId] ?? '',
      type: data['type'] ?? 'payment',
      originalPaymentId: data['originalPaymentId'],
      invoiceId: data[FirebaseFieldNames.invoiceId] ?? '',
      amount: (data[FirebaseFieldNames.amount] ?? 0).toDouble(),
      currency: data[FirebaseFieldNames.currency] ?? '',
      paymentMethod: data[FirebaseFieldNames.paymentMethod] ?? '',
      transactionDateTime:
      (data[FirebaseFieldNames.transactionDateTime] as Timestamp).toDate(),
      status: data[FirebaseFieldNames.status] ?? '',
      refundReason: data['refundReason'],
      refundMedias: data['refundMedias'] != null
          ? List<String>.from(data['refundMedias'])
          : null,
      refundStatus: data['refundStatus'],
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// 复制方法，用于更新部分字段
  PaymentTransactionModel copyWith({
    String? transactionId,
    String? type,
    String? originalPaymentId,
    String? invoiceId,
    double? amount,
    String? currency,
    String? paymentMethod,
    DateTime? transactionDateTime,
    String? status,
    String? refundReason,
    List<String>? refundMedias,
    String? refundStatus,
    DateTime? updatedAt,
  }) {
    return PaymentTransactionModel(
      transactionId: transactionId ?? this.transactionId,
      type: type ?? this.type,
      originalPaymentId: originalPaymentId ?? this.originalPaymentId,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionDateTime: transactionDateTime ?? this.transactionDateTime,
      status: status ?? this.status,
      refundReason: refundReason ?? this.refundReason,
      refundMedias: refundMedias ?? this.refundMedias,
      refundStatus: refundStatus ?? this.refundStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 判断是否为支付记录
  bool get isPayment => type == 'payment';

  /// 判断是否为退款记录
  bool get isRefund => type == 'refund';

  /// 获取实际金额（退款为负数）
  double get effectiveAmount => isRefund ? -amount.abs() : amount;

  /// 获取显示的金额（绝对值）
  double get displayAmount => amount.abs();

  // 退款状态相关方法
  List<Color> get refundStatusGradient {
    switch ((refundStatus ?? 'processing').toLowerCase()) {
      case 'approved':
        return [TColors.refundApproved.withOpacity(0.8), TColors.refundApproved];
      case 'rejected':
        return [TColors.refundRejected.withOpacity(0.8), TColors.refundRejected];
      case 'processing':
        return [TColors.refundProcessing.withOpacity(0.8), TColors.refundProcessing];
      case 'cancelled':
        return [TColors.refundCancelled.withOpacity(0.8), TColors.refundCancelled];
      default:
        return [TColors.grey.withOpacity(0.8), TColors.grey];
    }
  }

  Color get refundStatusColor {
    switch ((refundStatus ?? 'processing').toLowerCase()) {
      case 'approved':
        return TColors.refundApproved;
      case 'rejected':
        return TColors.refundRejected;
      case 'processing':
        return TColors.refundProcessing;
      case 'cancelled':
        return TColors.refundCancelled;
      default:
        return TColors.grey;
    }
  }

  IconData get refundStatusIcon {
    switch ((refundStatus ?? 'processing').toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'processing':
        return Icons.pending;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  String get refundStatusText {
    switch ((refundStatus ?? 'processing').toLowerCase()) {
      case 'approved':
        return 'Approved - Refund Completed';
      case 'rejected':
        return 'Rejected';
      case 'processing':
        return 'Under Review';
      case 'cancelled':
        return 'Cancelled by Customer';
      default:
        return refundStatus ?? 'processing';
    }
  }

  String get statusTitle {
    switch ((refundStatus ?? 'processing').toLowerCase()) {
      case 'approved':
        return 'Refund Approved';
      case 'rejected':
        return 'Refund Rejected';
      case 'processing':
        return 'Under Review';
      case 'cancelled':
        return 'Request Cancelled';
      default:
        return 'Refund Status';
    }
  }

  String get statusDescription {
    switch ((refundStatus ?? 'processing').toLowerCase()) {
      case 'approved':
        return 'Your refund has been approved and processed. The amount should appear in your original payment method within 3-5 business days.';
      case 'rejected':
        return 'Your refund request has been rejected. If you believe this was a mistake, please contact our support team.';
      case 'processing':
        return 'We\'re currently reviewing your refund request. This process typically takes 3-5 business days.';
      case 'cancelled':
        return 'This refund request was cancelled. You can submit a new request if needed.';
      default:
        return 'Refund status information is not available.';
    }
  }

  // 支付方法图标
  IconData get paymentMethodIcon {
    switch (paymentMethod.toLowerCase()) {
      case 'stripe':
        return Iconsax.card_bold;
      case 'paypal':
        return Iconsax.wallet_2_bold;
      case 'apple pay':
        return Icons.phone_iphone;
      case 'google pay':
        return Icons.android;
      case 'bank transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  @override
  String toString() {
    return 'PaymentTransactionModel(transactionId: $transactionId, type: $type, amount: $amount, status: $status, refundStatus: $refundStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentTransactionModel &&
        other.transactionId == transactionId &&
        other.type == type &&
        other.originalPaymentId == originalPaymentId &&
        other.invoiceId == invoiceId &&
        other.amount == amount &&
        other.currency == currency &&
        other.paymentMethod == paymentMethod &&
        other.transactionDateTime == transactionDateTime &&
        other.status == status &&
        other.refundReason == refundReason &&
        listEquals(other.refundMedias, refundMedias) &&
        other.refundStatus == refundStatus &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      transactionId,
      type,
      originalPaymentId,
      invoiceId,
      amount,
      currency,
      paymentMethod,
      transactionDateTime,
      status,
      refundReason,
      refundMedias,
      refundStatus,
      updatedAt,
    );
  }
}