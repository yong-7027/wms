import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/payment/models/payment_transaction_model.dart';
import '../../../utils/constants/firebase_collection_names.dart';
import '../../../utils/constants/firebase_field_names.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class PaymentRepository extends GetxController {
  static PaymentRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<PaymentTransactionModel>> fetchUserTransactions() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      // 1. 获取当前用户已完成的appointments
      final appointmentsSnapshot = await _db
          .collection(FirebaseCollectionNames.appointments)
          .where(FirebaseFieldNames.userId, isEqualTo: userId)
          .where('status', isEqualTo: 'completed') // 只获取已完成的预约
          .get();

      if (appointmentsSnapshot.docs.isEmpty) return [];

      // 2. 获取这些appointments的所有已支付invoices
      final appointmentIds = appointmentsSnapshot.docs.map((doc) => doc.id)
          .toList();

      final invoicesSnapshot = await _db
          .collection(FirebaseCollectionNames.invoices)
          .where(FirebaseFieldNames.appointmentId, whereIn: appointmentIds)
          .where('status', isEqualTo: 'paid') // 只获取已支付的发票
          .get();

      if (invoicesSnapshot.docs.isEmpty) return [];

      // 3. 获取这些invoices的所有payments
      final invoiceIds = invoicesSnapshot.docs.map((doc) => doc.id).toList();

      final paymentsSnapshot = await _db
          .collection(FirebaseCollectionNames.payments)
          .where(FirebaseFieldNames.invoiceId, whereIn: invoiceIds)
          .orderBy('createdAt', descending: true)
          .get();

      return paymentsSnapshot.docs
          .map((doc) => PaymentTransactionModel.fromSnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// 创建支付记录（关联到发票）
  Future<String?> makeInvoicePayment({
    required PaymentTransactionModel transaction,
    required String invoiceId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // 使用 transactionId 作为文档ID，避免重复支付
      await _db
          .collection(FirebaseCollectionNames.payments)
          .doc(transaction.transactionId)
          .set({
        ...transaction.toJson(),
        FirebaseFieldNames.userId: user.uid,
        FirebaseFieldNames.invoiceId: invoiceId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return transaction.transactionId;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Create refund request
  Future<String> createRefundRequest(
      PaymentTransactionModel refundTransaction) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create refund document
      final docRef = await _db
          .collection('refunds')
          .add({
        ...refundTransaction.toJson(),
        FirebaseFieldNames.userId: user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Get refund requests for user
  Future<List<PaymentTransactionModel>> getUserRefundRequests() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _db
          .collection('refunds')
          .where(FirebaseFieldNames.userId, isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentTransactionModel.fromSnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Get refund request by ID
  Future<PaymentTransactionModel?> getRefundRequestById(String refundId) async {
    try {
      final doc = await _db
          .collection('refunds')
          .doc(refundId)
          .get();

      if (!doc.exists) return null;
      return PaymentTransactionModel.fromSnapshot(doc);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Update refund status
  Future<void> updateRefundStatus(String refundId, String status) async {
    try {
      await _db
          .collection('refunds')
          .doc(refundId)
          .update({
        'refundStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Cancel refund request (user-initiated)
  Future<void> cancelRefundRequest(String transactionId) async {
    try {
      // Find the refund document by transaction ID
      final snapshot = await _db
          .collection('refunds')
          .where('transactionId', isEqualTo: transactionId)
          .where('refundStatus', isEqualTo: 'processing')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'refundStatus': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Check if payment has active refund request
  Future<bool> hasActiveRefundRequest(String paymentId) async {
    try {
      final snapshot = await _db
          .collection('refunds')
          .where('originalPaymentId', isEqualTo: paymentId)
          .where('refundStatus', isEqualTo: 'processing')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get refunds for specific payment
  Future<List<PaymentTransactionModel>> getRefundsForPayment(String paymentId) async {
    try {
      final snapshot = await _db
          .collection('refunds')
          .where('originalPaymentId', isEqualTo: paymentId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentTransactionModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 验证支付是否存在（防止重复处理）
  Future<bool> paymentExists(String transactionId) async {
    try {
      final doc = await _db
          .collection(FirebaseCollectionNames.payments)
          .doc(transactionId)
          .get();

      return doc.exists;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// 根据交易ID获取支付详情
  Future<PaymentTransactionModel?> fetchPaymentByIntent(
      String transactionId) async {
    try {
      final doc = await _db
          .collection(FirebaseCollectionNames.payments)
          .doc(transactionId)
          .get();

      if (!doc.exists) return null;
      return PaymentTransactionModel.fromSnapshot(doc);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// 获取特定发票的所有支付记录
  Future<List<PaymentTransactionModel>> fetchInvoicePayments(
      String invoiceId) async {
    try {
      final snapshot = await _db
          .collection(FirebaseCollectionNames.payments)
          .where(FirebaseFieldNames.invoiceId, isEqualTo: invoiceId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentTransactionModel.fromSnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// 更新支付状态
  Future<void> updatePaymentStatus(String transactionId, String status) async {
    try {
      await _db
          .collection(FirebaseCollectionNames.payments)
          .doc(transactionId)
          .update({
        FirebaseFieldNames.status: status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Update payment status to refunded when refund is approved
  Future<void> markPaymentAsRefunded(String paymentId) async {
    try {
      await updatePaymentStatus(paymentId, 'refunded');
    } catch (e) {
      throw 'Failed to update payment status: $e';
    }
  }

  /// 获取用户的支付统计信息
  Future<Map<String, dynamic>> getPaymentStats() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      final snapshot = await _db
          .collection(FirebaseCollectionNames.payments)
          .where(FirebaseFieldNames.userId, isEqualTo: userId)
          .get();

      double totalPaid = 0.0;
      int successfulPayments = 0;
      int failedPayments = 0;

      for (final doc in snapshot.docs) {
        final payment = PaymentTransactionModel.fromSnapshot(doc);
        if (payment.status == 'succeeded') {
          totalPaid += payment.amount;
          successfulPayments++;
        } else if (payment.status == 'failed') {
          failedPayments++;
        }
      }

      return {
        'totalPaid': totalPaid,
        'successfulPayments': successfulPayments,
        'failedPayments': failedPayments,
        'totalPayments': snapshot.docs.length,
      };
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// 删除支付记录（管理员功能）
  Future<void> deletePayment(String transactionId) async {
    try {
      await _db
          .collection(FirebaseCollectionNames.payments)
          .doc(transactionId)
          .delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Delete refund request
  Future<void> deleteRefundRequest(String refundId) async {
    try {
      await _db
          .collection('refunds')
          .doc(refundId)
          .delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Check if refund request exists
  Future<bool> refundRequestExists(String refundId) async {
    try {
      final doc = await _db
          .collection('refunds')
          .doc(refundId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}