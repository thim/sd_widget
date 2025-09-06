import 'package:flutter/material.dart';
import 'package:sd_widget/src/core/sd_list_builder.dart';
import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';

/// Type alias for better readability
typedef JsonMap = Map<String, dynamic>;

/// A configurable widget that builds its UI based on JSON configuration.
///
/// This widget supports multiple data sources:
/// - JSON strings via [SDWidget.fromJson]
/// - List of maps via [SDWidget.fromList]
/// - Pre-built view data via [SDWidget.fromViewData]
/// - Dynamic list data via [SDWidget.listDataBuilder]
///
/// Example usage:
/// ```dart
/// SDWidget.fromJson(
///   '{"type": "container", "child": {"type": "text", "text": "Hello"}}',
///   viewRegistry: myRegistry,
/// );
/// ```
class SDWidget extends StatelessWidget {
  /// The underlying data builder that handles the widget construction
  final JsonViewDataBuilder _viewData;

  /// Creates a widget from a JSON string.
  ///
  /// [fromJson] must be a valid JSON string that matches the expected format.
  /// [viewRegistry] is required and contains the widget builders.
  /// [data] is optional additional data that can be referenced in the JSON.
  ///
  SDWidget.fromJson(
    String fromJson, {
    required JsonViewRegistry viewRegistry,
    JsonMap data = const {},
    super.key,
  }) : _viewData = _createViewDataFromJson(fromJson, viewRegistry, data);

  /// Creates a widget from a list of maps.
  ///
  /// [list] must be a non-empty list of maps.
  /// [viewRegistry] is required and contains the widget builders.
  /// [data] is optional additional data that can be referenced.
  ///
  SDWidget.fromList(
    List<JsonMap> list, {
    required JsonViewRegistry viewRegistry,
    JsonMap data = const {},
    super.key,
  }) : _viewData = _createViewDataFromList(list, viewRegistry, data);

  /// Creates a widget from pre-built view data.
  ///
  /// [viewData] must not be null.
  SDWidget.fromViewData(
    JsonViewDataBuilder viewData, {
    super.key,
  }) : _viewData = viewData;

  /// Creates a widget with dynamic list data building capabilities.
  ///
  /// [fromJson] must be a valid JSON string.
  /// [itemData] builds individual items in the list.
  /// [itemCount] returns the total number of items.
  /// [viewRegistry] is required and contains the widget builders.
  ///
  SDWidget.listDataBuilder({
    required String fromJson,
    required ItemDataBuilder itemData,
    required ItemCountBuilder itemCount,
    required JsonViewRegistry viewRegistry,
    super.key,
  }) : _viewData = _createViewDataWithListBuilder(
          fromJson,
          itemData,
          itemCount,
          viewRegistry,
        );

  /// Helper method to create view data from JSON with error handling
  static JsonViewDataBuilder _createViewDataFromJson(
    String fromJson,
    JsonViewRegistry viewRegistry,
    JsonMap data,
  ) {
    viewRegistry.addData(data);
    final viewData = JsonViewDataBuilder(viewRegistry);
    viewData.loadJson(fromJson);
    return viewData;
  }

  /// Helper method to create view data from list with error handling
  static JsonViewDataBuilder _createViewDataFromList(
    List<JsonMap> list,
    JsonViewRegistry viewRegistry,
    JsonMap data,
  ) {
    viewRegistry.addData(data);
    final viewData = JsonViewDataBuilder(viewRegistry);
    viewData.fromList(list);
    return viewData;
  }

  /// Helper method to create view data with list builder
  static JsonViewDataBuilder _createViewDataWithListBuilder(
    String fromJson,
    ItemDataBuilder itemData,
    ItemCountBuilder itemCount,
    JsonViewRegistry viewRegistry,
  ) {
    viewRegistry.registerDataBuilder(ListBuilder(itemData, itemCount));
    final viewData = JsonViewDataBuilder(viewRegistry);
    viewData.loadJson(fromJson);
    return viewData;
  }

  @override
  Widget build(BuildContext context) {
    return _viewData.build(context);
  }
}
