import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';

/// item_data herdado do nó pai (listas alimentadas por dados).
Map<String, dynamic> itemDataOf(Map args) {
  final v = args['item_data'];
  return v is Map ? v.cast<String, dynamic>() : const {};
}

/// Builder do nó em [args][key], repassando item_data.
JsonViewDataBuilder childOf(Map args, JsonViewRegistry registry, [String key = 'child']) {
  final data = JsonViewDataBuilder(registry);
  final child = args[key];
  if (child is Map<String, dynamic>) {
    data.fromMap(child, itemData: itemDataOf(args));
  }
  return data;
}

/// Builder dos nós em [args]['children'], repassando item_data.
JsonViewDataBuilder childrenOf(Map args, JsonViewRegistry registry) {
  final data = JsonViewDataBuilder(registry);
  final children = args['children'];
  if (children is Iterable) {
    data.fromList(children, itemData: itemDataOf(args));
  }
  return data;
}

int? parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}
