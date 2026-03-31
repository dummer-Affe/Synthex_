import 'package:flutter/widgets.dart';

extension IntSpacingExtension on int {
  Widget get spacerV => SizedBox(height: toDouble());
  Widget get spacerH => SizedBox(width: toDouble());
}

extension DoubleSpacingExtension on double {
  Widget get spacerV => SizedBox(height: this);
  Widget get spacerH => SizedBox(width: this);
}
