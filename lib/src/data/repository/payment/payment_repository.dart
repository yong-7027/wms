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
  Future<PaymentTransactionModel?> fetchPaymentByIntent(String transactionId) async {
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

  /// 获取用户的所有支付记录
  Future<List<PaymentTransactionModel>> fetchUserPayments() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _db
          .collection(FirebaseCollectionNames.payments)
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

  /// 获取特定发票的所有支付记录
  Future<List<PaymentTransactionModel>> fetchInvoicePayments(String invoiceId) async {
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
}