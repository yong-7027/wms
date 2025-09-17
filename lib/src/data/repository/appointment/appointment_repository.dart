import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/constants/firebase_collection_names.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class AppointmentRepository extends GetxController {
  static AppointmentRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// 更新车辆服务状态（支付完成后）
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    try {
      await _db
          .collection(FirebaseCollectionNames.appointments)
          .doc(appointmentId)
          .update({
        'status': status,
        'paidAt': FieldValue.serverTimestamp(),
      });

      print('Car service status updated: $appointmentId -> $status');
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