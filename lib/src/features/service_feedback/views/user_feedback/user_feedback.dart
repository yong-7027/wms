import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/user_feedback/user_feedback_controller.dart';
import '../../models/service_feedback_model.dart';
import 'widgets/media_lightbox.dart';
import 'widgets/rating_bar.dart';
import 'widgets/report_dialog.dart';

class UserFeedbackScreen extends StatelessWidget {
  const UserFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserFeedbackController());

    return Scaffold(
      backgroundColor: TColors.primaryBackground,
      appBar: AppBar(
        title: Text('User Feedbacks'),
        backgroundColor: TColors.primary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Overall Rating Section
              _buildOverallRatingSection(controller),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Rating Progress Bars
              _buildRatingProgressBars(controller),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Filter Tabs
              _buildFilterTabs(controller),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Sort Dropdown
              _buildSortSection(controller),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Reviews List
              _buildReviewsList(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOverallRatingSection(UserFeedbackController controller) {
    return Column(
      children: [
        Text(
          controller.averageRating.value.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: TColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        RatingBar(rating: controller.averageRating.value),
        const SizedBox(height: 8),
        Text(
          'Based on ${controller.totalReviews.value} reviews',
          style: const TextStyle(
            fontSize: 14,
            color: TColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingProgressBars(UserFeedbackController controller) {
    final categories = [
      'Service',
      'Repair Efficiency',
      'Transparency',
      'Overall Experience'
    ];

    return Column(
      children: categories.map((category) {
        // Calculate average for each category from all feedbacks
        double categoryAverage = _calculateCategoryAverage(controller, category);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: categoryAverage / 5.0,
                  backgroundColor: TColors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(TColors.primary),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  double _calculateCategoryAverage(UserFeedbackController controller, String category) {
    if (controller.allFeedbacks.isEmpty) return 0.0;

    double total = 0;
    int count = 0;

    for (final feedback in controller.allFeedbacks) {
      switch (category) {
        case 'Service':
          total += feedback.serviceRating;
          break;
        case 'Repair Efficiency':
          total += feedback.repairEfficiencyRating;
          break;
        case 'Transparency':
          total += feedback.transparencyRating;
          break;
        case 'Overall Experience':
          total += feedback.overallExperienceRating;
          break;
      }
      count++;
    }

    return count > 0 ? total / count : 0.0;
  }

  Widget _buildFilterTabs(UserFeedbackController controller) {
    final filters = [
      {'label': 'All', 'value': FilterOption.all},
      {'label': 'With media', 'value': FilterOption.withMedia},
      {'label': '5 star', 'value': FilterOption.fiveStar},
      {'label': '4 star', 'value': FilterOption.fourStar},
      {'label': '3 star', 'value': FilterOption.threeStar},
      {'label': '2 star', 'value': FilterOption.twoStar},
      {'label': '1 star', 'value': FilterOption.oneStar},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = controller.selectedFilter.value == filter['value'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter['label'] as String,
                style: TextStyle(
                  color: isSelected ? TColors.white : TColors.textPrimary,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => controller.updateFilter(filter['value'] as FilterOption),
              backgroundColor: TColors.white,
              selectedColor: TColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? TColors.primary : TColors.borderPrimary,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortSection(UserFeedbackController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Sort by',
          style: TextStyle(
            fontSize: 14,
            color: TColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<SortOption>(
          value: controller.selectedSort.value,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, color: TColors.textSecondary),
          items: const [
            DropdownMenuItem(
              value: SortOption.mostRecent,
              child: Text('Most recent', style: TextStyle(fontSize: 14)),
            ),
            DropdownMenuItem(
              value: SortOption.mostHelpful,
              child: Text('Most helpful', style: TextStyle(fontSize: 14)),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.updateSort(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildReviewsList(UserFeedbackController controller) {
    if (controller.filteredFeedbacks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No reviews found',
            style: TextStyle(
              fontSize: 16,
              color: TColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: controller.filteredFeedbacks
          .map((feedback) => _buildReviewItem(controller, feedback))
          .toList(),
    );
  }

  Widget _buildReviewItem(UserFeedbackController controller, ServiceFeedbackModel feedback) {
    final serviceTypes = controller.getServiceTypesForFeedback(feedback.appointmentId);
    final isCurrentUser = controller.isFeedbackFromCurrentUser(feedback);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and menu
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: TColors.primary.withOpacity(0.1),
                child: Text(
                  feedback.comment.isNotEmpty
                      ? feedback.comment[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: TColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.id?.substring(0, 8) ?? '', // Mock user name
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingBar(
                          rating: feedback.averageRating,
                          size: 16,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          feedback.formattedCreatedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: TColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isCurrentUser) ...[
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: TColors.textSecondary,
                        size: 20,
                      ),
                      onSelected: (value) {
                        if (value == 'report') {
                          _showReportDialog(controller, feedback.id!);
                        }
                      },
                      itemBuilder: (context) => [
                        if (controller.canReportFeedback(feedback.id!))
                          const PopupMenuItem<String>(
                            value: 'report',
                            child: Row(
                              children: [
                                Icon(Icons.flag_outlined, size: 18, color: TColors.error),
                                SizedBox(width: 8),
                                Text('Report'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Service type tags
          if (serviceTypes.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: serviceTypes.map((serviceType) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    serviceType.serviceName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Comment
          if (feedback.comment.isNotEmpty) ...[
            Text(
              feedback.comment,
              style: const TextStyle(
                fontSize: 14,
                color: TColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Media
          if (feedback.mediaFilenames.isNotEmpty) ...[
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: feedback.mediaFilenames.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showMediaLightbox(feedback.mediaFilenames, index),
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: TColors.lightGrey,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildMediaImage(feedback.mediaFilenames[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Staff reply
          if (feedback.hasStaffReply) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColors.lightContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Staff Response',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feedback.staffReply,
                    style: const TextStyle(
                      fontSize: 14,
                      color: TColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 10),

          // Like button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => controller.toggleLike(feedback.id!),
                  child: Row(
                    children: [
                      Text(
                        'Helpful ',
                        style: TextStyle(
                          fontSize: 12,
                          color: feedback.likes.contains('controller._authRepository.authUser?.uid')
                              ? TColors.primary
                              : TColors.textSecondary,
                        ),
                      ),
                      Text(
                        '(${feedback.likes.length})',
                        style: TextStyle(
                          fontSize: 12,
                          color: feedback.likes.contains('controller._authRepository.authUser?.uid')
                              ? TColors.primary
                              : TColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        feedback.likes.contains('controller._authService.authUser?.uid')
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 18,
                        color: feedback.likes.contains('controller._authRepository.authUser?.uid')
                            ? TColors.primary
                            : TColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      // Network image
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.error,
          color: TColors.error,
        ),
      );
    } else {
      // Local file
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.error,
          color: TColors.error,
        ),
      );
    }
  }

  void _showMediaLightbox(List<String> mediaFilenames, int initialIndex) {
    Get.dialog(
      MediaLightbox(
        mediaFilenames: mediaFilenames,
        initialIndex: initialIndex,
      ),
    );
  }

  void _showReportDialog(UserFeedbackController controller, String feedbackId) {
    Get.dialog(
      ReportDialog(
        onReport: (reason) => controller.reportFeedback(feedbackId, reason),
      ),
    );
  }
}