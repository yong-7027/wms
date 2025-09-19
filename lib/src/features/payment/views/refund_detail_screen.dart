import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/formatters/formatter.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/helpers/video_helper.dart';
import '../models/payment_transaction_model.dart';
import 'widgets/media_viewer_screen.dart';

class RefundDetailScreen extends StatelessWidget {
  final PaymentTransactionModel refund;

  const RefundDetailScreen({super.key, required this.refund});

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: darkMode ? TColors.dark : TColors.light,
      appBar: AppBar(
        title: Text(
          'Refund Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkMode ? TColors.white : TColors.dark,
          ),
        ),
        backgroundColor: darkMode ? TColors.dark : TColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: refund.refundStatusGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: refund.refundStatusColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    refund.refundStatusIcon,
                    color: TColors.white,
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (refund.refundStatus ?? 'processing').toUpperCase(),
                    style: const TextStyle(
                      color: TColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${refund.currency} ${refund.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: TColors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Refund Amount',
                    style: TextStyle(
                      color: TColors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Refund Information Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: darkMode ? TColors.black : TColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(darkMode ? 0.1 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Refund Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkMode ? TColors.white : TColors.dark,
                      ),
                    ),
                  ),
                  _buildDetailRow(
                    context,
                    'Refund ID',
                    refund.transactionId,
                    Icons.receipt_long,
                    darkMode,
                    copyable: true,
                  ),
                  if (refund.originalPaymentId != null)
                    _buildDetailRow(
                      context,
                      'Original Payment ID',
                      refund.originalPaymentId!,
                      Icons.payment,
                      darkMode,
                      copyable: true,
                    ),
                  _buildDetailRow(
                    context,
                    'Refund Amount',
                    '${refund.currency} ${refund.amount.toStringAsFixed(2)}',
                    Icons.attach_money,
                    darkMode,
                  ),
                  _buildDetailRow(
                    context,
                    'Payment Method',
                    refund.paymentMethod,
                    refund.paymentMethodIcon,
                    darkMode,
                  ),
                  _buildDetailRow(
                    context,
                    'Request Date',
                    TFormatter.formatFullDate(refund.transactionDateTime),
                    Icons.access_time,
                    darkMode,
                  ),
                  if (refund.updatedAt != null)
                    _buildDetailRow(
                      context,
                      'Last Updated',
                      TFormatter.formatFullDate(refund.updatedAt!),
                      Icons.update,
                      darkMode,
                    ),
                  _buildDetailRow(
                    context,
                    'Status',
                    refund.refundStatusText,
                    Icons.info,
                    darkMode,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Refund Reason Card
            if (refund.refundReason?.isNotEmpty == true)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: darkMode ? TColors.black : TColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(darkMode ? 0.1 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.message, color: TColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Refund Reason',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkMode ? TColors.white : TColors.dark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: darkMode ? TColors.darkerGrey.withOpacity(0.3) : TColors.lightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          refund.refundReason!,
                          style: TextStyle(
                            color: darkMode ? TColors.white : TColors.dark,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (refund.refundReason?.isNotEmpty == true)
              const SizedBox(height: 24),

            // Supporting Evidence Card
            if (refund.refundMedias?.isNotEmpty == true)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: darkMode ? TColors.black : TColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(darkMode ? 0.1 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.photo_library, color: TColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Supporting Evidence',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkMode ? TColors.white : TColors.dark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: refund.refundMedias!.length,
                        itemBuilder: (context, index) {
                          final mediaUrl = refund.refundMedias![index];
                          final isVideo = VideoHelper.isVideoFile(mediaUrl);

                          return GestureDetector(
                            onTap: () => _openMediaViewer(index),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: TColors.lightGrey,
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: isVideo
                                          ? Container(
                                        color: TColors.darkGrey,
                                        child: const Center(
                                          child: Icon(
                                            Icons.videocam,
                                            color: TColors.white,
                                            size: 32,
                                          ),
                                        ),
                                      )
                                          : CachedNetworkImage(
                                        imageUrl: mediaUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: TColors.lightGrey,
                                          child: const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: TColors.lightGrey,
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: TColors.darkGrey,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isVideo)
                                    const Center(
                                      child: Icon(
                                        Icons.play_circle_filled,
                                        color: TColors.white,
                                        size: 32,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

            if (refund.refundMedias?.isNotEmpty == true)
              const SizedBox(height: 24),

            // Status Information Card
            _buildStatusInfoCard(context, darkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      bool darkMode, {
        bool isLast = false,
        bool copyable = false,
      }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: TColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    color: darkMode ? TColors.grey : TColors.darkGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          color: darkMode ? TColors.white : TColors.dark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    if (copyable) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _copyToClipboard(context, value),
                        child: Icon(
                          Icons.copy,
                          color: TColors.primary,
                          size: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: darkMode ? TColors.dark : TColors.light,
            height: 1,
          ),
      ],
    );
  }

  Widget _buildStatusInfoCard(BuildContext context, bool darkMode) {
    final status = refund.refundStatus ?? 'processing';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: refund.refundStatusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: refund.refundStatusColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            refund.refundStatusIcon,
            color: refund.refundStatusColor,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            refund.statusTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: refund.refundStatusColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            refund.statusDescription,
            style: TextStyle(
              color: darkMode ? TColors.grey : TColors.darkGrey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openMediaViewer(int index) {
    Get.to(
          () => MediaViewerScreen(),
      arguments: {
        'mediaItems': refund.refundMedias!,
        'initialIndex': index,
        'isLocalFiles': false, // 标记为网络URL
      },
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: TColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}