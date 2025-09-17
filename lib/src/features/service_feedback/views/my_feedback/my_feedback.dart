import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../controllers/my_feedback/my_feedback_controller.dart';
import '../../models/service_feedback_model.dart';
import '../../models/service_model.dart';
import '../make_feedback/make_service_feedback.dart';

// Controller
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
      final List<ServiceModel> mockServices = [
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
          status: ServiceStatus.pending,
        ),
        ServiceModel(
          id: '3',
          serviceType: 'Battery Replacement',
          carName: 'Proton',
          carModel: 'Saga',
          carPlateNo: 'DEF 9012',
          serviceDesc: 'Car battery replacement with 2-year warranty',
          serviceDate: DateTime.now().subtract(Duration(days: 10)),
          completedDate: DateTime.now().subtract(Duration(days: 8)),
          totalCost: 180.00,
          hasFeedback: false,
          status: ServiceStatus.cancelled,
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
          appointmentId: 'service1',
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
          appointmentId: 'service2',
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
          appointmentId: 'service3',
          serviceRating: 5,
          repairEfficiencyRating: 5,
          transparencyRating: 4,
          overallExperienceRating: 5,
          comment: 'Outstanding work! My car feels like new again. Highly recommend this service center.',
          staffReply: 'We truly appreciate your kind words! Your satisfaction is our top priority. Thank you for choosing our service center.',
          createdAt: DateTime.now().subtract(Duration(days: 30)),
          userId: 'user3',
          mediaPaths: [],
          likes: [],
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
    print('Navigate to service details: ${service.id}');
  }

  void navigateToMakeFeedback(ServiceModel service) {
    Get.to(() => MakeServiceFeedbackScreen());
    print('Navigate to make feedback: ${service.id}');
  }
}

// Main Page
class MyServiceFeedbackPage extends StatelessWidget {
  const MyServiceFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyServiceFeedbackController());

    return Scaffold(
      backgroundColor: TColors.primaryBackground,
      appBar: AppBar(
        title: Text(
          'My Feedback',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: TColors.textPrimary,
          ),
        ),
        backgroundColor: TColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: TColors.textPrimary),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            color: TColors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => TabBar(
                controller: controller.tabController,
                labelColor: TColors.primary,
                unselectedLabelColor: TColors.textSecondary,
                indicatorColor: TColors.primary,
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('To Feedback'),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: TColors.warning,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${controller.toFeedbackServices.length}',
                            style: TextStyle(
                              color: TColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('My Feedback'),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: TColors.success,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${controller.myFeedbackServices.length}',
                            style: TextStyle(
                              color: TColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          ToFeedbackTab(),
          MyFeedbackTab(),
        ],
      ),
    );
  }
}

// To Feedback Tab
class ToFeedbackTab extends StatelessWidget {
  const ToFeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyServiceFeedbackController>();

    return RefreshIndicator(
      onRefresh: controller.refreshCurrentTab,
      color: TColors.primary,
      child: Obx(() {
        if (controller.isLoadingToFeedback.value) {
          return _buildLoadingState();
        }

        if (controller.hasError.value) {
          return _buildErrorState(controller);
        }

        if (controller.toFeedbackServices.isEmpty) {
          return _buildEmptyState();
        }

        return _buildServicesList(controller);
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TColors.primary),
          SizedBox(height: 20),
          Text(
            'Loading services...',
            style: TextStyle(
              fontSize: 16,
              color: TColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(MyServiceFeedbackController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColors.lightRed,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: TColors.error,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: TColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: TColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: controller.loadToFeedbackServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: TColors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                size: 48,
                color: TColors.success,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'All Caught Up!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'You have no services awaiting feedback.\nCompleted services will appear here within 7 days.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: TColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(MyServiceFeedbackController controller) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: controller.toFeedbackServices.length,
      separatorBuilder: (context, index) => SizedBox(height: 16),
      itemBuilder: (context, index) {
        final service = controller.toFeedbackServices[index];
        return ToFeedbackServiceCard(service: service);
      },
    );
  }
}

// To Feedback Service Card
class ToFeedbackServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ToFeedbackServiceCard({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyServiceFeedbackController>();
    final remainingTime = service.remainingTimeToRate;
    final canReview = controller.canServiceBeReviewed(service);

    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.navigateToServiceDetails(service),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with service type and remaining time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service.serviceType,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: TColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: canReview ? TColors.lightOrange : TColors.lightRed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.formatRemainingTime(remainingTime),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: canReview ? TColors.orange : TColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Car information
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TColors.lightBlueColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.directions_car,
                          size: 20,
                          color: TColors.primary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${service.carName} ${service.carModel}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: TColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              service.carPlateNo,
                              style: TextStyle(
                                fontSize: 13,
                                color: TColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Service description
                Text(
                  service.serviceDesc,
                  style: TextStyle(
                    fontSize: 15,
                    color: TColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),

                // Service date and cost
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completed On',
                          style: TextStyle(
                            fontSize: 12,
                            color: TColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          service.formattedCompletedDate,
                          style: TextStyle(
                            fontSize: 15,
                            color: TColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: TColors.lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        service.formattedTotalCost,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canReview
                        ? () => controller.navigateToMakeFeedback(service)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canReview ? TColors.primary : TColors.buttonDisabled,
                      foregroundColor: TColors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: canReview ? 2 : 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          canReview ? Icons.rate_review : Icons.schedule,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          canReview ? 'Write Review' : 'Time Expired',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// My Feedback Tab
class MyFeedbackTab extends StatelessWidget {
  const MyFeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyServiceFeedbackController>();

    return RefreshIndicator(
      onRefresh: controller.refreshCurrentTab,
      color: TColors.primary,
      child: Obx(() {
        if (controller.isLoadingMyFeedback.value) {
          return _buildLoadingState();
        }

        if (controller.myFeedbackServices.isEmpty) {
          return _buildEmptyState();
        }

        return _buildFeedbacksList(controller);
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TColors.primary),
          SizedBox(height: 20),
          Text(
            'Loading feedback...',
            style: TextStyle(
              fontSize: 16,
              color: TColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColors.lightBlueColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.feedback_outlined,
                size: 48,
                color: TColors.primary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Feedback Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Your completed feedback will appear here.\nStart by providing feedback for your services.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: TColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbacksList(MyServiceFeedbackController controller) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: controller.myFeedbackServices.length,
      separatorBuilder: (context, index) => SizedBox(height: 16),
      itemBuilder: (context, index) {
        final feedback = controller.myFeedbackServices[index];
        return MyFeedbackCard(feedback: feedback);
      },
    );
  }
}

// My Feedback Card
class MyFeedbackCard extends StatefulWidget {
  final ServiceFeedbackModel feedback;

  const MyFeedbackCard({
    super.key,
    required this.feedback,
  });

  @override
  State<MyFeedbackCard> createState() => _MyFeedbackCardState();
}

class _MyFeedbackCardState extends State<MyFeedbackCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main feedback content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with service info and rating
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'mockServices[0].serviceType',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: TColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Honda Civic',
                            style: TextStyle(
                              fontSize: 14,
                              color: TColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getRatingColor(widget.feedback.averageRating),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 18,
                            color: TColors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            widget.feedback.averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: TColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Rating breakdown
                _buildRatingBreakdown(),
                SizedBox(height: 16),

                // Comment
                if (widget.feedback.comment.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TColors.softGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.format_quote,
                              size: 16,
                              color: TColors.textSecondary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'My Review',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: TColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.feedback.comment,
                          style: TextStyle(
                            fontSize: 15,
                            color: TColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Feedback date and cost
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feedback Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: TColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.feedback.formattedCreatedDate,
                          style: TextStyle(
                            fontSize: 15,
                            color: TColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: TColors.lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'RM 650.00',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TColors.success,
                        ),
                      ),
                    ),
                  ],
                ),

                // Staff reply section
                if (widget.feedback.hasStaffReply) ...[
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TColors.lightBlueColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: TColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.support_agent,
                                  size: 16,
                                  color: TColors.primary,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Staff Reply',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: TColors.primary,
                                  ),
                                ),
                              ),
                              Icon(
                                _isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: TColors.primary,
                                size: 24,
                              ),
                            ],
                          ),
                          if (_isExpanded) ...[
                            SizedBox(height: 12),
                            Text(
                              widget.feedback.staffReply,
                              style: TextStyle(
                                fontSize: 14,
                                color: TColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown() {
    final ratings = {
      'Service': widget.feedback.serviceRating,
      'Efficiency': widget.feedback.repairEfficiencyRating,
      'Transparency': widget.feedback.transparencyRating,
      'Experience': widget.feedback.overallExperienceRating,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating Breakdown',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TColors.textSecondary,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: ratings.entries.map((entry) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: TColors.lightContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12,
                      color: TColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < entry.value ? Icons.star : Icons.star_border,
                        size: 14,
                        color: index < entry.value ? TColors.warning : TColors.grey,
                      );
                    }),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return TColors.success;
    if (rating >= 3.0) return TColors.warning;
    return TColors.error;
  }
}