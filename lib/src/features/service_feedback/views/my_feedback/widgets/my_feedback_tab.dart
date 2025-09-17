// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:wms/src/features/service_feedback/controllers/my_service_feedback_controller.dart';
// import 'package:wms/src/features/service_feedback/models/service_feedback_model.dart';
//
// /// Tab widget showing user's submitted feedback with editing capabilities
// class MyFeedbackTab extends StatelessWidget {
//   const MyFeedbackTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MyServiceFeedbackController>();
//
//     return RefreshIndicator(
//       onRefresh: controller.refreshCurrentTab,
//       child: Obx(() {
//         if (controller.isLoadingMyFeedbacks.value) {
//           return _buildLoadingState();
//         }
//
//         if (controller.hasError.value) {
//           return _buildErrorState(controller);
//         }
//
//         if (controller.myFeedbacks.isEmpty) {
//           return _buildEmptyState();
//         }
//
//         return _buildFeedbacksList(controller);
//       }),
//     );
//   }
//
//   /// Build loading state widget
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(color: Colors.blue[600]),
//           SizedBox(height: 16),
//           Text(
//             'Loading your feedback...',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Build error state widget
//   Widget _buildErrorState(MyServiceFeedbackController controller) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.red[400],
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Unable to load feedback',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               controller.errorMessage.value,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: controller.loadMyFeedbacks,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[600],
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 'Retry',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Build empty state widget
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.star_outline,
//               size: 64,
//               color: Colors.grey[400],
//             ),
//             SizedBox(height: 16),
//             Text(
//               'No Feedback Yet',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Your submitted reviews will appear here.\nStart by reviewing your completed services.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 height: 1.4,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Build feedback list widget
//   Widget _buildFeedbacksList(MyServiceFeedbackController controller) {
//     return ListView.separated(
//       padding: EdgeInsets.all(16),
//       itemCount: controller.myFeedbacks.length,
//       separatorBuilder: (context, index) => SizedBox(height: 12),
//       itemBuilder: (context, index) {
//         final feedback = controller.myFeedbacks[index];
//         return MyFeedbackCard(feedback: feedback);
//       },
//     );
//   }
// }
//
// /// Individual feedback card for my feedback tab
// class MyFeedbackCard extends StatelessWidget {
//   final ServiceFeedbackModel feedback;
//
//   const MyFeedbackCard({
//     super.key,
//     required this.feedback,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MyServiceFeedbackController>();
//     final canEdit = controller.canFeedbackBeEdited(feedback);
//     final remainingEditTime = feedback.remainingTimeToEdit;
//
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () => controller.navigateToFeedbackDetails(feedback),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with rating and edit status
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.star,
//                         color: Colors.amber[600],
//                         size: 20,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         feedback.formattedAverageRating,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: _getRatingColor(feedback.averageRating),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           feedback.ratingCategory,
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (canEdit)
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.green[100],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.edit,
//                             size: 12,
//                             color: Colors.green[700],
//                           ),
//                           SizedBox(width: 4),
//                           Text(
//                             'Editable',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.green[700],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//               SizedBox(height: 12),
//
//               // Service ID and status
//               Row(
//                 children: [
//                   Text(
//                     'Service ID: ${feedback.serviceId}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                       fontFamily: 'monospace',
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(feedback.status),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       feedback.status.displayName,
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//
//               // Rating breakdown
//               _buildRatingBreakdown(feedback),
//               SizedBox(height: 12),
//
//               // Comment preview
//               if (feedback.hasComment) ...[
//                 Text(
//                   feedback.comment.length > 80
//                       ? '${feedback.comment.substring(0, 80)}...'
//                       : feedback.comment,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[700],
//                     height: 1.3,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//               ],
//
//               // Media and date info
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         feedback.formattedCreatedDate,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[500],
//                         ),
//                       ),
//                       if (feedback.hasMedia) ...[
//                         SizedBox(width: 12),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.attachment,
//                               size: 12,
//                               color: Colors.grey[500],
//                             ),
//                             SizedBox(width: 2),
//                             Text(
//                               '${feedback.mediaCount} file${feedback.mediaCount > 1 ? 's' : ''}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[500],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ],
//                   ),
//                   if (canEdit)
//                     Text(
//                       controller.formatRemainingTime(remainingEditTime),
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.orange[700],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                 ],
//               ),
//
//               // Staff reply indicator
//               if (feedback.staffReply.isNotEmpty) ...[
//                 SizedBox(height: 8),
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(6),
//                     border: Border.all(color: Colors.blue[200]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.reply,
//                         size: 14,
//                         color: Colors.blue[600],
//                       ),
//                       SizedBox(width: 6),
//                       Text(
//                         'Staff replied',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.blue[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Build rating breakdown with visual indicators
//   Widget _buildRatingBreakdown(ServiceFeedbackModel feedback) {
//     final ratings = feedback.getRatingBreakdown();
//
//     return Column(
//       children: ratings.entries.map((entry) {
//         return Padding(
//           padding: EdgeInsets.only(bottom: 4),
//           child: Row(
//             children: [
//               SizedBox(
//                 width: 100,
//                 child: Text(
//                   entry.key,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8),
//               Row(
//                 children: List.generate(5, (index) {
//                   return Icon(
//                     index < entry.value ? Icons.star : Icons.star_border,
//                     size: 14,
//                     color: index < entry.value
//                         ? Colors.amber[600]
//                         : Colors.grey[300],
//                   );
//                 }),
//               ),
//               SizedBox(width: 8),
//               Text(
//                 entry.value.toString(),
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[700],
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   /// Get color based on rating value
//   Color _getRatingColor(double rating) {
//     if (rating >= 4.0) return Colors.green[600]!;
//     if (rating >= 3.0) return Colors.orange[600]!;
//     return Colors.red[600]!;
//   }
//
//   /// Get color based on feedback status
//   Color _getStatusColor(FeedbackStatus status) {
//     switch (status) {
//       case FeedbackStatus.draft:
//         return Colors.grey[600]!;
//       case FeedbackStatus.submitted:
//         return Colors.blue[600]!;
//       case FeedbackStatus.reviewed:
//         return Colors.orange[600]!;
//       case FeedbackStatus.published:
//         return Colors.green[600]!;
//       case FeedbackStatus.archived:
//         return Colors.grey[400]!;
//     }
//   }
// }