import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wms/src/features/service_feedback/controllers/star_animation_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import '../../../data/repository/service_feedback/service_feedback_repository.dart';
import '../models/service_feedback_model.dart';
import '../views/make_feedback/widgets/success_popup.dart';
import '../views/make_feedback/widgets/video_preview.dart';
import 'package:http/http.dart' as http;

enum MediaType { image, video }

class ServiceFeedbackController extends GetxController
    with GetTickerProviderStateMixin {
  final ServiceFeedbackModel feedback;

  ServiceFeedbackController({required this.feedback});

  // 添加加载状态
  final RxBool isMediaLoading = true.obs;
  final RxBool isInitializing = true.obs;

  // Service information
  final RxString serviceType = 'Service Type'.obs;
  final RxString carName = 'Car name'.obs;
  final RxString serviceDetails = 'Service Details'.obs;
  final RxString serviceDate = '19/07/2025, 01:11 PM'.obs;
  final RxString appointmentId = 'service_123'.obs;
  final RxString userId = '3ohlF9J881SuN5qzzL43L8JQ9ex1'.obs;

  // Rating states
  final RxInt serviceRating = 0.obs;
  final RxInt repairEfficiencyRating = 0.obs;
  final RxInt transparencyRating = 0.obs;
  final RxInt overallExperienceRating = 0.obs;

  // Previous rating states
  final RxInt previousServiceRating = 0.obs;
  final RxInt previousRepairEfficiencyRating = 0.obs;
  final RxInt previousTransparencyRating = 0.obs;
  final RxInt previousOverallExperienceRating = 0.obs;

  // Star animation system
  final RxMap<String, List<StarAnimationController>> starAnimations =
      <String, List<StarAnimationController>>{}.obs;
  final RxMap<String, AnimationController> shineControllers =
      <String, AnimationController>{}.obs;
  final RxMap<String, Animation<double>> shineAnimations =
      <String, Animation<double>>{}.obs;

  // Media upload - 存储临时文件路径
  final RxList<String> temporaryMediaPaths = <String>[].obs; // 临时文件路径
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = Uuid();
  final int maxMediaCount = 3;
  // final int maxFileSizeMB = 10;

  final int maxVideoDurationSeconds = 60; // 最长1分钟
  final int maxFileSizeMB = 10;

  // 添加要删除的文件名列表
  final RxList<String> _filesToDelete = <String>[].obs;

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

    // Initialize with existing feedback data if any
    if (feedback.comment.isNotEmpty) {
      comment.value = feedback.comment;
      commentController.text = feedback.comment;
      commentLength.value = feedback.comment.length;
    }

    // 加载已有的评分
    serviceRating.value = feedback.serviceRating;
    repairEfficiencyRating.value = feedback.repairEfficiencyRating;
    transparencyRating.value = feedback.transparencyRating;
    overallExperienceRating.value = feedback.overallExperienceRating;

    // 初始化星形动画
    _initializeStarAnimations();
    _initializeStarShineAnimation();

    // 异步加载媒体文件
    _initializeMediaFiles().then((_) {
      isInitializing.value = false;
    });

    // Form validation listeners
    ever(serviceRating, (_) => validateForm());
    ever(repairEfficiencyRating, (_) => validateForm());
    ever(transparencyRating, (_) => validateForm());
    ever(overallExperienceRating, (_) => validateForm());
    ever(comment, (_) => validateForm());
    ever(temporaryMediaPaths, (_) => validateForm());
  }

  /// Initialize star animation controllers for each rating category
  void _initializeStarAnimations() {
    final categories = ['service', 'repair', 'transparency', 'overall'];
    for (String category in categories) {
      starAnimations[category] = List.generate(
        5,
        (index) => StarAnimationController(
          vsync: this,
          duration: Duration(milliseconds: 200),
        ),
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
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart),
      );

      shineControllers[category] = controller;
      shineAnimations[category] = animation;
    }
  }

  /// 初始化媒体文件
  Future<void> _initializeMediaFiles() async {
    try {
      isMediaLoading.value = true;

      // 加载已有的媒体文件
      if (feedback.mediaFilenames.isNotEmpty) {
        await _loadExistingMediaFiles();
      }

      isMediaLoading.value = false;
    } catch (e) {
      print('Error initializing media files: $e');
      isMediaLoading.value = false;
    }
  }

  /// 加载已有的媒体文件
  Future<void> _loadExistingMediaFiles() async {
    try {
      // 下载已有的媒体文件到本地临时路径
      for (String filename in feedback.mediaFilenames) {
        try {
          // 从 Firebase Storage 下载文件到临时路径
          final String tempPath = await _downloadMediaToTemp(filename);
          temporaryMediaPaths.add(tempPath);
        } catch (e) {
          print('Failed to load existing media file $filename: $e');
          // 即使某个文件加载失败，继续加载其他文件
        }
      }
    } catch (e) {
      print('Error loading existing media files: $e');
      rethrow;
    }
  }

  /// 从 Firebase Storage 下载媒体文件到临时路径
  Future<String> _downloadMediaToTemp(String filename) async {
    try {
      // 获取下载 URL
      final String downloadUrl = await _feedbackRepository.getMediaDownloadUrl(filename);

      // 创建临时文件
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/$filename';
      final File tempFile = File(tempPath);

      // 下载文件
      final http.Response response = await http.get(Uri.parse(downloadUrl));
      await tempFile.writeAsBytes(response.bodyBytes);

      return tempPath;
    } catch (e) {
      print('Error downloading media file $filename: $e');
      rethrow;
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

    // Clean up temporary files
    _cleanUpTemporaryFiles();

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
  void _handleRatingChangeImmediately(
    String category,
    int newRating,
    int previousRating,
  ) {
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
          final delay = Duration(
            milliseconds: (i - previousRating) * 80,
          ); // 减少延迟
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

  // Media upload methods - 支持拍照和相册选择
  Future<void> pickMedia() async {
    if (temporaryMediaPaths.length >= maxMediaCount) {
      Get.snackbar(
        'Upload Limit',
        'You can only upload up to $maxMediaCount files',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // 显示选择对话框：拍照或从相册选择
    await Get.dialog(
      AlertDialog(
        title: Text('Select Media Source'),
        content: Text('Choose how you want to add media'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              pickMediaFromCamera();
            },
            child: Text('Take Photo'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              pickMediaFromGallery();
            },
            child: Text('Choose from Gallery'),
          ),
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
        ],
      ),
    );
  }

  // 从相机拍照
  // 从相机拍照或录制视频
  Future<void> pickMediaFromCamera() async {
    try {
      // 显示选择对话框：拍照或录制视频
      final MediaType? selectedType = await Get.dialog<MediaType>(
        AlertDialog(
          title: Text('Select Media Type'),
          content: Text('Choose what you want to capture'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: MediaType.image),
              child: Text('Take Photo'),
            ),
            TextButton(
              onPressed: () => Get.back(result: MediaType.video),
              child: Text('Record Video'),
            ),
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ],
        ),
      );

      if (selectedType == null) return;

      XFile? pickedFile;

      if (selectedType == MediaType.image) {
        pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.rear,
        );
      } else if (selectedType == MediaType.video) {
        pickedFile = await _picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 60), // 限制最长60秒
          preferredCameraDevice: CameraDevice.rear,
        );
      }

      if (pickedFile != null) {
        await _processTemporaryMedia(File(pickedFile.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture media: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 从相册选择
  Future<void> pickMediaFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _processTemporaryMedia(File(pickedFile.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick media from gallery: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 处理临时媒体文件（支持图片和视频）
  Future<void> _processTemporaryMedia(File file) async {
    try {
      // 检查文件大小
      final int fileSizeInBytes = await file.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > maxFileSizeMB) {
        Get.snackbar(
          'File Too Large',
          'File size must be less than ${maxFileSizeMB}MB',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // 删除过大的文件
        await file.delete();
        return;
      }

      // 验证文件格式
      final String extension = file.path.split('.').last.toLowerCase();
      final List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      final List<String> allowedVideoExtensions = ['mp4', 'mov', 'avi', 'mkv'];

      final bool isImage = allowedImageExtensions.contains(extension);
      final bool isVideo = allowedVideoExtensions.contains(extension);

      if (!isImage && !isVideo) {
        Get.snackbar(
          'Invalid Format',
          'Only images (JPG, PNG, GIF, WEBP) and videos (MP4, MOV, AVI, MKV) are allowed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        await file.delete();
        return;
      }

      // 如果是视频，检查时长
      if (isVideo) {
        final Duration? videoDuration = await _getVideoDuration(file);
        if (videoDuration != null && videoDuration.inSeconds > maxVideoDurationSeconds) {
          Get.snackbar(
            'Video Too Long',
            'Videos must be shorter than ${maxVideoDurationSeconds ~/ 60} minutes',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );

          await file.delete();
          return;
        }
      }

      // 处理文件路径
      String processedFilePath = file.path;

      // 如果是图片且不是WebP格式，进行压缩和转换
      if (isImage && extension != 'webp') {
        final File? compressedFile = await _compressImage(file);
        if (compressedFile != null) {
          // 删除原始文件
          await file.delete();
          processedFilePath = compressedFile.path;
        }
      }

      // 添加到临时文件列表
      temporaryMediaPaths.add(processedFilePath);

      Get.snackbar(
        'Success',
        isImage ? 'Photo processed successfully' : 'Video recorded successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process media: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // 确保在出错时清理文件
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (deleteError) {
        print('Error deleting temporary file: $deleteError');
      }
    }
  }

  /// Compress image using flutter_image_compress and convert to WebP
  Future<File?> _compressImage(File originalFile) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String uuid = _uuid.v4();
      final String compressedPath = '${tempDir.path}/${uuid}_compressed.webp';

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        compressedPath,
        format: CompressFormat.webp,
        quality: 85, // 压缩质量 (0-100)
        minWidth: 800, // 最小宽度
        minHeight: 600, // 最小高度
      );

      if (result != null) {
        final File compressedFile = File(result.path);

        // 检查压缩后的文件大小
        final int compressedSize = await compressedFile.length();
        final double compressedSizeMB = compressedSize / (1024 * 1024);

        if (compressedSizeMB > maxFileSizeMB) {
          // 如果压缩后仍然太大，尝试更高质量的压缩
          final XFile? higherCompressionResult = await FlutterImageCompress.compressAndGetFile(
            originalFile.absolute.path,
            compressedPath,
            format: CompressFormat.webp,
            quality: 70, // 更低的压缩质量
            minWidth: 640,
            minHeight: 480,
          );

          if (higherCompressionResult != null) {
            return File(higherCompressionResult.path);
          }
        }

        return compressedFile;
      }

      return null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  // 获取视频时长
  Future<Duration?> _getVideoDuration(File videoFile) async {
    VideoPlayerController? controller;

    try {
      // 创建视频控制器
      controller = VideoPlayerController.file(videoFile);

      // 初始化控制器
      await controller.initialize();

      // 获取视频时长
      final Duration duration = controller.value.duration;

      // 检查是否为有效时长
      if (duration.inSeconds <= 0) {
        print('Invalid video duration: $duration');
        return null;
      }

      print('Video duration: ${duration.inSeconds} seconds');
      return duration;
    } catch (e) {
      print('Error getting video duration: $e');
      return null;
    } finally {
      // 确保释放控制器资源
      if (controller != null) {
        await controller.dispose();
      }
    }
  }

  void removeMedia(int index) {
    if (index < temporaryMediaPaths.length) {
      final String filePath = temporaryMediaPaths[index];
      final String filename = filePath.split('/').last;

      // 检查是否是已存在的文件（从服务器下载的）
      final bool isExistingFile = feedback.mediaFilenames.contains(filename);

      if (isExistingFile) {
        // 对于已存在的文件，需要从最终的mediaFilenames中移除
        // 这里我们标记要删除的文件名
        _addFileToDeleteList(filename);
      }

      // 删除临时文件
      try {
        final File file = File(filePath);
        if (file.existsSync()) {
          file.delete();
        }
      } catch (e) {
        print('Error deleting temporary file: $e');
      }

      // 从列表中移除
      temporaryMediaPaths.removeAt(index);
    }
  }

  void _addFileToDeleteList(String filename) {
    if (!_filesToDelete.contains(filename)) {
      _filesToDelete.add(filename);
    }
  }

  // 清理临时文件
  Future<void> _cleanUpTemporaryFiles() async {
    for (String tempPath in temporaryMediaPaths) {
      try {
        final File tempFile = File(tempPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        print('Error cleaning up temporary file: $e');
      }
    }
  }

  // Comment methods
  void updateComment(String value) {
    if (value.length <= maxCommentLength) {
      comment.value = _escapeHtml(value);
      commentLength.value = value.length;
    } else {
      commentController.text = commentController.text.substring(
        0,
        maxCommentLength,
      );
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
    final bool hasAllRatings =
        serviceRating.value > 0 &&
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

  /// Submit review to Firestore with Firebase Storage media upload
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

      // 处理要删除的文件
      await _deleteMarkedFiles();

      // 处理媒体文件：上传新文件，保留未删除的已有文件
      List<String> mediaFilenames = [];

      // 首先添加未删除的已有文件名
      if (feedback.mediaFilenames.isNotEmpty) {
        for (String filename in feedback.mediaFilenames) {
          if (!_filesToDelete.contains(filename)) {
            mediaFilenames.add(filename);
          }
        }
      }

      // 上传新的媒体文件
      List<String> newFilenames = [];
      if (temporaryMediaPaths.isNotEmpty) {
        newFilenames = await _uploadNewMediaFiles();
        mediaFilenames.addAll(newFilenames);
      }

      // 创建更新后的反馈模型
      final updatedFeedback = feedback.copyWith(
        id: feedback.id,
        serviceRating: serviceRating.value,
        repairEfficiencyRating: repairEfficiencyRating.value,
        transparencyRating: transparencyRating.value,
        overallExperienceRating: overallExperienceRating.value,
        comment: comment.value,
        mediaFilenames: mediaFilenames,
        updatedAt: DateTime.now(),
        status: FeedbackStatus.submitted,
        editRemaining: feedback.editRemaining - 1,
      );

      // 更新现有反馈
      await _feedbackRepository.updateFeedback(updatedFeedback);

      // 清理所有临时文件
      await _cleanUpAllTemporaryFiles();

      // 清空要删除的文件列表
      _filesToDelete.clear();

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
    } catch (e, stackTrace) {
      // Close loading dialog
      Get.back();

      // 详细的错误日志
      print('=== DETAILED ERROR INFORMATION ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      print('=== END ERROR INFORMATION ===');

      String errorMessage = _getErrorMessage(e);
      Get.snackbar('Error', errorMessage, backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  /// 删除标记要删除的文件
  Future<void> _deleteMarkedFiles() async {
    for (String filename in _filesToDelete) {
      try {
        await _feedbackRepository.deleteMediaFromStorage(filename);
        print('Successfully deleted file from storage: $filename');
      } catch (e) {
        print('Failed to delete file $filename: $e');
        // 即使删除失败也继续，不要阻塞整个流程
      }
    }
  }

  /// 只上传新的媒体文件
  Future<List<String>> _uploadNewMediaFiles() async {
    List<String> uploadedFilenames = [];

    for (String tempPath in temporaryMediaPaths) {
      try {
        final String filename = tempPath.split('/').last;

        // 检查是否是已存在的文件（避免重复上传）
        final bool isExistingFile = feedback.mediaFilenames.contains(filename);
        if (!isExistingFile) {
          final File tempFile = File(tempPath);
          final String extension = tempPath.split('.').last.toLowerCase();
          final bool isVideo = ['mp4', 'mov'].contains(extension);

          // Generate unique filename with UUID
          final String uuid = _uuid.v4();
          String newFilename;

          if (isVideo) {
            newFilename = '$uuid.mp4';
          } else {
            newFilename = '$uuid.webp';
          }

          // Upload file
          final String uploadedFilename = await _feedbackRepository
              .uploadMediaToStorage(tempFile, newFilename);
          uploadedFilenames.add(uploadedFilename);
        }
      } catch (e) {
        print('Error uploading media file $tempPath: $e');
      }
    }

    return uploadedFilenames;
  }

  /// 清理所有临时文件
  Future<void> _cleanUpAllTemporaryFiles() async {
    for (String tempPath in temporaryMediaPaths) {
      try {
        final File tempFile = File(tempPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        print('Error cleaning up temporary file: $e');
      }
    }
    temporaryMediaPaths.clear();
  }

  // 根据错误类型提供具体的错误信息
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied. Please check your permissions.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'not-found':
          return 'Resource not found. Please try again.';
        default:
          return 'Firebase error: ${error.message}';
      }
    } else if (error is FileSystemException) {
      return 'File system error: ${error.message}. Please check storage permissions.';
    } else if (error is PlatformException) {
      return 'Platform error: ${error.message}';
    } else if (error is FormatException) {
      return 'Data format error: ${error.message}';
    } else if (error is StateError) {
      return 'Application error: ${error.message}';
    } else if (error.toString().contains('LateInitializationError')) {
      return 'Initialization error. Please restart the app.';
    } else if (error.toString().contains('permission')) {
      return 'Permission denied. Please grant the required permissions.';
    } else if (error.toString().contains('network')) {
      return 'Network connection failed. Please check your internet connection.';
    } else {
      return 'Something went wrong. Please try again. Error: ${error.toString()}';
    }
  }

  // Getters
  int get remainingMediaSlots => maxMediaCount - temporaryMediaPaths.length;

  // Media preview methods - 使用临时路径
  void showMediaPreview(String filePath, int index) {
    String extension = filePath.split('.').last.toLowerCase();
    bool isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(extension);
    final File file = File(filePath);

    // 检查文件是否存在
    if (!file.existsSync()) {
      Get.snackbar(
        'Error',
        'File not found',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(20),
        child: SizedBox(
          width: Get.width * 0.9,
          height: Get.height * 0.7,
          child: Stack(
            children: [
              Center(
                child: isVideo
                    ? VideoPreview(file: file)
                    : InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 3.0,
                        child: Image.file(
                          file,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 50,
                              ),
                            );
                          },
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
                    child: Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ),
              if (isVideo)
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Video',
                      style: TextStyle(color: Colors.white, fontSize: 12),
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
