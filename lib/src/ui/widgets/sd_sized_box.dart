import 'package:flutter/material.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/parser.dart';

class SDSizedBox implements BaseJsonWidget {
  final Map args;

  SDSizedBox(this.args);

  @override
  Widget build(BuildContext context) {
    final w = args['width'] ?? 0.0;
    final h = args['height'] ?? 0.0;

    if (w == 0.0 && h == 0.0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: parseDouble(w),
      height: parseDouble(h),
    );
  }
}
