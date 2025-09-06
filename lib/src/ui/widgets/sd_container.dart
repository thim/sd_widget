import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/decoder.dart';
import 'package:sd_widget/src/ui/widgets/parser.dart';

class SDContainer implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDContainer(this.args, JsonViewRegistry registry) : data = JsonViewDataBuilder(registry) {
    final children = args['child'];
    if (children is Map<String, dynamic>) {
      data.fromMap(children);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: decodeEdgeInsetsGeometry(args["padding"]),
      margin: decodeEdgeInsetsGeometry(args["margin"]),
      decoration: decodeDecoration(args["decoration"]),
      color: args.containsKey("decoration") ? null : decodeColor(args["color"]),
      alignment: decodeAlignment(args["alignment"]),
      height: parseDouble(args["height"]),
      width: parseDouble(args["width"]),
      child: data.build(context),
    );
  }
}
