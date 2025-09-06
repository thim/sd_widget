import 'package:flutter/material.dart';
import 'package:sd_widget/src/core/sd_action.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';

enum ButtonStyle { elevated, filled, outline, text }

class SDButton implements BaseJsonWidget {
  final Map args;

  final ActionCallback? actionCallback;

  SDButton(this.args, this.actionCallback);

  @override
  Widget build(BuildContext context) {
    final style = decodeStyle(args["style"]) ?? ButtonStyle.filled;

    final action = SDAction.fromMap(args["action"]);

    void click() {
      if (action != null) {
        actionCallback?.call(action);
      }
    }

    switch (style) {
      case ButtonStyle.elevated:
        return ElevatedButton(onPressed: click, child: Text('${args['text']}'));
      case ButtonStyle.filled:
        return FilledButton(onPressed: click, child: Text('${args['text']}'));
      case ButtonStyle.outline:
        return OutlinedButton(onPressed: click, child: Text('${args['text']}'));
      case ButtonStyle.text:
        return TextButton(onPressed: click, child: Text('${args['text']}'));
    }
  }
}

ButtonStyle? decodeStyle(String? value) {
  final map = {
    'elevated': ButtonStyle.elevated,
    'filled': ButtonStyle.filled,
    'outline': ButtonStyle.outline,
    'text': ButtonStyle.text,
  };

  return map[value];
}
