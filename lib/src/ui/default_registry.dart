import 'package:sd_widget/src/core/sd_base.dart';
import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/widgets/widgets.dart';

/// Factory function that creates and returns a configured [JsonViewRegistry]
/// with default widget mappings.
///
/// The [processor] parameter allows for custom JSON processing logic.
/// If not provided, a default processor will be used that extracts
/// 'type' and 'data' fields from the JSON map.
JsonViewRegistry defaultWidget({JsonProcessor? processor}) {
  // Use a more descriptive variable name
  final Map<String, RegistryBuilder> widgetBuilders = {};

  final registry = JsonViewRegistry(widgetBuilders, processor ?? _defaultProcessor);

  // Register basic UI widgets
  _registerWidgets(widgetBuilders, registry);

  return registry;
}

/// Default processor for handling JSON data.
///
/// Extracts the 'type' field as the widget type and 'data' field as widget arguments.
/// If 'type' is missing, returns an empty string. If 'data' is missing, returns an empty map.
(String, Map<String, dynamic>) _defaultProcessor(Map<String, dynamic> map) {
  final type = map['type'] as String?;
  final data = map['data'] as Map<String, dynamic>? ?? {};
  return (type ?? '', data);
}

/// Registers basic UI widgets to the widget builders map.
void _registerWidgets(Map<String, RegistryBuilder> builders, JsonViewRegistry registry) {
  builders.addAll({
    'text': (Map args) => SDText(args),
    'button': (Map args) => SDButton(args, registry.actionCallback),
    'svg': (Map args) => SDSVG(args),
    'padding': (Map args) => SDPadding(args, registry),
    'column': (Map args) => SDColumn(args, registry),
    'row': (Map args) => SDRow(args, registry),
    'scroll': (Map args) => SDScroll(args, registry),
    'listview': (Map args) => SDListView(args, registry),
    'sized_box': (Map args) => SDSizedBox(args),
    'container': (Map args) => SDContainer(args, registry),
    'expanded': (Map args) => SDExpanded(args, registry),
    'tile': (Map args) => SDTile(args),
    'list_tile': (Map args) => SDListTile(args),
    'list_builder': (Map args) => SDListBuilder(args, registry.listDataBuilder, registry),
  });
}
