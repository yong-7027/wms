import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/colors.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({
    super.key,
    required this.onReport,
  });

  final Function(String reason) onReport;

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? selectedReason;
  final TextEditingController _customReasonController = TextEditingController();

  final List<String> reportReasons = [
    'Inappropriate content',
    'Spam or fake review',
    'Offensive language',
    'Irrelevant to service',
    'False information',
    'Other',
  ];

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: TColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titlePadding: const EdgeInsets.all(20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actionsPadding: const EdgeInsets.all(20),
      title: Row(
        children: [
          const Icon(
            Icons.flag_outlined,
            color: TColors.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Report Review',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TColors.textPrimary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why are you reporting this review?',
              style: TextStyle(
                fontSize: 14,
                color: TColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Report reasons
            ...reportReasons.map((reason) {
              return RadioListTile<String>(
                value: reason,
                groupValue: selectedReason,
                onChanged: (value) {
                  setState(() {
                    selectedReason = value;
                  });
                },
                title: Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TColors.textPrimary,
                  ),
                ),
                activeColor: TColors.primary,
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),

            // Custom reason input
            if (selectedReason == 'Other') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customReasonController,
                decoration: InputDecoration(
                  hintText: 'Please specify the reason...',
                  hintStyle: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: TColors.borderPrimary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: TColors.borderPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: TColors.primary),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
            ],
          ],
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: TColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),

        // Report button
        ElevatedButton(
          onPressed: selectedReason != null ? _handleReport : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.error,
            foregroundColor: TColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Report',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _handleReport() {
    if (selectedReason == null) return;

    String finalReason = selectedReason!;

    if (selectedReason == 'Other' && _customReasonController.text.isNotEmpty) {
      finalReason = _customReasonController.text.trim();
    }

    if (finalReason.isEmpty || (selectedReason == 'Other' && _customReasonController.text.trim().isEmpty)) {
      // Show error for empty custom reason
      return;
    }

    Get.back();
    widget.onReport(finalReason);
  }
}