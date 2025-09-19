// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:wms/src/features/service_feedback/controllers/my_service_feedback_controller.dart';
// import 'widgets/to_feedback_tab.dart';
// import 'widgets/my_feedback_tab.dart';
//
// /// Main screen for managing service feedback with two tabs
// class MyServiceFeedbackScreen extends StatelessWidget {
//   const MyServiceFeedbackScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(MyServiceFeedbackController());
//
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           'My Service Feedback',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(60),
//           child: Container(
//             color: Colors.white,
//             child: Obx(() => TabBar(
//               controller: controller.tabController,
//               labelColor: Colors.blue[600],
//               unselectedLabelColor: Colors.grey[600],
//               indicatorColor: Colors.blue[600],
//               indicatorWeight: 3,
//               labelStyle: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//               unselectedLabelStyle: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//               tabs: [
//                 Tab(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text('To Feedback'),
//                       if (controller.toFeedbackCount > 0) ...[
//                         SizedBox(width: 8),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             '${controller.toFeedbackCount}',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 Tab(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text('My Feedback'),
//                       if (controller.myFeedbackCount > 0) ...[
//                         SizedBox(width: 8),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.blue[600],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             '${controller.myFeedbackCount}',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             )),
//           ),
//         ),
//       ),
//       body: TabBarView(
//         controller: controller.tabController,
//         children: [
//           ToFeedbackTab(),
//           MyFeedbackTab(),
//         ],
//       ),
//     );
//   }
// }