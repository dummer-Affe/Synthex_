import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/appearance.dart';

class AppSettings extends GetxController {
  static AppSettings get instance {
    if (Get.isRegistered<AppSettings>()) {
      return Get.find<AppSettings>();
    }

    return Get.put(AppSettings(), permanent: true);
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final Appearance appearance = Appearance.defaultAppearance();

  String? currentPage;
  int pageStackCount = 1;
  bool isIos = true;

  BuildContext? get context => navigatorKey.currentContext;
  bool get canPop => pageStackCount > 1;

  Future<void> init() async {}
}
