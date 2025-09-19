import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/fcm_service.dart';

class TestNotificationPage extends StatelessWidget {
  const TestNotificationPage({super.key});

  // 获取云函数的URL
  String _getFunctionUrl(String endpoint) {
    return 'https://api-lk2drcb6aa-uc.a.run.app/$endpoint';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测试通知功能'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 添加URL显示用于调试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('API 端点:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('testNotification: ${_getFunctionUrl('testNotification')}'),
                    Text('sendPaymentReminder: ${_getFunctionUrl('sendPaymentReminder')}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _testSendPaymentReminder(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('测试发送支付提醒', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _testNotification(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('测试通知功能', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _checkBackendHealth(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('检查后端健康状态', style: TextStyle(fontSize: 16)),
            ),
            FloatingActionButton(
              onPressed: () async {
                String? token = await FirebaseMessaging.instance.getToken();
                print('FCM Token: $token');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Token: $token')),
                );
              },
              child: Icon(Icons.notifications),
            )
            // ElevatedButton(
            //   onPressed: () => _showFCMToken(context),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.purple,
            //     padding: const EdgeInsets.symmetric(vertical: 16),
            //   ),
            //   child: const Text('显示FCM Token', style: TextStyle(fontSize: 16)),
            // ),
            // ElevatedButton(
            //   onPressed: () => FCMService().simulatePaymentReminder(),
            //   child: const Text('模拟支付提醒'),
            // ),
            // ElevatedButton(
            //   onPressed: () => FCMService().simulateTestNotification(),
            //   child: const Text('模拟测试通知'),
            // ),
            // ElevatedButton(
            //   onPressed: () => _showTestHistory(context),
            //   child: const Text('显示测试历史'),
            // ),
          ],
        ),
      ),
    );
  }

  // 检查后端健康状态
  Future<void> _checkBackendHealth(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('https://api-lk2drcb6aa-uc.a.run.app/'),
      );

      _showSnackBar(context, '后端状态: ${response.statusCode}');
      print('后端响应: ${response.body}');
    } catch (e) {
      _showSnackBar(context, '❌ 后端连接错误: $e');
      print('连接错误: $e');
    }
  }

  // 显示SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 测试发送支付提醒
  Future<void> _testSendPaymentReminder(BuildContext context) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        _showSnackBar(context, '请先登录');
        return;
      }

      final url = _getFunctionUrl('sendPaymentReminder');
      print('请求URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'invoiceId': 'mqNUHuRdE3aCjKZYOouf',
          'amount': 99.99,
          'dueDate': '2024-12-31',
        }),
      );

      print('响应状态码: ${response.statusCode}');
      print('响应体: ${response.body}');

      if (response.statusCode == 200) {
        _showSnackBar(context, '✅ 通知发送成功');
      } else {
        _showSnackBar(context, '❌ 通知发送失败: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar(context, '❌ 请求错误: $e');
      print('错误详情: $e');
    }
  }

  // 测试通知功能
  Future<void> _testNotification(BuildContext context) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        _showSnackBar(context, '请先登录');
        return;
      }

      final url = _getFunctionUrl('testNotification');
      print('请求URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
        }),
      );

      print('响应状态码: ${response.statusCode}');
      print('响应体: ${response.body}');

      if (response.statusCode == 200) {
        _showSnackBar(context, '✅ 测试通知发送成功');
      } else {
        _showSnackBar(context, '❌ 测试失败: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar(context, '❌ 测试错误: $e');
      print('错误详情: $e');
    }
  }

  // Future<void> _showFCMToken(BuildContext context) async {
  //   try {
  //     final fcmService = FCMService();
  //     final token = fcmService.fcmToken;
  //
  //     if (token != null) {
  //       await showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text('FCM Token'),
  //           content: SelectableText(token),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Clipboard.setData(ClipboardData(text: token));
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(content: Text('已复制到剪贴板')),
  //                 );
  //                 Navigator.pop(context);
  //               },
  //               child: const Text('复制'),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('关闭'),
  //             ),
  //           ],
  //         ),
  //       );
  //     } else {
  //       _showSnackBar(context, 'FCM Token 未获取到，请检查初始化');
  //     }
  //   } catch (e) {
  //     _showSnackBar(context, '获取FCM Token错误: $e');
  //   }
  // }

  // void _showTestHistory(BuildContext context) {
  //   final history = FCMService().getTestNotifications();
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('测试通知历史'),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: history.length,
  //           itemBuilder: (context, index) {
  //             final item = history[index];
  //             return ListTile(
  //               title: Text(item['title'] ?? '无标题'),
  //               subtitle: Text(item['body'] ?? '无内容'),
  //               trailing: Text(item['type'] ?? '未知'),
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }
}