/// Represents an event associated with an action.
///
/// Events provide additional context and metadata for actions,
/// enabling tracking, analytics, and custom behavior.
class SDEvent {
  final String name;
  final Map<String, dynamic> metadata;

  /// Creates a new SDEvent with the specified name and metadata.
  ///
  /// [name] - The name of the event
  /// [metadata] - Additional metadata for the event (defaults to empty map)
  const SDEvent(this.name, this.metadata);

  /// Creates an SDEvent from a dynamic value.
  ///
  /// [args] - The dynamic value to parse (should be a Map)
  /// Returns a new SDEvent instance, or null if parsing fails
  static SDEvent? fromMap(dynamic args) {
    if (args is! Map) return null;
    try {
      final name = args["name"]?.toString();
      final metadata = (args["metadata"] is Map ? args["metadata"] : {})
          .map<String, dynamic>((key, value) => MapEntry<String, dynamic>(key.toString(), value));

      if (name == null) return null;

      return SDEvent(name, metadata);
    } catch (e) {
      return null;
    }
  }
}
