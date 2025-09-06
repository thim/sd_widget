import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/decoder.dart';

class SDColumn implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDColumn(this.args, JsonViewRegistry registry) : data = JsonViewDataBuilder(registry) {
    final children = args['children'];
    if (children is Iterable) {
      data.fromList(children, itemData: args['item_data']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: decodeCrossAxisAlignment(args["crossAxisAlignment"]) ?? CrossAxisAlignment.center,
      mainAxisAlignment: decodeMainAxisAlignment(args["mainAxisAlignment"]) ?? MainAxisAlignment.start,
      mainAxisSize: decodeMainAxisSize(args["mainAxisSize"]) ?? MainAxisSize.min,
      verticalDirection: decodeVerticalDirection(args["verticalDirection"]) ?? VerticalDirection.down,
      children: data.builds(context),
    );
  }
}
