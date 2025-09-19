import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/appointment/models/appointment_model.dart';
import '../../../features/appointment/models/service_type_model.dart';
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

  Future getAppointmentById(String appointmentId) async {}

  /// 获取用户的预约（带过滤条件）
  Future<List<AppointmentModel>> getAppointmentByUserId(String userId) async {
    try {
      final query = _db
          .collection(FirebaseCollectionNames.appointments);
          // .where('userId', isEqualTo: userId)
          // .orderBy('scheduledAt', descending: true);

      final querySnapshot = await query.get();
      print('📥 Firestore returned ${querySnapshot.docs.length} appointment(s)');

      final appointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromSnapshot(doc))
          .toList();

      return appointments;
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

  /// 实时监听用户的预约变化
  Stream<List<AppointmentModel>> streamAppointmentsByUserId(String userId) {
    try {
      final query = _db
          .collection(FirebaseCollectionNames.appointments)
          .where('userId', isEqualTo: userId);

      return query.snapshots().map((querySnapshot) {
        final appointments = querySnapshot.docs.map((doc) {
          final appointment = AppointmentModel.fromSnapshot(doc);
          return appointment;
        }).toList();

        print('🎯 Total mapped appointments: ${appointments.length}');
        return appointments;
      });
    } catch (e) {
      print('❌ Error in streamAppointmentsByUserId: $e');
      throw TTexts.commonErrorMessage;
    }
  }

  /// 获取服务类型名称
  Future<List<String>> _getServiceTypeNames(List<String> serviceTypeIds) async {
    if (serviceTypeIds.isEmpty) return [];

    try {
      final List<String> serviceNames = [];

      // 批量获取服务类型信息
      for (final serviceId in serviceTypeIds) {
        final serviceDoc = await _db
            .collection(FirebaseCollectionNames.serviceTypes) // 假设集合名为 serviceTypes
            .doc(serviceId)
            .get();

        if (serviceDoc.exists) {
          final serviceType = ServiceTypeModel.fromSnapshot(serviceDoc);
          serviceNames.add(serviceType.serviceName);
        }
      }

      return serviceNames;
    } catch (e) {
      print('Error getting service type names: $e');
      return serviceTypeIds; // 如果获取失败，返回ID作为备用
    }
  }

}
