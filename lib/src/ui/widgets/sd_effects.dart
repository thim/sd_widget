import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_action.dart';
import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/decoder.dart';
import 'package:sd_widget/src/ui/widgets/parser.dart';
import 'package:sd_widget/src/ui/widgets/sd_common.dart';

class SDOpacity implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDOpacity(this.args, JsonViewRegistry registry) : data = childOf(args, registry);

  @override
  Widget build(BuildContext context) {
    final opacity = (parseDouble(args['opacity'], 1.0)!).clamp(0.0, 1.0);
    return Opacity(opacity: opacity, child: data.build(context));
  }
}

/// Gira o filho em graus; positivo = horário.
class SDRotate implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder data;

  SDRotate(this.args, JsonViewRegistry registry) : data = childOf(args, registry);

  @override
  Widget build(BuildContext context) {
    final degrees = parseDouble(args['angle'], 0.0)!;
    return Transform.rotate(
      angle: degrees * math.pi / 180,
      alignment: decodeAlignment(args['alignment']) ?? Alignment.center,
      child: data.build(context),
    );
  }
}

/// Torna qualquer nó clicável sem mudar o visual.
class SDTap implements BaseJsonWidget {
  final Map args;
  final JsonViewRegistry registry;
  final JsonViewDataBuilder data;

  SDTap(this.args, this.registry) : data = childOf(args, registry);

  @override
  Widget build(BuildContext context) {
    final action = SDAction.fromMap(args['action']);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Lido na hora do toque: onAction pode ser registrado depois do parse.
      onTap: action == null ? null : () => registry.actionCallback?.call(action),
      child: data.build(context),
    );
  }
}
