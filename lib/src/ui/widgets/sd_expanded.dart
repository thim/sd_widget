import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/sd_common.dart';

class SDExpanded implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDExpanded(this.args, JsonViewRegistry registry) : data = childOf(args, registry);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: parseInt(args['flex']) ?? 1,
      child: data.build(context),
    );
  }
}
