import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../features/payment/models/invoice_model.dart';
import '../../../utils/constants/firebase_field_names.dart';
import '../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class InvoiceRepository extends GetxController {
  static InvoiceRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get invoice by ID
  Future<InvoiceModel?> getInvoiceById(String invoiceId) async {
    try {
      final doc = await _db
          .collection('invoices')
          .doc(invoiceId)
          .get();

      if (doc.exists) {
        return InvoiceModel.fromSnapshot(doc);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on TPlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  /// Load invoices for specific appointment
  Future<List<InvoiceModel>> getInvoicesByAppointmentId(String appointmentId) async {
    try {
      final querySnapshot = await _db
          .collection('invoices')
          .where(FirebaseFieldNames.appointmentId, isEqualTo: appointmentId)
          .orderBy(FirebaseFieldNames.createdAt, descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InvoiceModel.fromSnapshot(doc))
          .toList();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on TPlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  /// Get invoices for user through appointments
  Future<List<InvoiceModel>> getUserInvoices(String userId) async {
    try {
      // First get user's appointments
      final appointmentsSnapshot = await _db
          .collection('appointments')
          .where(FirebaseFieldNames.userId, isEqualTo: userId)
          .get();

      if (appointmentsSnapshot.docs.isEmpty) {
        return [];
      }

      // Get appointment IDs
      final appointmentIds = appointmentsSnapshot.docs
          .map((doc) => doc.id)
          .toList();

      // Then get invoices for these appointments
      final invoicesSnapshot = await _db
          .collection('invoices')
          .where(FirebaseFieldNames.appointmentId, whereIn: appointmentIds)
          .orderBy(FirebaseFieldNames.createdAt, descending: true)
          .get();

      return invoicesSnapshot.docs
          .map((doc) => InvoiceModel.fromSnapshot(doc))
          .toList();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on TPlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  /// Update invoice status
  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    try {
      await _db
          .collection('invoices')
          .doc(invoiceId)
          .update({
        FirebaseFieldNames.status: status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on TPlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  /// Mark invoice as paid
  Future<void> markInvoiceAsPaid(String invoiceId, {String? pdfUrl}) async {
    try {
      final updateData = {
        FirebaseFieldNames.status: 'paid',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (pdfUrl != null) {
        updateData[FirebaseFieldNames.pdfUrl] = pdfUrl;
      }

      await _db
          .collection('invoices')
          .doc(invoiceId)
          .update(updateData);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on TPlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  /// Create new invoice
  Future<String> createInvoice(InvoiceModel invoice) async {
    try {
      final docRef = await _db
          .collection('invoices')
          .add(invoice.toJson());

      return docRef.id;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on TPlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  /// Update invoice
  Future<void> updateInvoice(String invoiceId, InvoiceModel invoice) async {
    try {
      await _db
          .collection('invoices')
          .doc(invoiceId)
          .update({
        ...invoice.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on TPlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  /// Delete invoice
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _db
          .collection('invoices')
          .doc(invoiceId)
          .delete();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on TPlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  /// Check if invoice exists
  Future<bool> invoiceExists(String invoiceId) async {
    try {
      final doc = await _db
          .collection('invoices')
          .doc(invoiceId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get overdue invoices count for user
  Future<int> getOverdueInvoicesCount(String userId) async {
    try {
      // First get user's appointments
      final appointmentsSnapshot = await _db
          .collection('appointments')
          .where(FirebaseFieldNames.userId, isEqualTo: userId)
          .get();

      if (appointmentsSnapshot.docs.isEmpty) {
        return 0;
      }

      final appointmentIds = appointmentsSnapshot.docs
          .map((doc) => doc.id)
          .toList();

      // Then get overdue invoices for these appointments
      final querySnapshot = await _db
          .collection('invoices')
          .where(FirebaseFieldNames.appointmentId, whereIn: appointmentIds)
          .where(FirebaseFieldNames.status, isEqualTo: 'overdue')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting overdue invoices count: $e');
      return 0;
    }
  }

  /// Get unpaid invoices total for user
  Future<double> getUnpaidInvoicesTotal(String userId) async {
    try {
      // First get user's appointments
      final appointmentsSnapshot = await _db
          .collection('appointments')
          .where(FirebaseFieldNames.userId, isEqualTo: userId)
          .get();

      if (appointmentsSnapshot.docs.isEmpty) {
        return 0.0;
      }

      final appointmentIds = appointmentsSnapshot.docs
          .map((doc) => doc.id)
          .toList();

      // Then get unpaid invoices for these appointments
      final querySnapshot = await _db
          .collection('invoices')
          .where(FirebaseFieldNames.appointmentId, whereIn: appointmentIds)
          .where(FirebaseFieldNames.status, whereIn: ['unpaid', 'overdue'])
          .get();

      double total = 0.0;
      for (final doc in querySnapshot.docs) {
        final invoice = InvoiceModel.fromSnapshot(doc);
        total += invoice.totalAmount;
      }

      return total;
    } catch (e) {
      print('Error getting unpaid invoices total: $e');
      return 0.0;
    }
  }

  /// Get invoices with refund processing status
  Future<List<InvoiceModel>> getRefundProcessingInvoices(String userId) async {
    try {
      // First get user's appointments
      final appointmentsSnapshot = await _db
          .collection('appointments')
          .where(FirebaseFieldNames.userId, isEqualTo: userId)
          .get();

      if (appointmentsSnapshot.docs.isEmpty) {
        return [];
      }

      final appointmentIds = appointmentsSnapshot.docs
          .map((doc) => doc.id)
          .toList();

      // Then get refund processing invoices
      final querySnapshot = await _db
          .collection('invoices')
          .where(FirebaseFieldNames.appointmentId, whereIn: appointmentIds)
          .where(FirebaseFieldNames.status, isEqualTo: 'refund_processing')
          .orderBy(FirebaseFieldNames.createdAt, descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InvoiceModel.fromSnapshot(doc))
          .toList();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on TPlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  /// Get invoices by status
  Future<List<InvoiceModel>> getInvoicesByStatus(String userId, String status) async {
    try {
      // First get user's appointments
      final appointmentsSnapshot = await _db
          .collection('appointments')
          .where(FirebaseFieldNames.userId, isEqualTo: userId)
          .get();

      if (appointmentsSnapshot.docs.isEmpty) {
        return [];
      }

      final appointmentIds = appointmentsSnapshot.docs
          .map((doc) => doc.id)
          .toList();

      // Then get invoices with specified status
      final querySnapshot = await _db
          .collection('invoices')
          .where(FirebaseFieldNames.appointmentId, whereIn: appointmentIds)
          .where(FirebaseFieldNames.status, isEqualTo: status)
          .orderBy(FirebaseFieldNames.createdAt, descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InvoiceModel.fromSnapshot(doc))
          .toList();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on TPlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  /// Mark invoice as refund completed
  Future<void> markInvoiceRefundCompleted(String invoiceId, {String? refundTransactionId}) async {
    try {
      final updateData = {
        FirebaseFieldNames.status: 'refund_completed',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (refundTransactionId != null) {
        updateData['refundTransactionId'] = refundTransactionId;
      }

      await _db
          .collection('invoices')
          .doc(invoiceId)
          .update(updateData);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on TPlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }
}