import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../payment/views/invoice_detail_screen.dart';

class FCMService {
  // 确保全局只有一个 FCMService 实例，避免多次初始化
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FlutterLocalNotificationsPlugin _localNotifications;

  static const String _lastUserIdKey = '';

  // 初始化 FCM
  Future<void> initialize() async {
    try {
      // 初始化本地通知
      await _initializeLocalNotifications();

      // 请求通知权限
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        announcement: false,
      );

      // 获取并保存 FCM token
      await _getAndSaveFCMToken();

      // 设置消息处理回调
      _setupMessageHandlers();

      // 监听登录/登出状态
      _setupAuthStateListener();

      print('FCM initialized successfully');
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  // 初始化本地通知
  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    // 指定应用启动图标作为通知图标
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // 配置 iOS 本地通知权限
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      // 当用户点击通知时:
      // 1. 检查通知中附带的 payload（字符串数据）
      // 2. 调用 _parsePayloadString() 解析成 Map，方便后续使用（如跳转到特定页面）
      // 3. 把解析后的数据传递给 _handleNotificationClick()，例如导航到详情页
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        Map<String, dynamic>? payloadMap;
        if (response.payload != null) {
          try {
            // 尝试解析 JSON 字符串
            payloadMap = _parsePayloadString(response.payload!);
          } catch (e) {
            print('Failed to parse notification payload: $e');
          }
        }
        _handleNotificationClick(payloadMap);
      },
    );
  }

  // 解析 payload 字符串为 Map
  Map<String, dynamic>? _parsePayloadString(String payload) {
    try {
      // 如果 payload 是 JSON 字符串，使用 json.decode
      if (payload.startsWith('{') && payload.endsWith('}')) {
        // 如果是 JSON 对象
        return _parseJsonPayload(payload);
      } else {
        // 如果是查询字符串格式
        // key=value&key2=value2 格式
        return _parseQueryStringPayload(payload);
      }
    } catch (e) {
      print('Error parsing payload: $e');
      return null;
    }
  }

  // 解析 JSON 格式的 payload
  Map<String, dynamic> _parseJsonPayload(String payload) {
    return json.decode(payload) as Map<String, dynamic>;
  }

  // 解析查询字符串格式的 payload
  Map<String, dynamic> _parseQueryStringPayload(String payload) {
    final Map<String, dynamic> result = {};
    final pairs = payload.split('&');

    for (final pair in pairs) {
      final keyValue = pair.split('=');
      if (keyValue.length == 2) {
        result[keyValue[0]] = Uri.decodeComponent(keyValue[1]);
      }
    }

    return result;
  }

  // 获取并保存 FCM token
  Future<void> _getAndSaveFCMToken() async {
    try {
      String? token = await _messaging.getToken();

      if (token != null) {
        await _saveTokenToFirestore(token);
        print('FCM Token: $token');
      }

      // 监听 token 刷新
      _messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(newToken);
        print('FCM Token refreshed: $newToken');
      });
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  // 保存 token 到 Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      String? userId = await _getCurrentUserId();

      if (userId != null) {
        await _firestore.collection('users').doc(userId).set({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('FCM token saved successfully for user $userId');
      }
    } catch (e) {
      print('Error saving FCM token to Firestore: $e');
    }
  }

  // 获取当前用户ID
  String? _getCurrentUserId() {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      print('Error getting current user ID from FirebaseAuth: $e');
      return null;
    }
  }

  // 设置消息处理回调
  void _setupMessageHandlers() {
    // 处理前台消息
    // 当 App 正在前台运行，并收到一条 FCM 消息
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // 在前台时，Firebase 不会自动显示系统推送通知，所以需要手动调用
      print('Received foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 处理后台消息点击
    // App 在后台运行或最小化
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background message: ${message.notification?.title}');
      _handleNotificationClick(message.data);
    });

    // 处理终止状态消息点击
    // App 完全关闭（未在后台）
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state: ${message.notification?.title}');
        _handleNotificationClick(message.data);
      }
    });
  }

  void _setupAuthStateListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // 用户登录，重新获取并保存 token
        print('User logged in, refreshing FCM token');
        await _saveUserId(user.uid);
        _getAndSaveFCMToken();
      } else {
        // 用户登出
        print('User logged out');
        _clearTokensOnLogout();
      }
    });
  }

  // 保存用户ID到本地存储
  Future<void> _saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUserIdKey, userId);
      print('User ID saved to local storage: $userId');
    } catch (e) {
      print('Error saving user ID: $e');
    }
  }

  // 从本地存储获取最后一次已知的用户ID
  Future<String?> _getLastKnownUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastUserIdKey);
    } catch (e) {
      print('Error getting last user ID: $e');
      return null;
    }
  }

  // 清理本地存储的用户ID
  Future<void> _clearSavedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastUserIdKey);
      print('User ID cleared from local storage');
    } catch (e) {
      print('Error clearing user ID: $e');
    }
  }

  // 登出时清理token
  Future<void> _clearTokensOnLogout() async {
    try {
      final lastKnownUserId = await _getLastKnownUserId();

      if (lastKnownUserId != null) {
        // 清理 Firestore 中的 token
        await _firestore.collection('users').doc(lastKnownUserId).update({
          'fcmTokens': FieldValue.delete(),
          'lastLogout': FieldValue.serverTimestamp(),
        });
        print('FCM tokens cleared for user $lastKnownUserId on logout');

        // 清理本地存储的用户ID
        await _clearSavedUserId();
      } else {
        print('No known user ID to clear tokens');
      }
    } catch (e) {
      print('Error clearing tokens on logout: $e');
    }
  }

  // 显示本地通知
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'payment_reminders', // channelId - 必须与 Cloud Function 中的一致
      'Payment Reminders',
      channelDescription: 'Notifications for payment reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      // sound: RawResourceAndroidNotificationSound('notification'),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.notification?.title,
      message.notification?.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  // 处理通知点击
  void _handleNotificationClick(Map<String, dynamic>? data) {
    if (data != null) {
      final type = data['type'];
      final invoiceId = data['invoiceId'];

      print('Notification clicked - Type: $type, Invoice ID: $invoiceId');

      // 根据通知类型导航到相应页面
      if (type == 'payment_reminder' && invoiceId != null) {
        Get.to(() => InvoiceDetailScreen(invoiceId: invoiceId));
      }
    }
  }

  // 获取当前 FCM token（可用于调试）
  Future<String?> getCurrentToken() async {
    return await _messaging.getToken();
  }

  // 清除所有注册的 tokens（用户登出时调用）
  Future<void> clearTokens() async {
    try {
      String? userId = await _getCurrentUserId();
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.delete(),
        });
        print('FCM tokens cleared for user $userId');
      }
    } catch (e) {
      print('Error clearing FCM tokens: $e');
    }
  }
}