import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';

class SDExpanded implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDExpanded(this.args, JsonViewRegistry registry) : data = JsonViewDataBuilder(registry) {
    final children = args['child'];
    if (children is Map<String, dynamic>) {
      data.fromMap(children);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: data.build(context),
    );
  }
}
