import 'package:flutter/material.dart';

import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/decoder.dart';

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

    return Text(
      text,
      style: decodeTextStyle(
        textTheme,
        args['style'],
      )?.copyWith(
        color: decodeColor(args['color']),
      ),
    );
  }
}
