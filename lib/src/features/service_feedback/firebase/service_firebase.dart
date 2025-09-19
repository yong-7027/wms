import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_model.dart';

// 获取当前用户的ID (您需要根据您的认证系统实现这个)
String getCurrentUserId() {
  // 例如: return FirebaseAuth.instance.currentUser?.uid ?? '';
  return '3ohlF9J881SuN5qzzL43L8JQ9ex1'; // 替换为实际的用户ID获取逻辑
}

Future<List<ServiceModel>> getCompletedServicesWithoutFeedback() async {
  try {
    final String userId = getCurrentUserId();

    // 执行查询
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('carServices')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'paid')
        .where('hasFeedback', isEqualTo: false)
        .get();

    // 使用 fromDocumentSnapshot 方法转换结果
    final List<ServiceModel> services = querySnapshot.docs.map((doc) {
      return ServiceModel.fromDocumentSnapshot(doc); // 直接使用文档快照
    }).toList();

    return services;
  } catch (e) {
    print('Error fetching services: $e');
    return [];
  }
}

// 辅助函数：处理 Firestore 特定的数据类型（如 Timestamp）
Map<String, dynamic> _processFirestoreData(Map<String, dynamic> data) {
  final processedData = Map<String, dynamic>.from(data);

  // 检查并转换 Timestamp 到 DateTime
  if (data['serviceDate'] is Timestamp) {
    processedData['serviceDate'] = (data['serviceDate'] as Timestamp).toDate().toIso8601String();
  }

  if (data['completedDate'] is Timestamp) {
    processedData['completedDate'] = (data['completedDate'] as Timestamp).toDate().toIso8601String();
  }

  return processedData;
}