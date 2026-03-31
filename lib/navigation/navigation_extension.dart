import 'package:provider/provider.dart';

import '../app_states/app_settings.dart';
import 'navigation_enums.dart';
import 'navigation_manager.dart';

extension NavigationEnumsExt on NavigationEnums {
  Future<void> navigateToPageClear({Object? data}) async {
    AppSettings.instance.pageStackCount = 1;
    AppSettings.instance.currentPage = rawValue;
    await AppSettings.instance.context!
        .read<NavigationService>()
        .navigateToPageClear(path: rawValue, data: data);
  }

  Future<Object?> navigateToPage({Object? data}) {
    AppSettings.instance.currentPage = rawValue;
    return AppSettings.instance.context!
        .read<NavigationService>()
        .navigateToPage(path: rawValue, data: data);
  }
}
