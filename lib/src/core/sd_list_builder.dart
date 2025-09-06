/// Function signature for building item data based on ID and index.
///
/// [id] - The unique identifier for the list
/// [index] - The zero-based index of the item in the list
/// Returns a Map containing the data for the item at the given index
typedef ItemDataBuilder = Map Function(String id, int index);

/// Function signature for determining the total count of items in a list.
///
/// [id] - The unique identifier for the list
/// Returns the total number of items in the list
typedef ItemCountBuilder = int Function(String id);

/// A builder class for creating dynamic lists with data and count providers.
///
/// This class encapsulates the logic for building list items and determining
/// list counts, making it easy to create dynamic lists from various data sources.
class ListBuilder {
  /// Function that builds data for individual list items
  final ItemDataBuilder builder;

  /// Function that determines the total count of items in the list
  final ItemCountBuilder count;

  /// Creates an empty ListBuilder that returns no items and zero count.
  ///
  /// Useful as a default or placeholder when no actual data is available.
  const ListBuilder(this.builder, this.count);

  /// Creates an empty ListBuilder that returns no items and zero count.
  ///
  /// Useful as a default or placeholder when no actual data is available.
  factory ListBuilder.empty() => ListBuilder((id, index) => {}, (id) => 0);
}
