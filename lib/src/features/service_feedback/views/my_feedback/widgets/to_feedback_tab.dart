// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:wms/src/features/service_feedback/controllers/my_service_feedback_controller.dart';
// import 'package:wms/src/features/service_feedback/models/service_model.dart';
//
// /// Tab widget showing services that require feedback within 7 days
// class ToFeedbackTab extends StatelessWidget {
//   const ToFeedbackTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MyServiceFeedbackController>();
//
//     return RefreshIndicator(
//       onRefresh: controller.refreshCurrentTab,
//       child: Obx(() {
//         if (controller.isLoadingToFeedback.value) {
//           return _buildLoadingState();
//         }
//
//         if (controller.hasError.value) {
//           return _buildErrorState(controller);
//         }
//
//         if (controller.toFeedbackServices.isEmpty) {
//           return _buildEmptyState();
//         }
//
//         return _buildServicesList(controller);
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
//             'Loading services...',
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
//               'Oops! Something went wrong',
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
//               onPressed: controller.loadToFeedbackServices,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[600],
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 'Try Again',
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
//               Icons.rate_review_outlined,
//               size: 64,
//               color: Colors.grey[400],
//             ),
//             SizedBox(height: 16),
//             Text(
//               'All Caught Up!',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'You have no services awaiting feedback.\nCompleted services will appear here within 7 days.',
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
//   /// Build services list widget
//   Widget _buildServicesList(MyServiceFeedbackController controller) {
//     return ListView.separated(
//       padding: EdgeInsets.all(16),
//       itemCount: controller.toFeedbackServices.length,
//       separatorBuilder: (context, index) => SizedBox(height: 12),
//       itemBuilder: (context, index) {
//         final service = controller.toFeedbackServices[index];
//         return ToFeedbackServiceCard(service: service);
//       },
//     );
//   }
// }
//
// /// Individual service card for to feedback tab
// class ToFeedbackServiceCard extends StatelessWidget {
//   final ServiceModel service;
//
//   const ToFeedbackServiceCard({
//     super.key,
//     required this.service,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MyServiceFeedbackController>();
//     final remainingTime = service.remainingTimeToRate;
//     final canReview = controller.canServiceBeReviewed(service);
//
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () => controller.navigateToServiceDetails(service),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with service type and remaining time
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     service.serviceType,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: canReview ? Colors.orange[100] : Colors.red[100],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       controller.formatRemainingTime(remainingTime),
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: canReview ? Colors.orange[800] : Colors.red[800],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//
//               // Car information
//               Row(
//                 children: [
//                   Icon(Icons.directions_car, size: 16, color: Colors.grey[600]),
//                   SizedBox(width: 6),
//                   Text(
//                     '${service.carName} ${service.carModel}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Text(
//                     service.carPlateNo,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 8),
//
//               // Service details
//               Text(
//                 service.serviceDesc,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                   height: 1.3,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               SizedBox(height: 12),
//
//               // Service date and cost
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Completed',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[500],
//                         ),
//                       ),
//                       Text(
//                         service.formattedCompletedDate,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Text(
//                     service.formattedTotalCost,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.green[600],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//
//               // Action button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: canReview
//                       ? () => controller.navigateToMakeFeedback(service)
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: canReview ? Colors.blue[600] : Colors.grey[400],
//                     padding: EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     elevation: canReview ? 2 : 0,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.rate_review,
//                         size: 18,
//                         color: Colors.white,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         canReview ? 'Write Review' : 'Time Expired',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }