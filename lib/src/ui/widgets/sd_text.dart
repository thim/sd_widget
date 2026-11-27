import 'package:flutter/material.dart';

import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/decoder.dart';
import 'package:sd_widget/src/ui/widgets/parser.dart';
import 'package:sd_widget/src/ui/widgets/sd_common.dart';

class SDText implements BaseJsonWidget {
  final Map args;

  SDText(this.args);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final itemData = args['item_data'];
    String text = args['text'];

    if (text.startsWith('\$') && itemData is Map) {
      text = itemData[text] ?? "";
    }

    final base = decodeTextStyle(textTheme, args['style']) ?? const TextStyle();

    return Text(
      text,
      textAlign: decodeTextAlign(args['textAlign']),
      maxLines: parseInt(args['maxLines']),
      overflow: decodeTextOverflow(args['overflow']),
      style: base.copyWith(
        color: decodeColor(args['color']),
        fontSize: parseDouble(args['fontSize']),
        fontWeight: decodeFontWeight(args['fontWeight']),
        fontFamily: args['fontFamily'] as String?,
        height: parseDouble(args['height']),
      ),
    );
  }
}
