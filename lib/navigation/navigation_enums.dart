import 'package:flutter/material.dart';

enum NavigationEnums {
  deafult,
  liveInterpreter,
}

extension NavigationConstantsValue on NavigationEnums {
  String get rawValue {
    switch (this) {
      case NavigationEnums.deafult:
        return '/deafult';
      case NavigationEnums.liveInterpreter:
        return '/liveInterpreter';
    }
  }

  NavigationEnums normalValue(String? val) {
    switch (val) {
      case '/':
      case null:
        return NavigationEnums.deafult;
      default:
        try {
          return NavigationEnums.values.byName(val.substring(1));
        } catch (_) {
          debugPrint('Unknown route: $val, navigating to default');
          return NavigationEnums.deafult;
        }
    }
  }
}
