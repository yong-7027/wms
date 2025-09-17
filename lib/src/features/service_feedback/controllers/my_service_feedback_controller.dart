// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import '../models/service_model.dart';
// import '../models/service_feedback_model.dart';
// import '../firebase/firebase_operation.dart';
//
// class MyServiceFeedbackController extends GetxController with GetSingleTickerProviderStateMixin {
//   // Tab controller for switching between tabs
//   late TabController tabController;
//
//   // Current active tab index
//   final RxInt currentTabIndex = 0.obs;
//
//   // Services data
//   final RxList<ServiceModel> toFeedbackServices = <ServiceModel>[].obs;
//   final RxList<ServiceFeedbackModel> myFeedbacks = <ServiceFeedbackModel>[].obs;
//
//   // Loading states
//   final RxBool isLoadingToFeedback = false.obs;
//   final RxBool isLoadingMyFeedbacks = false.obs;
//   final RxBool isRefreshing = false.obs;
//
//   // User information
//   final RxString currentUserId = 'user_456'.obs; // This should come from auth service
//
//   // Error handling
//   final RxString errorMessage = ''.obs;
//   final RxBool hasError = false.obs;
//
//   // Firestore services
//   late FeedbackFirestoreService _feedbackService;
//   // Note: You'll need to create ServiceFirestoreService similar to FeedbackFirestoreService
//   // late ServiceFirestoreService _serviceService;
//
//   // Tab labels
//   final List<String> tabLabels = ['To Feedback', 'My Feedback'];
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     // Initialize tab controller
//     tabController = TabController(length: 2, vsync: this);
//
//     // Initialize services
//     _feedbackService = FeedbackFirestoreService();
//     // _serviceService = ServiceFirestoreService();
//
//     // Listen to tab changes
//     tabController.addListener(() {
//       currentTabIndex.value = tabController.index;
//     });
//
//     // Load initial data
//     loadInitialData();
//   }
//
//   @override
//   void onClose() {
//     tabController.dispose();
//     super.onClose();
//   }
//
//   /// Load initial data for both tabs
//   Future<void> loadInitialData() async {
//     await Future.wait([
//       loadToFeedbackServices(),
//       loadMyFeedbacks(),
//     ]);
//   }
//
//   /// Load services that require feedback (completed within 7 days and no feedback)
//   Future<void> loadToFeedbackServices() async {
//     try {
//       isLoadingToFeedback.value = true;
//       hasError.value = false;
//
//       // Mock data - Replace with actual Firestore query
//       // Query should filter services where:
//       // 1. status == ServiceStatus.completed
//       // 2. completedDate is within last 7 days
//       // 3. hasFeedback == false
//       // 4. userId == currentUserId
//
//       await Future.delayed(Duration(milliseconds: 800)); // Simulate network delay
//
//       // Mock services for demonstration
//       final mockServices = _generateMockToFeedbackServices();
//       toFeedbackServices.assignAll(mockServices);
//
//       /*
//       // Actual Firestore implementation would look like:
//       final services = await _serviceService.getUserCompletedServicesWithoutFeedback(
//         currentUserId.value,
//         DateTime.now().subtract(Duration(days: 7)),
//       );
//       toFeedbackServices.assignAll(services);
//       */
//
//     } catch (e) {
//       hasError.value = true;
//       errorMessage.value = 'Failed to load services: $e';
//       print('Error loading to feedback services: $e');
//     } finally {
//       isLoadingToFeedback.value = false;
//     }
//   }
//
//   /// Load user's existing feedback
//   Future<void> loadMyFeedbacks() async {
//     try {
//       isLoadingMyFeedbacks.value = true;
//       hasError.value = false;
//
//       // Mock data - Replace with actual Firestore query
//       await Future.delayed(Duration(milliseconds: 600)); // Simulate network delay
//
//       final mockFeedbacks = _generateMockFeedbacks();
//       myFeedbacks.assignAll(mockFeedbacks);
//
//       /*
//       // Actual Firestore implementation:
//       final feedbacks = await _feedbackService.getUserFeedbacks(currentUserId.value);
//       myFeedbacks.assignAll(feedbacks);
//       */
//
//     } catch (e) {
//       hasError.value = true;
//       errorMessage.value = 'Failed to load feedback: $e';
//       print('Error loading my feedbacks: $e');
//     } finally {
//       isLoadingMyFeedbacks.value = false;
//     }
//   }
//
//   /// Refresh data based on current tab
//   Future<void> refreshCurrentTab() async {
//     isRefreshing.value = true;
//
//     if (currentTabIndex.value == 0) {
//       await loadToFeedbackServices();
//     } else {
//       await loadMyFeedbacks();
//     }
//
//     isRefreshing.value = false;
//   }
//
//   /// Navigate to make feedback screen
//   void navigateToMakeFeedback(ServiceModel service) {
//     Get.toNamed('/make-service-feedback', arguments: {
//       'service': service,
//     });
//   }
//
//   /// Navigate to service details screen
//   void navigateToServiceDetails(ServiceModel service) {
//     Get.toNamed('/service-details', arguments: {
//       'serviceId': service.id,
//     });
//   }
//
//   /// Navigate to feedback details screen
//   void navigateToFeedbackDetails(ServiceFeedbackModel feedback) {
//     Get.toNamed('/feedback-details', arguments: {
//       'feedback': feedback,
//     });
//   }
//
//   /// Switch to specific tab
//   void switchToTab(int index) {
//     if (index >= 0 && index < tabLabels.length) {
//       tabController.animateTo(index);
//     }
//   }
//
//   /// Check if service can still be reviewed (within 7 days)
//   bool canServiceBeReviewed(ServiceModel service) {
//     return service.remainingTimeToRate.inSeconds > 0;
//   }
//
//   /// Check if feedback can still be edited (within 24 hours)
//   bool canFeedbackBeEdited(ServiceFeedbackModel feedback) {
//     return feedback.remainingTimeToEdit.inSeconds > 0;
//   }
//
//   /// Format remaining time for display
//   String formatRemainingTime(Duration duration) {
//     if (duration.inSeconds <= 0) return 'Expired';
//
//     if (duration.inDays > 0) {
//       return '${duration.inDays}d ${duration.inHours % 24}h remaining';
//     } else if (duration.inHours > 0) {
//       return '${duration.inHours}h ${duration.inMinutes % 60}m remaining';
//     } else {
//       return '${duration.inMinutes}m remaining';
//     }
//   }
//
//   /// Get count of services awaiting feedback
//   int get toFeedbackCount => toFeedbackServices.length;
//
//   /// Get count of submitted feedbacks
//   int get myFeedbackCount => myFeedbacks.length;
//
//   /// Generate mock data for to feedback services
//   List<ServiceModel> _generateMockToFeedbackServices() {
//     return [
//       ServiceModel(
//         id: 'service_001',
//         serviceType: 'Oil Change',
//         carName: 'Toyota Camry',
//         carModel: '2019',
//         carPlateNo: 'ABC1234',
//         serviceDesc: 'Full synthetic oil change with filter replacement',
//         serviceDate: DateTime.now().subtract(Duration(days: 2)),
//         completedDate: DateTime.now().subtract(Duration(days: 1)),
//         totalCost: 85.50,
//         status: ServiceStatus.completed,
//         hasFeedback: false,
//       ),
//       ServiceModel(
//         id: 'service_002',
//         serviceType: 'Brake Service',
//         carName: 'Honda Civic',
//         carModel: '2020',
//         carPlateNo: 'XYZ5678',
//         serviceDesc: 'Brake pad replacement and brake fluid flush',
//         serviceDate: DateTime.now().subtract(Duration(days: 5)),
//         completedDate: DateTime.now().subtract(Duration(days: 4)),
//         totalCost: 320.00,
//         status: ServiceStatus.completed,
//         hasFeedback: false,
//       ),
//       ServiceModel(
//         id: 'service_003',
//         serviceType: 'Engine Diagnostics',
//         carName: 'BMW X3',
//         carModel: '2021',
//         carPlateNo: 'BMW9999',
//         serviceDesc: 'Complete engine diagnostic scan and tune-up',
//         serviceDate: DateTime.now().subtract(Duration(days: 6)),
//         completedDate: DateTime.now().subtract(Duration(days: 6)),
//         totalCost: 450.75,
//         status: ServiceStatus.completed,
//         hasFeedback: false,
//       ),
//     ];
//   }
//
//   /// Generate mock data for existing feedbacks
//   List<ServiceFeedbackModel> _generateMockFeedbacks() {
//     return [
//       ServiceFeedbackModel(
//         id: 'feedback_001',
//         serviceId: 'service_100',
//         userId: currentUserId.value,
//         serviceRating: 5,
//         repairEfficiencyRating: 5,
//         transparencyRating: 4,
//         overallExperienceRating: 5,
//         comment: 'Excellent service! Very professional and quick.',
//         mediaPaths: [],
//         likes: [],
//         staffReply: 'Thank you for your feedback!',
//         createdAt: DateTime.now().subtract(Duration(days: 3)),
//         updatedAt: null,
//         status: FeedbackStatus.published,
//         canEdit: false,
//       ),
//       ServiceFeedbackModel(
//         id: 'feedback_002',
//         serviceId: 'service_101',
//         userId: currentUserId.value,
//         serviceRating: 4,
//         repairEfficiencyRating: 3,
//         transparencyRating: 4,
//         overallExperienceRating: 4,
//         comment: 'Good service overall, but took longer than expected.',
//         mediaPaths: [],
//         likes: [],
//         staffReply: '',
//         createdAt: DateTime.now().subtract(Duration(hours: 12)),
//         updatedAt: null,
//         status: FeedbackStatus.submitted,
//         canEdit: true,
//       ),
//       ServiceFeedbackModel(
//         id: 'feedback_003',
//         serviceId: 'service_102',
//         userId: currentUserId.value,
//         serviceRating: 3,
//         repairEfficiencyRating: 3,
//         transparencyRating: 2,
//         overallExperienceRating: 3,
//         comment: 'Average service. Could improve communication about delays.',
//         mediaPaths: [],
//         likes: [],
//         staffReply: '',
//         createdAt: DateTime.now().subtract(Duration(days: 10)),
//         updatedAt: DateTime.now().subtract(Duration(days: 9)),
//         status: FeedbackStatus.published,
//         canEdit: false,
//       ),
//     ];
//   }
// }