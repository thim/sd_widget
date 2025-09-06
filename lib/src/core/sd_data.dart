import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:sd_widget/src/core/sd_action.dart';
import 'package:sd_widget/src/core/sd_base.dart';
import 'package:sd_widget/src/core/sd_registry.dart';

/// A data manager for loading and processing JSON data into widget views.
///
/// This class handles the conversion of JSON data (both compressed and uncompressed)
/// into widget instances using a registry-based approach. It supports loading from
/// various sources and provides utilities for managing the resulting widget list.
class JsonViewData {
  /// Internal list storing the created widget views
  final List<JsonView> _viewList = [];

  /// The registry used for processing JSON and creating widgets
  final JsonViewRegistry _registry;

  /// Gets the number of loaded widget views
  int get length => _viewList.length;

  /// Gets an unmodifiable list of all loaded widget builders
  List<JsonView> get builders => List.unmodifiable(_viewList);

  /// Creates a new JsonViewData instance with the specified registry.
  ///
  /// [_registry] - The JsonViewRegistry to use for processing JSON data
  JsonViewData(this._registry);

  /// Factory constructor that creates a JsonViewData with the given registry.
  ///
  /// [registry] - The JsonViewRegistry to use for processing JSON data
  factory JsonViewData.withRegistry(JsonViewRegistry registry) => JsonViewData(registry);

  /// Loads JSON data from a gzip-compressed string.
  ///
  /// [jsonString] - The gzip-compressed JSON string to load
  void loadZip(
    String jsonString,
  ) {
    final List<int> original = utf8.encode(jsonString);
    final List<int> decompress = gzip.decode(original);
    final String decoded = utf8.decode(decompress);
    loadJson(decoded);
  }

  /// Loads JSON data from a string and converts it to widget views.
  ///
  /// [jsonString] - The JSON string to parse and load
  /// [clearExisting] - Whether to clear existing views before loading (defaults to true)
  /// Returns the number of views loaded
  void loadJson(String jsonString, {bool clearExisting = true}) {
    if (jsonString.isEmpty) return;

    if (clearExisting) {
      _viewList.clear();
    }

    try {
      final decoded = json.decode(jsonString);

      if (decoded is Iterable) {
        fromList(decoded);
      } else if (decoded is Map<String, dynamic>) {
        fromMap(decoded);
      } else {
        log('Invalid JSON structure: expected Map or List', name: 'VIEW_DATA');
        return;
      }

      log("Builder list loaded.", name: "VIEW_DATA");
    } catch (e, s) {
      log("Error processing json", error: e, stackTrace: s);
    }
  }

  /// Processes a list of items and converts them to widget views.
  ///
  /// [list] - The iterable containing items to process
  /// [itemData] - Additional data to include with each item
  /// Returns the number of successfully processed items
  void fromList(Iterable list, {Map<String, dynamic> itemData = const {}}) {
    for (final item in list) {
      fromMap(item, itemData: itemData);
    }
  }

  /// Processes a map and converts it to a widget view.
  ///
  /// [map] - The map containing widget data
  /// [itemData] - Additional data to include with the item
  /// Returns true if the widget was successfully created and added
  void fromMap(Map<String, dynamic> map, {Map<String, dynamic> itemData = const {}}) {
    final (type, data) = _registry.processor(map);
    data['item_data'] = itemData;
    final builder = _registry.getUIBuilder(type, data);

    if (builder == null) return;
    _viewList.add(builder);
  }

  /// Creates a single widget builder from a map without adding it to the view list.
  ///
  /// [builderMap] - The map containing widget configuration data
  /// Returns the created JsonView widget, or null if creation failed
  JsonView? createBuilder(
    Map<String, dynamic> builderMap,
  ) {
    final (type, data) = _registry.processor(builderMap);
    data['item_data'] = builderMap['item_data'];
    return _registry.getUIBuilder(type, data);
  }

  /// Sets the action callback for handling widget actions.
  ///
  /// [actionCallback] - The callback function to handle actions
  void onAction(ActionCallback actionCallback) {
    _registry.onAction(actionCallback);
  }
}
