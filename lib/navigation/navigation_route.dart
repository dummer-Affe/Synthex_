import 'package:flutter/material.dart';

import '../view/live_interpreter/view/live_interpreter_view.dart';
import 'navigation_enums.dart';

class NavigationRoute {
  Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (NavigationEnums.deafult.normalValue(routeSettings.name)) {
      case NavigationEnums.deafult:
      case NavigationEnums.liveInterpreter:
        return MaterialPageRoute<void>(
          builder: (_) => const LiveInterpreterView(),
          settings: const RouteSettings(
            name: '/liveInterpreter',
          ),
        );
    }
  }
}
