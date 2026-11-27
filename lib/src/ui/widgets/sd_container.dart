import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/decoder.dart';
import 'package:sd_widget/src/ui/widgets/parser.dart';
import 'package:sd_widget/src/ui/widgets/sd_common.dart';

class SDContainer implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDContainer(this.args, JsonViewRegistry registry) : data = childOf(args, registry);

  @override
  Widget build(BuildContext context) {
    final clip = args["clip"] == true;
    final color = args.containsKey("decoration") ? null : decodeColor(args["color"]);
    var decoration = decodeDecoration(args["decoration"]);
    // Container só recorta com decoration; a cor vira decoração nesse caso.
    if (clip && decoration == null) decoration = BoxDecoration(color: color);

    return Container(
      padding: decodeEdgeInsetsGeometry(args["padding"]),
      margin: decodeEdgeInsetsGeometry(args["margin"]),
      decoration: decoration,
      color: decoration == null ? color : null,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      alignment: decodeAlignment(args["alignment"]),
      height: parseDouble(args["height"]),
      width: parseDouble(args["width"]),
      child: data.build(context),
    );
  }
}
