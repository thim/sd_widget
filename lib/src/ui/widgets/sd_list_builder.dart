import 'package:flutter/material.dart';

import 'package:sd_widget/src/core/sd_list_builder.dart';
import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';

class SDListBuilder implements BaseJsonWidget {
  final Map args;
  final JsonViewDataBuilder viewData;
  final ListBuilder listBuilder;

  SDListBuilder(this.args, this.listBuilder, JsonViewRegistry registry) : viewData = JsonViewDataBuilder(registry);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listBuilder.count(args["id"]),
      itemBuilder: (context, index) {
        final builder = args['builder'];

        if (builder is Map) {
          builder['item_data'] = listBuilder.builder(args["id"], index);
        }
        final viewBuilder = viewData.createBuilder(builder) as BaseJsonWidget;
        return viewBuilder.build(context);
      },
    );
  }
}
