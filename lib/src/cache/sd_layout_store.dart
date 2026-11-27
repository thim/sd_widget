import 'dart:collection';
import 'dart:convert';

/// Um layout SDUI guardado em cache.
class CachedLayout {
  /// JSON do layout, exatamente como veio da rede.
  final String json;

  /// ETag devolvido pelo servidor, usado para revalidar (If-None-Match).
  final String? etag;

  /// Quando o layout foi baixado ou revalidado pela última vez.
  final DateTime fetchedAt;

  const CachedLayout({required this.json, this.etag, required this.fetchedAt});

  CachedLayout copyWith({DateTime? fetchedAt}) =>
      CachedLayout(json: json, etag: etag, fetchedAt: fetchedAt ?? this.fetchedAt);

  Map<String, dynamic> toMap() => {
        'json': json,
        if (etag != null) 'etag': etag,
        'fetchedAt': fetchedAt.toUtc().toIso8601String(),
      };

  /// Lê o formato de [toMap]; devolve null se estiver corrompido.
  static CachedLayout? fromMap(Object? map) {
    if (map is! Map) return null;
    final json = map['json'];
    final at = DateTime.tryParse('${map['fetchedAt']}');
    if (json is! String || at == null) return null;
    return CachedLayout(json: json, etag: map['etag'] as String?, fetchedAt: at);
  }
}

/// Onde os layouts ficam guardados entre aberturas do app.
///
/// O pacote traz [MemoryLayoutStore] e [KeyValueLayoutStore]; este último liga o
/// cache a qualquer armazenamento chave-valor (shared_preferences, Hive, arquivos…)
/// sem o sd_widget depender deles.
abstract interface class SDLayoutStore {
  Future<CachedLayout?> read(String key);
  Future<void> write(String key, CachedLayout layout);
  Future<void> remove(String key);
}

/// Cache em memória com descarte do menos usado (LRU).
class MemoryLayoutStore implements SDLayoutStore {
  final int capacity;
  final LinkedHashMap<String, CachedLayout> _items = LinkedHashMap();

  MemoryLayoutStore({this.capacity = 20}) : assert(capacity > 0);

  int get length => _items.length;

  /// Leitura síncrona, sem mudar a ordem de uso.
  CachedLayout? peek(String key) => _items[key];

  @override
  Future<CachedLayout?> read(String key) async => _touch(key);

  CachedLayout? _touch(String key) {
    final v = _items.remove(key);
    if (v != null) _items[key] = v;
    return v;
  }

  @override
  Future<void> write(String key, CachedLayout layout) async {
    _items.remove(key);
    _items[key] = layout;
    while (_items.length > capacity) {
      _items.remove(_items.keys.first);
    }
  }

  @override
  Future<void> remove(String key) async => _items.remove(key);
}

/// Adapta um armazenamento chave-valor de strings.
///
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// final store = KeyValueLayoutStore(
///   read: (k) async => prefs.getString(k),
///   write: (k, v) => prefs.setString(k, v),
///   remove: (k) => prefs.remove(k),
/// );
/// ```
class KeyValueLayoutStore implements SDLayoutStore {
  final Future<String?> Function(String key) _read;
  final Future<void> Function(String key, String value) _write;
  final Future<void> Function(String key) _remove;
  final String prefix;

  KeyValueLayoutStore({
    required Future<String?> Function(String key) read,
    required Future<void> Function(String key, String value) write,
    required Future<void> Function(String key) remove,
    this.prefix = 'sdui.layout.',
  })  : _read = read,
        _write = write,
        _remove = remove;

  @override
  Future<CachedLayout?> read(String key) async {
    final raw = await _read('$prefix$key');
    if (raw == null) return null;
    try {
      return CachedLayout.fromMap(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(String key, CachedLayout layout) => _write('$prefix$key', jsonEncode(layout.toMap()));

  @override
  Future<void> remove(String key) => _remove('$prefix$key');
}
