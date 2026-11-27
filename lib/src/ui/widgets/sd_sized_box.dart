import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/parser.dart';
import 'package:sd_widget/src/ui/widgets/sd_common.dart';

class SDSizedBox implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder? data;

  SDSizedBox(this.args, [JsonViewRegistry? registry])
      : data = registry != null && args['child'] is Map ? childOf(args, registry) : null;

  @override
  Widget build(BuildContext context) {
    // Com filho: caixa de tamanho fixo (ausente = tamanho do filho).
    if (data != null) {
      return SizedBox(
        width: parseDouble(args['width']),
        height: parseDouble(args['height']),
        child: data!.build(context),
      );
    }

    // Sem filho: espaçador; eixo ausente vale 0.
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
