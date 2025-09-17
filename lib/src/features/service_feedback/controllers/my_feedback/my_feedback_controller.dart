import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/service_feedback_model.dart';
import '../../models/service_model.dart';

class MyServiceFeedbackController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // Reactive variables
  final RxBool isLoadingToFeedback = false.obs;
  final RxBool isLoadingMyFeedback = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ServiceModel> toFeedbackServices = <ServiceModel>[].obs;
  final RxList<ServiceFeedbackModel> myFeedbackServices = <ServiceFeedbackModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    loadInitialData();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void loadInitialData() {
    loadToFeedbackServices();
    loadMyFeedbackServices();
  }

  Future<void> loadToFeedbackServices() async {
    try {
      isLoadingToFeedback.value = true;
      hasError.value = false;

      // Simulate API call delay
      await Future.delayed(Duration(milliseconds: 800));

      // Mock data - services without feedback
      final mockServices = [
        ServiceModel(
          id: '1',
          serviceType: 'Engine Service',
          carName: 'Toyota',
          carModel: 'Camry',
          carPlateNo: 'ABC 1234',
          serviceDesc: 'Complete engine service including oil change, filter replacement, and general inspection',
          serviceDate: DateTime.now().subtract(Duration(days: 8)),
          completedDate: DateTime.now().subtract(Duration(days: 2)),
          totalCost: 280.50,
          hasFeedback: false,
          status: ServiceStatus.completed,
        ),
        ServiceModel(
          id: '2',
          serviceType: 'Brake Repair',
          carName: 'Honda',
          carModel: 'Civic',
          carPlateNo: 'XYZ 5678',
          serviceDesc: 'Front brake pad replacement and brake fluid change',
          serviceDate: DateTime.now().subtract(Duration(days: 6)),
          completedDate: DateTime.now().subtract(Duration(days: 1)),
          totalCost: 450.00,
          hasFeedback: false,
          status: ServiceStatus.cancelled,
        ),
        ServiceModel(
          id: '3',
          serviceType: 'Battery Replacement',
          carName: 'Proton',
          carModel: 'Saga',
          carPlateNo: 'DEF 9012',
          serviceDesc: 'Car battery replacement with 2-year warranty',
          serviceDate: DateTime.now().subtract(Duration(days: 10)),
          completedDate: DateTime.now().subtract(Duration(days: 8)), // Expired
          totalCost: 180.00,
          hasFeedback: false,
          status: ServiceStatus.pending,
        ),
      ];

      toFeedbackServices.value = mockServices;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load services. Please try again.';
    } finally {
      isLoadingToFeedback.value = false;
    }
  }

  Future<void> loadMyFeedbackServices() async {
    try {
      isLoadingMyFeedback.value = true;

      // Simulate API call delay
      await Future.delayed(Duration(milliseconds: 600));

      // Mock data - services with feedback
      final mockFeedbacks = [
        ServiceFeedbackModel(
          id: 'fb1',
          appointmentId: '1',
          serviceRating: 5,
          repairEfficiencyRating: 4,
          transparencyRating: 5,
          overallExperienceRating: 4,
          comment: 'Excellent service! The AC is working perfectly now. Staff was very professional and explained everything clearly.',
          staffReply: 'Thank you for your wonderful feedback! We\'re delighted that you\'re satisfied with our AC service. We look forward to serving you again.',
          createdAt: DateTime.now().subtract(Duration(days: 10)),
          userId: 'user1',
          mediaPaths: [],
          likes: [],
        ),
        ServiceFeedbackModel(
          id: 'fb2',
          appointmentId: '2',
          serviceRating: 4,
          repairEfficiencyRating: 3,
          transparencyRating: 4,
          overallExperienceRating: 4,
          comment: 'Good service overall. The tires are great quality, but the waiting time was a bit long.',
          staffReply: '',
          createdAt: DateTime.now().subtract(Duration(days: 20)),
          userId: 'user2',
          mediaPaths: [],
          likes: [],
        ),
        ServiceFeedbackModel(
          id: 'fb3',
          appointmentId: '3',
          serviceRating: 5,
          repairEfficiencyRating: 5,
          transparencyRating: 4,
          overallExperienceRating: 5,
          comment: 'Outstanding work! My car feels like new again. Highly recommend this service center.',
          staffReply: 'We truly appreciate your kind words! Your satisfaction is our top priority. Thank you for choosing our service center.',
          userId: 'user3',
          mediaPaths: [],
          likes: [],
          createdAt: DateTime.now().subtract(Duration(days: 25)),
        ),
      ];

      myFeedbackServices.value = mockFeedbacks;
    } catch (e) {
      // Handle error if needed
    } finally {
      isLoadingMyFeedback.value = false;
    }
  }

  Future<void> refreshCurrentTab() async {
    if (tabController.index == 0) {
      await loadToFeedbackServices();
    } else {
      await loadMyFeedbackServices();
    }
  }

  String formatRemainingTime(Duration duration) {
    if (duration.inSeconds <= 0) return 'Expired';

    if (duration.inDays > 0) {
      return '${duration.inDays}d left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h left';
    } else {
      return '${duration.inMinutes}m left';
    }
  }

  bool canServiceBeReviewed(ServiceModel service) {
    return service.canRate;
  }

  void navigateToServiceDetails(ServiceModel service) {
    // Navigate to service details page
    print('Navigate to service details: ${service.id}');
  }

  void navigateToMakeFeedback(ServiceModel service) {
    // Navigate to make feedback page
    print('Navigate to make feedback: ${service.id}');
    // Get.to(() => MakeFeedbackPage(service: service));
  }
}