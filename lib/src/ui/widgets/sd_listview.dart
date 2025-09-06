import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/decoder.dart';

class SDListView implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDListView(this.args, JsonViewRegistry registry) : data = JsonViewDataBuilder(registry) {
    final children = args['children'];

    if (children is Iterable) {
      data.fromList(children);
    }
  }

  @override
  Widget build(BuildContext context) {
    final axis = decodeAxis(args["axis"]) ?? Axis.horizontal;

    return LayoutBuilder(builder: (context, constraints) {
      final fraction = args["fraction"] ?? 0.9;
      final separator = args["separator"] ?? 8.0;
      return SizedBox(
        height: args["height"] ?? 150.0,
        child: ListView.separated(
          scrollDirection: axis,
          itemCount: data.length,
          padding: decodeEdgeInsetsGeometry(args["padding"]),
          itemBuilder: (context, index) {
            return SizedBox(
              width: constraints.maxWidth * fraction,
              child: data.build(context, index: index),
            );
          },
          separatorBuilder: (context, index) => SizedBox(
            width: separator,
            height: separator,
          ),
        ),
      );
    });
  }
}
