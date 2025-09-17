import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wms/src/features/service_feedback/controllers/star_animation_controller.dart';
import 'dart:io';
import '../../../data/repository/service_feedback/service_feedback_repo.dart';
import '../models/service_feedback_model.dart';
import '../views/make_feedback/widgets/success_popup.dart';
import '../views/make_feedback/widgets/video_preview.dart';

class ServiceFeedbackController extends GetxController with GetTickerProviderStateMixin {
  // Service information
  final RxString serviceType = 'Service Type'.obs;
  final RxString carName = 'Car name'.obs;
  final RxString serviceDetails = 'Service Details'.obs;
  final RxString serviceDate = '19/07/2025, 01:11 PM'.obs;
  final RxString appointmentId = 'service_123'.obs; // Add service ID
  final RxString userId = 'user_456'.obs; // Add user ID

  // Rating states
  final RxInt serviceRating = 0.obs;
  final RxInt repairEfficiencyRating = 0.obs;
  final RxInt transparencyRating = 0.obs;
  final RxInt overallExperienceRating = 0.obs;

  // Previous rating states to track which stars are newly lit
  final RxInt previousServiceRating = 0.obs;
  final RxInt previousRepairEfficiencyRating = 0.obs;
  final RxInt previousTransparencyRating = 0.obs;
  final RxInt previousOverallExperienceRating = 0.obs;

  // Star animation system - optimized version
  final RxMap<String, List<StarAnimationController>> starAnimations = <String, List<StarAnimationController>>{}.obs;

  // StarShine animation controllers for 5-star ratings (one for each category)
  final RxMap<String, AnimationController> shineControllers = <String, AnimationController>{}.obs;
  final RxMap<String, Animation<double>> shineAnimations = <String, Animation<double>>{}.obs;

  // Media upload
  final RxList<File> uploadedMedia = <File>[].obs;
  final ImagePicker _picker = ImagePicker();
  final int maxMediaCount = 3;
  final int maxFileSizeMB = 10;

  // Comment
  final RxString comment = ''.obs;
  final RxInt commentLength = 0.obs;
  final int maxCommentLength = 150;
  final TextEditingController commentController = TextEditingController();

  // Validation states
  final RxBool canSubmit = false.obs;
  final RxString validationMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasExistingReview = false.obs;

  // Firestore service
  late ServiceFeedbackRepository _feedbackRepository;

  @override
  void onInit() {
    super.onInit();

    // Initialize Firestore service
    _feedbackRepository = ServiceFeedbackRepository();

    // Initialize star animations
    _initializeStarAnimations();
    _initializeStarShineAnimation();

    // Form validation listeners
    ever(serviceRating, (_) => validateForm());
    ever(repairEfficiencyRating, (_) => validateForm());
    ever(transparencyRating, (_) => validateForm());
    ever(overallExperienceRating, (_) => validateForm());
    ever(comment, (_) => validateForm());

    // Check for existing review on initialization
    checkExistingReview();
  }

  /// Initialize star animation controllers for each rating category
  void _initializeStarAnimations() {
    final categories = ['service', 'repair', 'transparency', 'overall'];
    for (String category in categories) {
      starAnimations[category] = List.generate(5, (index) =>
          StarAnimationController(
            vsync: this,
            duration: Duration(milliseconds: 200),
          )
      );
    }
  }

  /// Initialize starshine animations for 5-star special effects (one for each category)
  void _initializeStarShineAnimation() {
    final categories = ['service', 'repair', 'transparency', 'overall'];

    for (String category in categories) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      );

      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutQuart,
        ),
      );

      shineControllers[category] = controller;
      shineAnimations[category] = animation;
    }
  }

  @override
  void onClose() {
    // Dispose shine animation controllers
    for (var controller in shineControllers.values) {
      controller.dispose();
    }

    // Dispose star animation controllers
    for (var categoryAnimations in starAnimations.values) {
      for (var controller in categoryAnimations) {
        controller.dispose();
      }
    }

    commentController.dispose();
    super.onClose();
  }

  /// Set rating for a specific category with immediate synchronized animation
  void setRating(String category, int rating) {
    int previousRating = _getPreviousRating(category);

    // 立即触发动画，但不立即更新评分值
    _handleRatingChangeImmediately(category, rating, previousRating);

    // 延迟更新评分值，让动画和状态变化同步
    Future.delayed(Duration(milliseconds: 50), () {
      _updateRatingValue(category, rating, previousRating);
    });
  }

  /// Get previous rating for category
  int _getPreviousRating(String category) {
    switch (category) {
      case 'service':
        return serviceRating.value;
      case 'repair':
        return repairEfficiencyRating.value;
      case 'transparency':
        return transparencyRating.value;
      case 'overall':
        return overallExperienceRating.value;
      default:
        return 0;
    }
  }

  /// Update rating value after animation starts
  void _updateRatingValue(String category, int rating, int previousRating) {
    switch (category) {
      case 'service':
        previousServiceRating.value = previousRating;
        serviceRating.value = rating;
        break;
      case 'repair':
        previousRepairEfficiencyRating.value = previousRating;
        repairEfficiencyRating.value = rating;
        break;
      case 'transparency':
        previousTransparencyRating.value = previousRating;
        transparencyRating.value = rating;
        break;
      case 'overall':
        previousOverallExperienceRating.value = previousRating;
        overallExperienceRating.value = rating;
        break;
    }
  }

  /// Handle rating changes immediately with synchronized animation and state
  void _handleRatingChangeImmediately(String category, int newRating, int previousRating) {
    print("New rating: $newRating + Prev rating: $previousRating");
    final animations = starAnimations[category];
    if (animations == null) return;

    // 重置所有星星动画
    for (var controller in animations) {
      controller.reset();
    }

    // 同步触发动画和状态变化
    if (newRating > previousRating) {
      // 评分增加：依次快速触发每颗新星的动画
      for (int i = previousRating; i < newRating; i++) {
        if (i < animations.length) {
          final delay = Duration(milliseconds: (i - previousRating) * 80); // 减少延迟
          Future.delayed(delay, () {
            // animations = 0-4, new & prev rating = 1-5
            animations[i].triggerBounceAnimation();
          });
        }
      }
    } else if (newRating <= previousRating && newRating > 0) {
      // 评分减少：立即触发最高剩余星星的动画
      animations[newRating - 1].triggerBounceAnimation();
    }

    // 5星特效 - 触发对应类别的StarShine动画
    if (newRating == 5) {
      _triggerStarShineAnimation(category);
    }
  }

  /// Trigger starshine animation for maximum rating in specific category
  void _triggerStarShineAnimation(String category) {
    final controller = shineControllers[category];
    if (controller != null) {
      controller.reset();
      controller.forward();
    }
  }

  // Media upload methods (unchanged)
  Future<void> pickMedia() async {
    if (uploadedMedia.length >= maxMediaCount) {
      Get.snackbar(
        'Upload Limit',
        'You can only upload up to $maxMediaCount files',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);

        // Validate file size
        final int fileSizeInBytes = await file.length();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > maxFileSizeMB) {
          Get.snackbar(
            'File Too Large',
            'File size must be less than ${maxFileSizeMB}MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Validate file format
        final String extension = pickedFile.path.split('.').last.toLowerCase();
        final List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov'];

        if (!allowedExtensions.contains(extension)) {
          Get.snackbar(
            'Invalid Format',
            'Only images (JPG, PNG, GIF) and videos (MP4, MOV) are allowed',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        uploadedMedia.add(file);
        Get.snackbar(
          'Success',
          'Media uploaded successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick media: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeMedia(int index) {
    if (index < uploadedMedia.length) {
      uploadedMedia.removeAt(index);
    }
  }

  // Comment methods (unchanged)
  void updateComment(String value) {
    if (value.length <= maxCommentLength) {
      comment.value = _escapeHtml(value);
      commentLength.value = value.length;
    } else {
      commentController.text = commentController.text.substring(0, maxCommentLength);
      commentController.selection = TextSelection.fromPosition(
        TextPosition(offset: maxCommentLength),
      );
      commentLength.value = maxCommentLength;
    }
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  // Validation
  void validateForm() {
    final bool hasAllRatings = serviceRating.value > 0 &&
        repairEfficiencyRating.value > 0 &&
        transparencyRating.value > 0 &&
        overallExperienceRating.value > 0;

    if (!hasAllRatings) {
      canSubmit.value = false;
      validationMessage.value = 'Please rate all categories';
      return;
    }

    if (hasExistingReview.value) {
      canSubmit.value = false;
      validationMessage.value = 'You have already reviewed this service';
      return;
    }

    canSubmit.value = true;
    validationMessage.value = '';
  }

  /// Check if user has already reviewed this service
  Future<void> checkExistingReview() async {
    try {
      isLoading.value = true;

      // Replace the existing method call with:
      final feedbacks = await _feedbackRepository.getAllFeedbacks(
        userId: userId.value,
        appointmentId: appointmentId.value,
        limit: 1,
      ).first;

      hasExistingReview.value = feedbacks.isNotEmpty;
      validateForm();
    } catch (e) {
      print('Error checking existing review: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit review to Firestore and update appointment
  Future<void> submitReview() async {
    if (!canSubmit.value) {
      Get.snackbar(
        'Incomplete Review',
        validationMessage.value,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Show loading dialog
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Create feedback model
      final feedback = ServiceFeedbackModel.fromController(
        appointmentId: appointmentId.value,
        userId: userId.value,
        serviceRating: serviceRating.value,
        repairEfficiencyRating: repairEfficiencyRating.value,
        transparencyRating: transparencyRating.value,
        overallExperienceRating: overallExperienceRating.value,
        comment: comment.value,
        mediaFiles: uploadedMedia,
      );

      // Submit feedback and update appointment
      await _feedbackRepository.createFeedback(feedback);

      // Close loading dialog
      Get.back();

      // Show success popup
      Get.dialog(
        SuccessPopup(
          onClose: () {
            // Navigate back to previous screen after popup is closed
            Get.back();
          },
        ),
        barrierDismissible: false,
      );

      // Navigate back
      // Get.back();

    } catch (e) {
      // Close loading dialog
      Get.back();

      Get.snackbar(
        'Error',
        'Failed to submit review: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Getters
  int get remainingMediaSlots => maxMediaCount - uploadedMedia.length;

  // Media preview methods (unchanged)
  void showMediaPreview(File file, int index) {
    String extension = file.path.split('.').last.toLowerCase();
    bool isVideo = ['mp4', 'mov'].contains(extension);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        child: SizedBox(
          width: Get.width * 0.9,
          height: Get.height * 0.7,
          child: Stack(
            children: [
              Center(
                child: isVideo
                    ? VideoPreview(file: file)
                    : InteractiveViewer(
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
