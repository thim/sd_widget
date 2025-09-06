/// Base interface for all JSON-driven widget views.
///
/// This interface serves as the foundation for all widgets that can be created
/// from JSON data. Implementing classes should provide the necessary logic
/// to render themselves based on the provided JSON configuration.
abstract interface class JsonView {}

/// Function signature for building widgets based on type and arguments.
///
/// This is used by registries to create widgets dynamically from JSON data.
///
/// [type] - The widget type identifier
/// [args] - The configuration arguments for the widget
/// Returns the created widget, or null if the type is not supported
typedef JsonViewBuilder = JsonView? Function(String type, Map<String, dynamic> args);

/// Function signature for creating widgets from configuration arguments.
///
/// This is used for individual widget builders registered in the system.
///
/// [args] - The configuration arguments for the widget
/// Returns the created widget instance
typedef RegistryBuilder = JsonView Function(Map<String, dynamic> args);

/// Function signature for processing raw JSON data into widget configuration.
///
/// This function extracts the widget type and configuration data from raw JSON.
///
/// [map] - The raw JSON data as a map
/// Returns a record containing the widget type and processed configuration data
typedef JsonProcessor = (String, Map<String, dynamic>) Function(Map<String, dynamic> map);
