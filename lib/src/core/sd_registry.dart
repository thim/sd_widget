import 'dart:developer';

import 'package:sd_widget/src/core/sd_action.dart';
import 'package:sd_widget/src/core/sd_base.dart';
import 'package:sd_widget/src/core/sd_list_builder.dart';

/// A registry for managing JSON-to-widget mappings and data processing.
///
/// This class serves as a central registry for widget builders, data management,
/// and action handling in a JSON-driven UI system.
class JsonViewRegistry {
  /// Map of widget type names to their corresponding builder functions
  final Map<String, RegistryBuilder> _builders;

  /// Function used to process JSON data before widget creation
  final JsonProcessor _processor;

  /// Internal data store for the registry
  final Map<String, dynamic> _data = {};

  /// Builder for creating list data
  ListBuilder _dataBuilder = ListBuilder.empty();

  /// Callback function for handling widget actions
  ActionCallback? actionCallback;

  /// Gets the current list data builder
  ListBuilder get listDataBuilder => _dataBuilder;

  /// Gets the internal data store
  Map<String, dynamic> get dataProvider => _data;

  /// Gets the JSON processor function
  JsonProcessor get processor => _processor;

  /// Creates a new JsonViewRegistry with the given builders and processor.
  ///
  /// [_builders] - Map of widget type names to builder functions
  /// [_processor] - Function to process JSON data before widget creation
  JsonViewRegistry(this._builders, this._processor) {
    log('Creating registry with ${_builders.length} builders.', name: 'VIEW_REGISTRY');
  }

  /// Registers a new data builder for list operations.
  ///
  /// [dataBuilder] - The ListBuilder to use for creating list data
  void registerDataBuilder(ListBuilder dataBuilder) {
    _dataBuilder = dataBuilder;
  }

  /// Adds data to the internal data store.
  ///
  /// [data] - Map of key-value pairs to add to the data store
  void addData(Map<String, dynamic> data) {
    _data.addAll(data);
  }

  /// Sets the action callback function.
  ///
  /// [actionCallback] - Function to call when widget actions are triggered
  void onAction(ActionCallback actionCallback) {
    this.actionCallback = actionCallback;
  }

  /// Creates a widget instance for the given type and arguments.
  ///
  /// [type] - The widget type name
  /// [args] - Arguments to pass to the widget builder
  /// Returns the created widget, or null if the type is not registered
  JsonView? getUIBuilder(String type, Map<String, dynamic> args) {
    return _builders[type]?.call(args);
  }

  /// Adds a new widget builder to the registry.
  ///
  /// [key] - The widget type name
  /// [builder] - The builder function for creating widgets of this type
  /// Returns true if the builder was added, false if it already existed
  void add(String key, RegistryBuilder builder) {
    if (_builders.containsKey(key)) log('Builder $key already registered.', name: 'VIEW_REGISTRY', level: 1);
    _builders.putIfAbsent(key, () => builder);
  }
}
