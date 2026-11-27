import 'package:flutter/material.dart';

import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/parser.dart';

const Color _placeholder = Color(0xFFE0E0E0);

/// Imagem raster por URL.
class SDImage implements BaseJsonWidget {
  final Map args;

  SDImage(this.args);

  @override
  Widget build(BuildContext context) {
    final w = parseDouble(args['width']);
    final h = parseDouble(args['height']);
    final radius = parseDouble(args['radius'], 0.0)!;

    Widget fallback(BuildContext context, Object error, StackTrace? stack) =>
        Container(width: w, height: h, color: _placeholder);

    Widget image = Image.network(
      '${args['url']}',
      width: w,
      height: h,
      fit: decodeBoxFit(args['fit']) ?? BoxFit.cover,
      semanticLabel: args['semanticLabel'] as String?,
      errorBuilder: fallback,
    );
    if (radius > 0) {
      image = ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
    }
    return image;
  }
}

BoxFit? decodeBoxFit(dynamic value) {
  return {
    'contain': BoxFit.contain,
    'cover': BoxFit.cover,
    'fill': BoxFit.fill,
    'fitWidth': BoxFit.fitWidth,
    'fitHeight': BoxFit.fitHeight,
    'none': BoxFit.none,
    'scaleDown': BoxFit.scaleDown,
  }[value];
}
