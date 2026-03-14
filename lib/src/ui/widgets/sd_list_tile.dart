import 'package:flutter/material.dart';

import 'package:sd_widget/src/ui/sd_data_builder.dart';

class SDListTile implements BaseJsonWidget {
  final Map args;

  SDListTile(this.args);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(replace('title')),
      subtitle: Text(replace("subtitle")),
      trailing: Text(replace("trailing")),
    );
  }

  String replace(String key) {
    final itemData = args['item_data'];
    final String text0 = args[key]?.toString() ?? '';
    String text = text0;
    if (text.startsWith('\$') && itemData is Map) {
      text = itemData[text] ?? "";
    }
    return text;
  }
}
