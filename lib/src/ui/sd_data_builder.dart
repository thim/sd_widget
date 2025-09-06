import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sd_widget/src/core/sd_base.dart';
import 'package:sd_widget/src/core/sd_data.dart';

/// Abstract interface for JSON-based widgets that can be built from configuration.
///
/// All widgets created from JSON configuration must implement this interface
/// to ensure they can be properly rendered by the [JsonViewDataBuilder].
abstract interface class BaseJsonWidget implements JsonView {
  /// Builds the widget for the given [context].
  ///
  /// This method should return a valid Flutter widget based on the
  /// JSON configuration provided during widget creation.
  Widget build(BuildContext context);
}

/// A builder class that constructs Flutter widgets from JSON configuration data.
///
/// This class extends [JsonViewData] and provides methods to build individual
/// widgets or collections of widgets from JSON-based widget definitions.
///
/// The builder handles error cases gracefully by returning empty widgets
/// when construction fails, ensuring the app doesn't crash due to malformed JSON.
class JsonViewDataBuilder extends JsonViewData {
  /// Creates a new [JsonViewDataBuilder] with the given [registry].
  ///
  /// The [registry] contains the widget builders and processors needed
  /// to construct widgets from JSON configuration.
  JsonViewDataBuilder(super.registry);

  /// Builds a widget or collection of widgets from the loaded JSON data.
  ///
  /// The behavior depends on the number of builders and the provided [index]:
  /// - If no builders: returns an empty [SizedBox.shrink]
  /// - If one builder: returns that single widget
  /// - If [index] is provided: returns the widget at that index
  /// - Otherwise: returns all widgets in a [Column]
  ///
  /// [context] is the build context for widget construction.
  /// [index] is an optional index to build a specific widget from the collection.
  ///
  /// Returns a [Widget] that represents the JSON configuration, or an empty
  /// widget if an error occurs during construction.
  Widget build(
    BuildContext context, {
    int? index,
  }) {
    try {
      if (builders.isEmpty) {
        return const SizedBox.shrink();
      }
      if (builders.length == 1) {
        return (builders.first as BaseJsonWidget).build(context);
      }
      if (index != null && index < builders.length) {
        return (builders[index] as BaseJsonWidget).build(context);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: builds(context),
      );
    } catch (e, s) {
      log("Error building widget.", error: e, stackTrace: s, name: 'JsonViewDataBuilder');
      return const SizedBox.shrink();
    }
  }

  /// Builds all widgets from the builders collection.
  ///
  /// This method constructs each widget individually and handles errors
  /// for each widget separately, ensuring that one failing widget doesn't
  /// prevent others from being built.
  ///
  /// [context] is the build context for widget construction.
  ///
  /// Returns a [List<Widget>] containing all successfully built widgets.
  /// Failed widgets are replaced with empty [SizedBox.shrink] widgets.
  List<Widget> builds(
    BuildContext context,
  ) {
    return builders.map((item) {
      try {
        return (item as BaseJsonWidget).build(context);
      } catch (e, s) {
        log("Error building inner widget.", error: e, stackTrace: s, name: 'JsonViewDataBuilder');
        return const SizedBox.shrink();
      }
    }).toList();
  }
}
