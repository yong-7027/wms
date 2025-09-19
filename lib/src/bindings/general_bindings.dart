import 'package:get/get.dart';

import '../services/deep_link_service.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(DeepLinkService());
  }
}