import 'package:flutter/material.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';

/// A custom [SliverChildDelegate] that builds widgets from JSON configuration data.
///
/// This delegate wraps a [JsonViewDataBuilder] to provide sliver-compatible
/// widget building for use with Flutter's sliver widgets like [SliverList],
/// [SliverGrid], etc.
///
/// The delegate efficiently manages widget creation and rebuilding by:
/// - Only rebuilding when the underlying data actually changes
/// - Providing proper child count management
/// - Handling errors gracefully during widget construction
///
/// Example usage:
/// ```dart
/// final delegate = SDSliverDelegate(jsonViewDataBuilder);
/// final sliverList = SliverList(delegate: delegate);
/// ```
class SDSliverDelegate extends SliverChildDelegate {
  /// The underlying delegate that handles the actual widget building
  final SliverChildBuilderDelegate _delegate;

  /// The JSON view data builder that contains the widget configuration
  final JsonViewDataBuilder _widgetData;

  /// Creates a new [SDSliverDelegate] with the given [widgetData].
  ///
  /// [widgetData] must not be null and should contain the JSON-based
  /// widget configuration that will be used to build the sliver children.
  SDSliverDelegate(this._widgetData)
      : _delegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return _widgetData.build(context, index: index);
          },
          childCount: _widgetData.length,
        );

  @override
  Widget? build(BuildContext context, int index) => _delegate.build(context, index);

  @override
  int? get estimatedChildCount => _widgetData.length;

  @override
  bool shouldRebuild(covariant SDSliverDelegate oldDelegate) {
    if (identical(_widgetData, oldDelegate._widgetData)) {
      return false;
    }
    return _widgetData.length != oldDelegate._widgetData.length || _widgetData.builders != oldDelegate._widgetData.builders;
  }
}
