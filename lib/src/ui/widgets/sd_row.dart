import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/decoder.dart';

class SDRow implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDRow(this.args, JsonViewRegistry registry) : data = JsonViewDataBuilder(registry) {
    final children = args['children'];
    if (children is Iterable) {
      data.fromList(children);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: decodeCrossAxisAlignment(args["crossAxisAlignment"]) ?? CrossAxisAlignment.center,
      mainAxisAlignment: decodeMainAxisAlignment(args["mainAxisAlignment"]) ?? MainAxisAlignment.start,
      mainAxisSize: decodeMainAxisSize(args["mainAxisSize"]) ?? MainAxisSize.min,
      verticalDirection: decodeVerticalDirection(args["verticalDirection"]) ?? VerticalDirection.down,
      children: data.builds(context),
    );
  }
}
