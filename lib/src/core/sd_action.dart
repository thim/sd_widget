import 'package:sd_widget/src/core/sd_event.dart';

/// Enum representing different types of actions that can be performed in the widget system.
///
/// Each action type corresponds to a specific behavior or navigation action.
enum SDActionType {
  /// Navigate to a named route
  pushNamed('push_named'),

  /// Open a web view with the specified URL
  pushWebView('open_webview'),

  /// Open an external URL in the default browser
  pushExternal('open_url'),

  /// Pop the current screen/route
  pop('pop'),

  /// Custom action type for application-specific behaviors
  custom('custom');

  /// The string representation of the action type
  final String typeName;

  /// Creates an SDActionType with the given type name
  const SDActionType(this.typeName);

  /// Decodes a string value into an SDActionType.
  ///
  /// [value] - The string value to decode
  /// Returns the corresponding SDActionType, or [custom] if not found
  static SDActionType decodeAction(String? value) {
    if (value == null || value.isEmpty) {
      return SDActionType.custom;
    }

    final normalizedValue = value.toLowerCase().trim();

    for (final type in SDActionType.values) {
      if (type.typeName.toLowerCase() == normalizedValue) {
        return type;
      }
    }

    return SDActionType.custom;
  }
}

/// Represents an action that can be performed in the widget system.
///
/// Actions encapsulate the type of operation, target reference, associated events,
/// and any additional data needed to execute the action.
class SDAction {
  final SDActionType type;
  final String reference;
  final SDEvent? event;
  final String? label;
  final Map<String, dynamic>? data;

  /// Whether this action has an associated event.
  bool get hasEvent => event != null;

  /// Creates a new SDAction with the specified parameters.
  ///
  /// [type] - The type of action to perform
  /// [reference] - The target reference for the action
  /// [event] - Optional event associated with this action
  /// [data] - Optional additional data for the action
  /// [label] - Optional human-readable label for the action
  const SDAction(this.type, this.reference, {this.event, this.data, this.label});

  /// Creates an SDAction from a map of arguments.
  ///
  /// [args] - The map containing action configuration
  /// Returns a new SDAction instance, or null if the map is invalid
  static SDAction? fromMap(Map? args) {
    if (args == null) return null;

    try {
      final type = SDActionType.decodeAction(args["type"]);
      final reference = args["reference"]?.toString() ?? "";
      final event = SDEvent.fromMap(args["event"] ?? args["eventProperties"]);
      final data = args["data"];
      final label = args["label"]?.toString();
      return SDAction(type, reference, event: event, data: data, label: label);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'SD_ACTION (name: $type, reference: $reference)';
  }
}

/// Function signature for handling action callbacks.
///
/// [action] - The SDAction to handle
typedef ActionCallback = void Function(SDAction action);
