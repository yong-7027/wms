import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/helpers/video_helper.dart';
import '../controllers/refund_controller.dart';
import '../models/payment_transaction_model.dart';
import 'widgets/media_viewer_screen.dart';

class RefundRequestScreen extends StatelessWidget {
  const RefundRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RefundController());
    final PaymentTransactionModel transaction = Get.arguments;
    controller.setOriginalPayment(transaction);

    return Scaffold(
      appBar: AppBar(
        title: Text('Refund Request', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Info Section
              _PaymentInfoCard(transaction: transaction),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Media Upload Section
              _MediaUploadSection(),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Refund Reason Section
              _RefundReasonSection(),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Upload Progress Section
              // Obx(() => controller.isUploading.value
              //     ? _UploadProgressSection()
              //     : const SizedBox.shrink()),

              // Submit Button
              _SubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentInfoCard extends StatelessWidget {
  const _PaymentInfoCard({required this.transaction});

  final PaymentTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        color: dark ? TColors.dark : TColors.light,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.receipt_item_bold, color: dark ? TColors.white : TColors.dark),
              const SizedBox(width: TSizes.spaceBtwItems),
              Text(
                'Payment Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          _InfoRow('Transaction ID', transaction.transactionId),
          _InfoRow('Amount', '${transaction.currency.toUpperCase()} ${transaction.displayAmount.toStringAsFixed(2)}'),
          _InfoRow('Payment Method', transaction.paymentMethod),
          _InfoRow('Date', THelperFunctions.getFormattedDate(transaction.transactionDateTime)),
        ],
      ),
    );
  }

  Widget _InfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: TColors.darkGrey)),
        ],
      ),
    );
  }
}

class _MediaUploadSection extends GetView<RefundController> {
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.camera_bold, color: dark ? TColors.white : TColors.dark),
            const SizedBox(width: TSizes.spaceBtwItems),
            Text(
              'Supporting Evidence',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              ' *',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: TColors.error),
            ),
          ],
        ),
        const SizedBox(height: TSizes.xs),
        Text(
          'Please provide at least one image or video as evidence for your refund request. Maximum 5 files, each under 10MB.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TColors.darkGrey),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Upload Options
        Row(
          children: [
            Expanded(
              child: _UploadOptionCard(
                icon: Iconsax.gallery_bold,
                title: 'From Gallery',
                onTap: () => controller.pickMediaFromGallery(),
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: _UploadOptionCard(
                icon: Iconsax.camera_bold,
                title: 'Take Photo',
                onTap: () => controller.takePhoto(),
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: _UploadOptionCard(
                icon: Iconsax.video_bold,
                title: 'Record Video',
                onTap: () => controller.recordVideo(),
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Selected Media Display
        Obx(() => controller.selectedFiles.isEmpty
            ? _EmptyMediaState()
            : _MediaPreviewGrid()),
      ],
    );
  }

  Widget _UploadOptionCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return GetBuilder<RefundController>(
        builder: (controller) {
          final dark = THelperFunctions.isDarkMode(Get.context!);
          final isDisabled = controller.selectedFiles.length >= 5 || controller.isUploading.value;

          return GestureDetector(
            onTap: isDisabled ? null : onTap,
            child: Container(
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                color: isDisabled
                    ? (dark ? TColors.darkerGrey : TColors.grey)
                    : (dark ? TColors.darkGrey : TColors.lightGrey),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isDisabled ? TColors.darkGrey : TColors.primary,
                  ),
                  const SizedBox(height: TSizes.xs),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDisabled ? TColors.darkGrey : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Widget _EmptyMediaState() {
    final dark = THelperFunctions.isDarkMode(Get.context!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.xl),
      decoration: BoxDecoration(
        border: Border.all(color: TColors.error, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        color: dark ? TColors.dark.withOpacity(0.1) : TColors.light.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Icon(Iconsax.gallery_slash_bold, size: 48, color: TColors.error),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'No evidence uploaded',
            style: Get.textTheme.titleMedium?.copyWith(color: TColors.error),
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            'Please upload at least one image or video',
            style: Get.textTheme.bodySmall?.copyWith(color: TColors.darkGrey),
          ),
        ],
      ),
    );
  }

  Widget _MediaPreviewGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: TSizes.spaceBtwItems,
        mainAxisSpacing: TSizes.spaceBtwItems,
      ),
      itemCount: controller.selectedFiles.length,
      itemBuilder: (context, index) {
        return _MediaPreviewCard(index: index);
      },
    );
  }

  Widget _MediaPreviewCard({required int index}) {
    return GetBuilder<RefundController>(
        builder: (controller) {
          final file = controller.selectedFiles[index];
          final isVideo = VideoHelper.isVideoFile(file.path);

          return Stack(
            children: [
              GestureDetector(
                onTap: () => _openMediaViewer(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: TColors.lightGrey,
                    child: isVideo
                        ? _VideoThumbnail(file: file)
                        : Image.file(
                      file,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (isVideo)
                GestureDetector(
                  onTap: () => _openMediaViewer(index),
                  child: const Center(
                    child: Icon(
                      Iconsax.play_circle_bold,
                      color: TColors.white,
                      size: 32,
                    ),
                  ),
                ),
              // Remove Button (disabled during upload)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: controller.isUploading.value ? null : () => controller.removeFile(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: controller.isUploading.value ? TColors.darkGrey : TColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.close_circle_bold,
                      color: TColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
    );
  }

  void _openMediaViewer(int index) async {
    final result = await Get.to(
          () => const MediaViewerScreen(),
      arguments: {
        'mediaItems': controller.selectedFiles.toList(),
        'initialIndex': index,
        'isLocalFiles': true, // 标记为本地文件
      },
    );

    if (result != null && result['remainingFiles'] != null) {
      final remainingFiles = result['remainingFiles'] as List<File>;
      controller.selectedFiles.clear();
      controller.selectedFiles.addAll(remainingFiles);
    }
  }

  Widget _VideoThumbnail({required File file}) {
    return FutureBuilder<VideoPlayerController>(
      future: _initializeVideoController(file),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.value.isInitialized) {
          return AspectRatio(
            aspectRatio: snapshot.data!.value.aspectRatio,
            child: VideoPlayer(snapshot.data!),
          );
        }
        return Container(
          color: TColors.darkGrey,
          child: const Center(
            child: Icon(Iconsax.video_bold, color: TColors.white, size: 32),
          ),
        );
      },
    );
  }

  Future<VideoPlayerController> _initializeVideoController(File file) async {
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    return controller;
  }
}

class _RefundReasonSection extends GetView<RefundController> {
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.message_text_bold, color: dark ? TColors.white : TColors.dark),
            const SizedBox(width: TSizes.spaceBtwItems),
            Text(
              'Refund Reason',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              ' *',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: TColors.error),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        TextField(
          controller: controller.reasonController,
          maxLines: 6,
          maxLength: 300,
          enabled: !controller.isUploading.value, // Disable during upload
          onChanged: (value) => controller.updateCharacterCount(),
          decoration: InputDecoration(
            hintText: 'Please explain the reason for your refund request in detail...',
            hintStyle: TextStyle(color: TColors.darkGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              borderSide: BorderSide(color: TColors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              borderSide: BorderSide(color: TColors.primary),
            ),
            counterText: '',
          ),
        ),

        // Custom character counter
        Obx(() => Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: TSizes.xs),
            child: Text(
              '${controller.characterCount.value}/300',
              style: TextStyle(
                fontSize: 12,
                color: controller.characterCount.value > 300 ? TColors.error : TColors.darkGrey,
              ),
            ),
          ),
        )),
      ],
    );
  }
}

class _SubmitButton extends GetView<RefundController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: controller.canSubmit.value && !controller.isLoading.value && !controller.isUploading.value
            ? controller.submitRefundRequest
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          foregroundColor: TColors.white,
          padding: const EdgeInsets.symmetric(vertical: TSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          ),
        ),
        child: controller.isLoading.value || controller.isUploading.value
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(TColors.white),
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            Text(
              'Submitting...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        )
            : const Text(
          'Submit Refund Request',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      )),
    );
  }
}