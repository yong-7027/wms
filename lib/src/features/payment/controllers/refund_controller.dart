import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path/path.dart' as path;

import '../../../common/loaders/loaders.dart';
import '../../../data/repository/payment/invoice_repository.dart';
import '../../../data/repository/payment/payment_repository.dart';
import '../../../utils/helpers/network_manager.dart';
import '../models/payment_transaction_model.dart';
import '../views/payment_history_screen.dart';
import 'payment_history_controller.dart';

class RefundController extends GetxController {
  static RefundController get instance => Get.find();

  // Dependencies
  final PaymentRepository _paymentRepository = Get.put(PaymentRepository());
  final InvoiceRepository _invoiceRepository = Get.put(InvoiceRepository());
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://workshop-management-syst-b9cec.firebasestorage.app',
  );

  // Form controllers
  final reasonController = TextEditingController();

  // Observables
  var selectedFiles = <File>[].obs;
  var characterCount = 0.obs;
  var isLoading = false.obs;
  var canSubmit = false.obs;
  var isUploading = false.obs;

  // Original payment transaction
  PaymentTransactionModel? originalPayment;

  // Constants
  static const int maxFiles = 5;
  static const int maxImageSizeMB = 5;
  static const int maxCharacters = 300;
  static const int minCharacters = 10;

  // Media compression settings
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 85;
  static const double maxVideoSizeMB = 20;

  @override
  void onInit() {
    super.onInit();
    reasonController.addListener(_validateForm);
  }

  @override
  void onClose() {
    reasonController.dispose();
    VideoCompress.cancelCompression();
    super.onClose();
  }

  /// Set the original payment transaction
  void setOriginalPayment(PaymentTransactionModel payment) {
    originalPayment = payment;
    _validateEligibility();
  }

  /// Validate refund eligibility
  void _validateEligibility() {
    if (originalPayment == null) return;

    // Check if payment is eligible for refund (within 2 weeks and succeeded)
    if (originalPayment!.status != 'succeeded') {
      TLoaders.errorSnackBar(
        title: 'Refund Not Available',
        message: 'Only successful payments are eligible for refunds.',
      );
      Get.back();
      return;
    }

    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    if (originalPayment!.transactionDateTime.isBefore(twoWeeksAgo)) {
      TLoaders.errorSnackBar(
        title: 'Refund Window Expired',
        message: 'Refund requests must be submitted within 14 days of payment.',
      );
      Get.back();
      return;
    }

    // Check if there's already a pending refund
    _checkPendingRefund();
  }

  /// Check for pending refund requests
  Future<void> _checkPendingRefund() async {
    try {
      final hasPending = await _paymentRepository.hasActiveRefundRequest(originalPayment!.transactionId);

      if (hasPending) {
        TLoaders.warningSnackBar(
          title: 'Refund Already Requested',
          message: 'You already have a pending refund request for this payment.',
        );
        Get.back();
      }
    } catch (e) {
      print('Error checking pending refund: $e');
    }
  }

  /// Update character count and validate form
  void updateCharacterCount() {
    characterCount.value = reasonController.text.length;
    _validateForm();
  }

  /// Validate form inputs
  void _validateForm() {
    // Check refund reason length
    final hasValidReason = reasonController.text.trim().length >= minCharacters &&
        reasonController.text.length <= maxCharacters;

    // Check if at least one media file is uploaded
    final hasMedia = selectedFiles.isNotEmpty;

    // Update button state: must satisfy valid reason + media files + not loading/uploading
    canSubmit.value = hasValidReason && hasMedia && !isLoading.value && !isUploading.value;
  }

  /// Pick media from gallery (images and videos)
  Future<void> pickMediaFromGallery() async {
    try {
      if (selectedFiles.length >= maxFiles) {
        TLoaders.warningSnackBar(
          title: 'Limit Reached',
          message: 'You can only upload up to $maxFiles files.',
        );
        return;
      }

      final picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultipleMedia(
        limit: maxFiles - selectedFiles.length,
      );

      await _processSelectedFiles(pickedFiles);
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to pick files from gallery.',
      );
    }
  }

  /// Take a photo using camera
  Future<void> takePhoto() async {
    try {
      if (selectedFiles.length >= maxFiles) {
        TLoaders.warningSnackBar(
          title: 'Limit Reached',
          message: 'You can only upload up to $maxFiles files.',
        );
        return;
      }

      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: imageQuality,
      );

      if (photo != null) {
        await _processSelectedFiles([photo]);
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to take photo.',
      );
    }
  }

  /// Record a video using camera
  Future<void> recordVideo() async {
    try {
      if (selectedFiles.length >= maxFiles) {
        TLoaders.warningSnackBar(
          title: 'Limit Reached',
          message: 'You can only upload up to $maxFiles files.',
        );
        return;
      }

      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        await _processSelectedFiles([video]);
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to record video.',
      );
    }
  }

  /// Process selected files (validation, compression and conversion)
  Future<void> _processSelectedFiles(List<XFile> pickedFiles) async {
    final allowedMimeTypes = ['image/', 'video/'];

    for (final pickedFile in pickedFiles) {
      try {
        // 1. Check file format
        final mimeType = lookupMimeType(pickedFile.path);
        if (mimeType == null ||
            !allowedMimeTypes.any((allowed) => mimeType.startsWith(allowed))) {
          TLoaders.warningSnackBar(
            title: 'Invalid File Type',
            message: 'File "${pickedFile.name}" is not a supported image or video format.',
          );
          continue;
        }

        // 2. Check file size BEFORE compression with type-specific limits
        final originalFile = File(pickedFile.path);
        final originalSizeInMB = await originalFile.length() / (1024 * 1024);

        // 根据文件类型使用不同的限制
        final maxAllowedSize = mimeType.startsWith('video/')
            ? maxVideoSizeMB
            : maxImageSizeMB;

        if (originalSizeInMB > maxAllowedSize) {
          TLoaders.warningSnackBar(
            title: 'File Too Large',
            message: '${mimeType.startsWith('video/') ? 'Video' : 'Image'} '
                '"${pickedFile.name}" is ${originalSizeInMB.toStringAsFixed(1)}MB. '
                'Maximum size is ${maxAllowedSize}MB.',
          );
          continue;
        }

        // 3. Process file based on type
        File processedFile = originalFile;

        if (mimeType.startsWith('image/')) {
          // 图片：大于2MB才压缩
          if (originalSizeInMB > 2) {
            processedFile = await _compressImage(originalFile);
          }
        } else if (mimeType.startsWith('video/')) {
          // 视频：大于10MB才压缩（如果有视频压缩功能）
          if (originalSizeInMB > 10) {
            processedFile = await _compressVideo(originalFile);
          }
        }

        // 4. 压缩后再次用相同限制检查
        final finalSizeInMB = await processedFile.length() / (1024 * 1024);
        if (finalSizeInMB > maxAllowedSize) {
          TLoaders.warningSnackBar(
            title: 'Compression Failed',
            message: 'File could not be compressed enough. '
                'Please choose a smaller ${mimeType.startsWith('video/') ? 'video' : 'image'}.',
          );

          if (processedFile.path != originalFile.path) {
            try { await processedFile.delete(); } catch (e) { /* ignore */ }
          }
          continue;
        }

        // 5. Add to list if not duplicate
        if (!selectedFiles.any((f) => f.path == processedFile.path)) {
          selectedFiles.add(processedFile);
        }

      } catch (e) {
        TLoaders.warningSnackBar(
          title: 'Processing Error',
          message: 'Failed to process file "${pickedFile.name}". Please try again.',
        );
        print('Error processing file: $e');
      }
    }

    _validateForm();
  }

  /// Compress image file
  Future<File> _compressImage(File imageFile) async {
    try {
      final String targetPath = path.join(
        path.dirname(imageFile.path),
        'compressed_${path.basename(imageFile.path)}',
      );

      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: imageQuality,
        minWidth: 800,
        minHeight: 600,
        format: CompressFormat.jpeg, // Standardize to JPEG
      );

      if (compressedFile != null) {
        return File(compressedFile.path);
      } else {
        return imageFile; // Return original if compression fails
      }
    } catch (e) {
      print('Image compression error: $e');
      return imageFile; // Return original if compression fails
    }
  }

  /// Compress video file
  Future<File> _compressVideo(File videoFile) async {
    try {
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (mediaInfo != null && mediaInfo.file != null) {
        return mediaInfo.file!;
      } else {
        return videoFile; // Return original if compression fails
      }
    } catch (e) {
      print('Video compression error: $e');
      return videoFile; // Return original if compression fails
    }
  }

  /// Upload file to Firebase Storage
  Future<String> _uploadFileToStorage(File file, String fileName) async {
    try {
      final String storagePath = 'refund_media/$fileName';
      final Reference ref = _storage.ref().child(storagePath);

      final TaskSnapshot snapshot = await ref.putFile(file);
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      throw 'Failed to upload file: $e';
    }
  }

  /// Generate unique filename
  String _generateFileName(File file, String transactionId) {
    final extension = path.extension(file.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomId = DateTime.now().microsecondsSinceEpoch % 10000;

    return '${transactionId}_${timestamp}_$randomId$extension';
  }

  /// Remove a file from selected files
  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      final file = selectedFiles[index];
      selectedFiles.removeAt(index);

      // Clean up compressed file if it's different from original
      try {
        if (file.path.contains('compressed_')) {
          file.delete();
        }
      } catch (e) {
        // Ignore cleanup errors
      }

      _validateForm();
    }
  }

  /// Submit refund request
  Future<void> submitRefundRequest() async {
    try {
      // Check internet connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TLoaders.errorSnackBar(
          title: 'No Internet',
          message: 'Please check your internet connection and try again.',
        );
        return;
      }

      // Validate original payment
      if (originalPayment == null) {
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Original payment information not found.',
        );
        return;
      }

      // Double-check eligibility before submitting
      final now = DateTime.now();
      final twoWeeksAgo = now.subtract(const Duration(days: 14));

      if (originalPayment!.transactionDateTime.isBefore(twoWeeksAgo)) {
        TLoaders.errorSnackBar(
          title: 'Refund Window Expired',
          message: 'This payment is no longer eligible for refund (14-day limit exceeded).',
        );
        return;
      }

      // Check for existing pending refunds
      final hasPending = await _paymentRepository.hasActiveRefundRequest(originalPayment!.transactionId);
      if (hasPending) {
        TLoaders.errorSnackBar(
          title: 'Duplicate Request',
          message: 'You already have a pending refund request for this payment.',
        );
        return;
      }

      // Start loading and uploading
      isLoading.value = true;
      isUploading.value = true;
      _validateForm();

      // Generate refund transaction ID
      final refundTransactionId = 'refund_${DateTime.now().millisecondsSinceEpoch}';

      // Upload media files to Firebase Storage
      final List<String> uploadedMediaUrls = [];

      if (selectedFiles.isNotEmpty) {
        for (int i = 0; i < selectedFiles.length; i++) {
          final file = selectedFiles[i];
          final fileName = _generateFileName(file, refundTransactionId);

          try {
            // 返回上传后文件的 下载 URL
            final downloadUrl = await _uploadFileToStorage(file, fileName);
            // 将下载链接加入 uploadedMediaUrls 数组，用于后续保存到数据库或前端展示
            uploadedMediaUrls.add(downloadUrl);
          } catch (e) {
            // If any upload fails, clean up and show error
            isLoading.value = false;
            isUploading.value = false;
            _validateForm();

            TLoaders.errorSnackBar(
              title: 'Upload Failed',
              message: 'Failed to upload media files. Please try again.',
            );
            return;
          }
        }
      }

      // Create refund transaction
      final refundTransaction = PaymentTransactionModel(
        transactionId: refundTransactionId,
        type: 'refund',
        originalPaymentId: originalPayment!.transactionId,
        invoiceId: originalPayment!.invoiceId,
        amount: originalPayment!.amount,
        currency: originalPayment!.currency,
        paymentMethod: originalPayment!.paymentMethod,
        transactionDateTime: DateTime.now(),
        status: 'pending', // Initial status for refund requests
        refundReason: reasonController.text.trim(),
        refundMedias: uploadedMediaUrls, // Store Firebase Storage URLs
        refundStatus: 'processing',
        updatedAt: DateTime.now(),
      );

      // Save refund transaction to database
      await _paymentRepository.createRefundRequest(refundTransaction);

      // Stop loading and uploading
      isLoading.value = false;
      isUploading.value = false;

      // Clean up temporary compressed files
      await _cleanupTempFiles();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Success!',
        message: 'Your refund request has been submitted successfully. We will review it within 3-5 business days.',
      );

      // Navigate back
      Get.off(PaymentHistoryScreen());

    } catch (e) {
      // Stop loading and uploading
      isLoading.value = false;
      isUploading.value = false;
      _validateForm();

      // Show error message
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to submit refund request. Please try again.',
      );

      print('Submit refund error: $e');
    }
  }

  /// Clean up temporary compressed files
  Future<void> _cleanupTempFiles() async {
    for (final file in selectedFiles) {
      try {
        if (file.path.contains('compressed_')) {
          await file.delete();
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    }
  }

  /// Cancel refund request
  Future<void> cancelRefundRequest(String refundTransactionId) async {
    try {
      isLoading.value = true;

      // Check internet connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TLoaders.errorSnackBar(
          title: 'No Internet',
          message: 'Please check your internet connection and try again.',
        );
        return;
      }

      // Cancel the refund request
      await _paymentRepository.cancelRefundRequest(refundTransactionId);

      // Stop loading
      isLoading.value = false;

      // Show success message
      TLoaders.successSnackBar(
        title: 'Cancelled',
        message: 'Your refund request has been cancelled successfully.',
      );

      // Refresh the parent screen data if needed
      if (Get.isRegistered<PaymentHistoryController>()) {
        Get.find<PaymentHistoryController>().refreshData();
      }

    } catch (e) {
      isLoading.value = false;

      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to cancel refund request. Please try again.',
      );
    }
  }

  /// Clear all form data
  void clearForm() {
    reasonController.clear();

    // Clean up files before clearing
    for (final file in selectedFiles) {
      try {
        if (file.path.contains('compressed_')) {
          file.delete();
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    }

    selectedFiles.clear();
    characterCount.value = 0;
    _validateForm();
  }

  /// Get file size in MB
  Future<double> getFileSizeMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Get total size of all selected files
  Future<double> getTotalFileSizeMB() async {
    double totalSize = 0.0;
    for (final file in selectedFiles) {
      totalSize += await getFileSizeMB(file);
    }
    return totalSize;
  }

  /// Delete media from Firebase Storage
  Future<void> deleteMediaFromStorage(String downloadUrl) async {
    try {
      final Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting media: $e');
      // Don't throw error as this might be called during cleanup
    }
  }
}