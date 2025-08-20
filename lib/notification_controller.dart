import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReviewController extends GetxController with GetTickerProviderStateMixin {
  // Service information
  final RxString serviceType = 'Service Type'.obs;
  final RxString carName = 'Car name'.obs;
  final RxString serviceDetails = 'Service Details'.obs;
  final RxString serviceDate = '19/07/2025, 01:11 PM'.obs;

  // Rating states
  final RxInt serviceRating = 0.obs;
  final RxInt repairEfficiencyRating = 0.obs;
  final RxInt transparencyRating = 0.obs;
  final RxInt overallExperienceRating = 0.obs;

  // Previous rating states to track changes
  final RxInt previousServiceRating = 0.obs;
  final RxInt previousRepairRating = 0.obs;
  final RxInt previousTransparencyRating = 0.obs;
  final RxInt previousOverallRating = 0.obs;

  // Animation controllers for stars
  late List<AnimationController> starAnimationControllers;
  late List<Animation<double>> starAnimations;

  // Special animation controllers for 4-5 stars (fireworks effect)
  late AnimationController fireworksController;
  late Animation<double> fireworksAnimation;

  // Media upload
  final RxList<File> uploadedMedia = <File>[].obs;
  final ImagePicker _picker = ImagePicker();
  final int maxMediaCount = 3;
  final int maxFileSizeMB = 10;

  // Comment
  final RxString comment = ''.obs;
  final RxInt commentLength = 0.obs; // Add observable for comment length
  final int maxCommentLength = 150;
  final TextEditingController commentController = TextEditingController();

  // Validation states
  final RxBool canSubmit = false.obs;
  final RxString validationMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize star animation controllers
    starAnimationControllers = List.generate(20, (index) =>
        AnimationController(
          duration: Duration(milliseconds: 300),
          vsync: this,
        )
    );

    starAnimations = starAnimationControllers.map((controller) =>
        Tween<double>(begin: 1.0, end: 1.3).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut)
        )
    ).toList();

    // Initialize fireworks animation controller
    fireworksController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    fireworksAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: fireworksController,
        curve: Curves.easeOut,
      ),
    );

    // Listen to rating changes for validation
    ever(serviceRating, (_) => validateForm());
    ever(repairEfficiencyRating, (_) => validateForm());
    ever(transparencyRating, (_) => validateForm());
    ever(overallExperienceRating, (_) => validateForm());
    ever(comment, (_) => validateForm());
  }

  @override
  void onClose() {
    for (var controller in starAnimationControllers) {
      controller.dispose();
    }
    fireworksController.dispose();
    commentController.dispose();
    super.onClose();
  }

  // Rating methods with smart animation
  void setRating(String category, int rating) {
    int startIndex;
    int previousRating;

    switch (category) {
      case 'service':
        previousRating = previousServiceRating.value;
        serviceRating.value = rating;
        previousServiceRating.value = rating;
        startIndex = 0;
        break;
      case 'repair':
        previousRating = previousRepairRating.value;
        repairEfficiencyRating.value = rating;
        previousRepairRating.value = rating;
        startIndex = 5;
        break;
      case 'transparency':
        previousRating = previousTransparencyRating.value;
        transparencyRating.value = rating;
        previousTransparencyRating.value = rating;
        startIndex = 10;
        break;
      case 'overall':
        previousRating = previousOverallRating.value;
        overallExperienceRating.value = rating;
        previousOverallRating.value = rating;
        startIndex = 15;
        break;
      default:
        return;
    }

    _animateStarsSmartly(startIndex, rating, previousRating);

    // Special animation for 4-5 stars
    if (rating >= 4) {
      _triggerFireworksAnimation();
    }
  }

  void _animateStarsSmartly(int startIndex, int newRating, int previousRating) {
    // Only animate if rating increased
    if (newRating > previousRating) {
      // Animate only the new stars
      for (int i = previousRating; i < newRating; i++) {
        Future.delayed(Duration(milliseconds: (i - previousRating) * 100), () {
          starAnimationControllers[startIndex + i].forward().then((_) {
            starAnimationControllers[startIndex + i].reverse();
          });
        });
      }
    }
    // If rating decreased or stayed same, no animation
  }

  void _triggerFireworksAnimation() {
    fireworksController.reset();
    fireworksController.forward();
  }

  // Media upload methods
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

  // Comment methods
  void updateComment(String value) {
    if (value.length <= maxCommentLength) {
      comment.value = _escapeHtml(value);
      commentLength.value = value.length; // Update observable length
    } else {
      // Prevent input beyond limit
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

    canSubmit.value = true;
    validationMessage.value = '';
  }

  // Submit review
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
      // Show loading
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Close loading
      Get.back();

      // Show success message
      Get.snackbar(
        'Review Submitted',
        'Thank you for your feedback!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reset form or navigate back
      Get.back();

    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to submit review: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Getters
  int get remainingMediaSlots => maxMediaCount - uploadedMedia.length;

  // Media preview methods
  void showMediaPreview(File file, int index) {
    String extension = file.path.split('.').last.toLowerCase();
    bool isVideo = ['mp4', 'mov'].contains(extension);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.7,
          child: Stack(
            children: [
              Center(
                child: isVideo
                    ? VideoPreviewWidget(file: file)
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

// Video Preview Widget
class VideoPreviewWidget extends StatefulWidget {
  final File file;

  const VideoPreviewWidget({Key? key, required this.file}) : super(key: key);

  @override
  _VideoPreviewWidgetState createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Icon(
            Icons.video_library,
            size: 100,
            color: Colors.white54,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isPlaying = !isPlaying;
            });
            // Here you would implement actual video playback
            // For now, just show play/pause states
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          child: Text(
            'Tap to ${isPlaying ? 'pause' : 'play'}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}