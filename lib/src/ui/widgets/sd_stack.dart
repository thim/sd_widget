import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/decoder.dart';
import 'package:sd_widget/src/ui/widgets/parser.dart';
import 'package:sd_widget/src/ui/widgets/sd_common.dart';

/// Frame sem auto-layout: filhos posicionados livremente com `positioned`.
class SDStack implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDStack(this.args, JsonViewRegistry registry) : data = childrenOf(args, registry);

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      alignment: decodeAlignment(args['alignment']) ?? Alignment.topLeft,
      clipBehavior: args['clip'] == false ? Clip.none : Clip.hardEdge,
      children: data.builds(context),
    );
    final w = parseDouble(args['width']);
    final h = parseDouble(args['height']);
    if (w == null && h == null) return stack;
    return SizedBox(width: w, height: h, child: stack);
  }
}

/// Filho de `stack` em posição absoluta.
class SDPositioned implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDPositioned(this.args, JsonViewRegistry registry) : data = childOf(args, registry);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: parseDouble(args['left']),
      top: parseDouble(args['top']),
      right: parseDouble(args['right']),
      bottom: parseDouble(args['bottom']),
      width: parseDouble(args['width']),
      height: parseDouble(args['height']),
      child: data.build(context),
    );
  }
}
