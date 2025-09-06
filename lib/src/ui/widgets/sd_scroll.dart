import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/decoder.dart';

class SDScroll implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDScroll(this.args, JsonViewRegistry registry) : data = JsonViewDataBuilder(registry) {
    final children = args['children'];
    if (children is Iterable) {
      data.fromList(children);
    }
  }

  @override
  Widget build(BuildContext context) {
    final axis = decodeAxis(args["axis"]) ?? Axis.horizontal;

    return SingleChildScrollView(
        padding: decodeEdgeInsetsGeometry(args["padding"]),
        controller: ScrollController(),
        scrollDirection: axis,
        child: axis == Axis.horizontal
            ? Row(
                children: data.builds(context),
              )
            : Column(
                children: data.builds(context),
              ));
  }
}
