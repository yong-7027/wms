import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/colors.dart';
import '../../controllers/my_feedback/my_feedback_controller.dart';
import '../../models/service_feedback_model.dart';
import 'widgets/my_feedback_tab.dart';
import 'widgets/to_feedback_tab.dart';

class MyServiceFeedbackScreen extends StatelessWidget {
  const MyServiceFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyServiceFeedbackController());

    return Scaffold(
      backgroundColor: TColors.primaryBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        TColors.primary,
                        TColors.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Tab Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() => TabBar(
                controller: controller.tabController,
                labelColor: Colors.white,
                unselectedLabelColor: TColors.textSecondary,
                indicator: BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('To Feedback'),
                        SizedBox(width: 8),
                        if (controller.toFeedbackCount > 0)
                          CountBadge(
                            count: controller.toFeedbackCount,
                            isSelected: controller.tabController.index == 0,
                            color: TColors.warning,
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
                        if (controller.myFeedbackCount > 0)
                          CountBadge(
                            count: controller.myFeedbackCount,
                            isSelected: controller.tabController.index == 1,
                            color: TColors.success,
                          ),
                      ],
                    ),
                  ),
                ],
              )),
            ),
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  ToFeedbackTab(),
                  MyFeedbackTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Count Badge Widget
class CountBadge extends StatelessWidget {
  final int count;
  final bool isSelected;
  final Color color;

  const CountBadge({
    super.key,
    required this.count,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.3) : color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Reusable Loading State Widget
class LoadingStateWidget extends StatelessWidget {
  final String message;

  const LoadingStateWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: TColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            message,
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
}

// Reusable Error State Widget
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: TColors.error,
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: TColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor,
              ),
            ),
            SizedBox(height: 32),
            Text(
              title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: TColors.textSecondary,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// To Feedback Card
class ToFeedbackCard extends StatelessWidget {
  final ServiceFeedbackModel feedback;

  const ToFeedbackCard({
    super.key,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyServiceFeedbackController>();
    final remainingTime = controller.getRemainingTimeToFeedback(feedback.createdAt);
    final isExpired = controller.isFeedbackExpired(feedback.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isExpired ? null : () => controller.navigateToMakeFeedback(feedback),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with time indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Service Appointment #${feedback.appointmentId.substring(0, 8)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isExpired ? TColors.error.withOpacity(0.1) : TColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isExpired ? Icons.timer_off : Icons.timer,
                            size: 16,
                            color: isExpired ? TColors.error : TColors.warning,
                          ),
                          SizedBox(width: 4),
                          Text(
                            controller.formatRemainingTime(remainingTime),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isExpired ? TColors.error : TColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Service info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.build_circle,
                          size: 24,
                          color: TColors.primary,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service Completed',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: TColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Completed on ${feedback.formattedCreatedDate}',
                              style: TextStyle(
                                fontSize: 14,
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
                SizedBox(height: 24),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isExpired ? null : () => controller.navigateToMakeFeedback(feedback),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isExpired ? TColors.grey.withOpacity(0.3) : TColors.primary,
                      foregroundColor: isExpired ? TColors.textSecondary : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: isExpired ? 0 : 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isExpired ? Icons.schedule : Icons.rate_review,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          isExpired ? 'Time Expired' : 'Write Review',
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

// Reusable Rating Display Widget
class RatingDisplay extends StatelessWidget {
  final double rating;
  final bool isDisabled;
  final int starCount;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.isDisabled = false,
    this.starCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(starCount, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_outline,
          size: 20,
          color: isDisabled
              ? TColors.grey.withOpacity(0.5)
              : (index < rating ? TColors.warning : TColors.grey.withOpacity(0.4)),
        );
      }),
    );
  }
}

// My Feedback Card
class MyFeedbackCard extends StatelessWidget {
  final ServiceFeedbackModel feedback;

  const MyFeedbackCard({
    super.key,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyServiceFeedbackController>();

    return Obx(() {
      final isExpanded = controller.isFeedbackExpanded(feedback.id!);
      final canEdit = controller.canEditFeedback(feedback);
      final isDisabled = feedback.status == FeedbackStatus.disabled;

      return Container(
        decoration: BoxDecoration(
          color: isDisabled ? TColors.grey.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDisabled
              ? Border.all(color: TColors.grey.withOpacity(0.3), width: 1)
              : null,
          boxShadow: isDisabled ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: isDisabled ? null : () {
              controller.navigateToFeedbackDetails(feedback);
            },
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Info Section
                  Row(
                    children: [
                      // Vehicle image placeholder
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_car,
                          size: 40,
                          color: TColors.primary,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Vehicle details
                            Text(
                              'Toyota Camry 2020', // This should come from appointment data
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: TColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            // License plate
                            Text(
                              'ABC 1234', // This should come from appointment data
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: TColors.textSecondary,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Appointment time info
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TColors.info.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 20,
                          color: TColors.info,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Completed on ${feedback.formattedCreatedDate}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: TColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Service Types Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // These should come from appointment data
                      _ServiceTag(label: 'Oil Change', color: TColors.info),
                      _ServiceTag(label: 'Brake Check', color: TColors.warning),
                      _ServiceTag(label: 'Tire Rotation', color: TColors.success),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Rating Summary
                  Row(
                    children: [
                      RatingDisplay(
                        rating: feedback.averageRating,
                        isDisabled: isDisabled,
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${feedback.averageRating.toStringAsFixed(1)}/5',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDisabled ? TColors.textSecondary : TColors.textPrimary,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Reviewed ${feedback.formattedCreatedDate}',
                        style: TextStyle(
                          fontSize: 14,
                          color: TColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Expandable toggle for additional details
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => controller.toggleFeedbackExpansion(feedback.id!),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isExpanded ? 'Show Less' : 'Show More Details',
                            style: TextStyle(
                              fontSize: 14,
                              color: TColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: TColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expandable content with detailed feedback info
                  AnimatedCrossFade(
                    firstChild: Container(),
                    secondChild: _buildExpandedContent(feedback, canEdit, isDisabled, controller),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExpandedContent(
      ServiceFeedbackModel feedback,
      bool canEdit,
      bool isDisabled,
      MyServiceFeedbackController controller,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Divider(color: TColors.grey.withOpacity(0.3)),
        SizedBox(height: 16),

        // Detailed Ratings
        _buildDetailedRatings(feedback, isDisabled),
        SizedBox(height: 20),

        // Review Comment
        if (feedback.comment.isNotEmpty) ...[
          Text(
            'Your Review:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDisabled ? TColors.textSecondary : TColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              feedback.comment,
              style: TextStyle(
                fontSize: 15,
                color: isDisabled ? TColors.textSecondary : TColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16),
        ],

        // Staff Reply
        if (feedback.hasStaffReply) ...[
          Text(
            'Staff Reply:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TColors.info,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              feedback.staffReply,
              style: TextStyle(
                fontSize: 15,
                color: TColors.info,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16),
        ],

        // Action buttons
        if (canEdit) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.navigateToEditFeedback(feedback),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TColors.primary,
                    side: BorderSide(color: TColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Edit Review',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Time remaining info
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: TColors.warning,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can edit this review for ${controller.formatRemainingTime(controller.getRemainingTimeToEdit(feedback.updatedAt, feedback.editRemaining))}',
                    style: TextStyle(
                      fontSize: 13,
                      color: TColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailedRatings(ServiceFeedbackModel feedback, bool isDisabled) {
    final ratings = [
      {'label': 'Service Quality', 'rating': feedback.serviceRating.toDouble()},
      {'label': 'Efficiency', 'rating': feedback.repairEfficiencyRating.toDouble()},
      {'label': 'Transparency', 'rating': feedback.transparencyRating.toDouble()},
      {'label': 'Overall Experience', 'rating': feedback.overallExperienceRating.toDouble()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Ratings:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDisabled ? TColors.textSecondary : TColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        ...ratings.map((rating) => Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  rating['label'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDisabled ? TColors.textSecondary : TColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    RatingDisplay(
                      rating: rating['rating'] as double,
                      isDisabled: isDisabled,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${(rating['rating'] as double).toStringAsFixed(0)}/5',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDisabled ? TColors.textSecondary : TColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}

// Helper widget for service tags
class _ServiceTag extends StatelessWidget {
  final String label;
  final Color color;

  const _ServiceTag({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
