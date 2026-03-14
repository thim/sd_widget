# SD Widget — Codebase Analysis

## Overview

`sd_widget` is a **Server-Driven UI (SDUI)** Flutter package. It lets a backend
deliver JSON payloads that are rendered as native Flutter widgets without
requiring an app update.

---

## Package metadata

| Field | Value |
|-------|-------|
| Name | `sd_widget` |
| Version | `1.0.0+1` |
| Dart SDK | `>=3.0.0 <4.0.0` |
| Runtime deps | `flutter`, `flutter_svg 2.0.9` |
| Dev deps | `flutter_test`, `flutter_lints ^2.0.0` |

---

## Directory layout

```
lib/
├── sd_widget.dart              # Public barrel export
└── src/
    ├── core/
    │   ├── sd_base.dart        # Abstract interfaces & typedefs
    │   ├── sd_registry.dart    # Central widget registry
    │   ├── sd_data.dart        # JSON loader / data manager
    │   ├── sd_list_builder.dart# Dynamic list data provider
    │   ├── sd_action.dart      # Action model + SDActionType enum
    │   └── sd_event.dart       # Event model (analytics metadata)
    └── ui/
        ├── default_registry.dart  # Factory: defaultWidget()
        ├── sd_data_builder.dart   # BaseJsonWidget interface + JsonViewDataBuilder
        ├── sd_sliver.dart         # SDSliverDelegate (sliver-compatible delegate)
        ├── sd_widget.dart         # SDWidget (StatelessWidget entry-point)
        └── widgets/
            ├── widgets.dart       # Barrel re-export
            ├── decoder.dart       # JSON → Flutter type decoders
            ├── parser.dart        # parseDouble helper
            ├── sd_text.dart
            ├── sd_button.dart
            ├── sd_svg.dart
            ├── sd_column.dart
            ├── sd_row.dart
            ├── sd_container.dart
            ├── sd_padding.dart
            ├── sd_expanded.dart
            ├── sd_sized_box.dart
            ├── sd_scroll.dart
            ├── sd_listview.dart
            ├── sd_list_tile.dart
            ├── sd_tile.dart
            └── sd_list_builder.dart
test/
├── sd_widget_tests.dart        # Test entry-point
└── src/widget_test.dart        # All widget tests
```

---

## Architecture

### Data flow

```
JSON string
    │
    ▼
JsonViewData.loadJson()          (sd_data.dart)
    │  json.decode → List | Map
    ▼
JsonViewData.fromMap()
    │  _registry.processor(map)  → (type, data)
    │  _registry.getUIBuilder()  → JsonView (widget instance)
    ▼
List<JsonView> _viewList
    │
    ▼
JsonViewDataBuilder.build()      (sd_data_builder.dart)
    │  casts each JsonView to BaseJsonWidget and calls .build(context)
    ▼
Flutter Widget tree
```

### Key abstractions (`sd_base.dart`)

| Type | Purpose |
|------|---------|
| `JsonView` | Marker interface for all SD widgets |
| `BaseJsonWidget` | Extends `JsonView`, adds `Widget build(BuildContext)` |
| `RegistryBuilder` | `JsonView Function(Map<String,dynamic> args)` — factory per type |
| `JsonViewBuilder` | `JsonView? Function(String type, Map args)` — dispatcher |
| `JsonProcessor` | `(String, Map<String,dynamic>) Function(Map map)` — extracts type + data from raw JSON map |

### `JsonViewRegistry` (`sd_registry.dart`)

Central service locator:
- Holds `Map<String, RegistryBuilder> _builders`
- Holds a `JsonProcessor` (default: reads `map['type']` and `map['data']`)
- Exposes `getUIBuilder(type, args)` → delegates to `_builders[type]`
- Exposes `add(key, builder)` for custom widget registration
- Stores `actionCallback`, `_data` (key/value store), and `ListBuilder`

### `JsonViewData` (`sd_data.dart`)

Data manager / loader:
- `loadJson(String)` — parses JSON, populates internal `List<JsonView>`
- `loadZip(String)` — gzip-decodes then calls `loadJson`
- `fromList(Iterable)` / `fromMap(Map)` — lower-level helpers
- `createBuilder(Map)` — creates a single widget without adding to the list (used by `SDListBuilder`)

### `JsonViewDataBuilder` (`sd_data_builder.dart`)

Extends `JsonViewData`, adds Flutter rendering:
- `build(context, {index?})` — renders zero, one, or all widgets (wraps multiple in a `Column`)
- `builds(context)` → `List<Widget>` — renders all, isolates per-widget errors

### `SDWidget` (`sd_widget.dart`)

`StatelessWidget` entry-point with named constructors:

| Constructor | Source |
|-------------|--------|
| `SDWidget.fromJson(json, viewRegistry)` | JSON string |
| `SDWidget.fromList(list, viewRegistry)` | `List<Map>` |
| `SDWidget.fromViewData(viewData)` | Pre-built `JsonViewDataBuilder` |
| `SDWidget.listDataBuilder(fromJson, itemData, itemCount, viewRegistry)` | Dynamic list |

### `defaultWidget()` (`default_registry.dart`)

Factory function returning a pre-configured `JsonViewRegistry` with all
built-in widget types registered. Custom `JsonProcessor` can be injected.

---

## Built-in widgets

| JSON `type` | Class | Notes |
|-------------|-------|-------|
| `text` | `SDText` | Supports `$variable` substitution from `item_data` |
| `button` | `SDButton` | `elevated / filled / outline / text` styles; fires `ActionCallback` |
| `svg` | `SDSVG` | Uses `flutter_svg` |
| `column` | `SDColumn` | Recursive children via `JsonViewDataBuilder` |
| `row` | `SDRow` | Same as column, horizontal |
| `container` | `SDContainer` | Sizing, decoration, single child |
| `padding` | `SDPadding` | Wraps a child with `EdgeInsetsGeometry` |
| `expanded` | `SDExpanded` | `Expanded` with `flex` support |
| `sized_box` | `SDSizedBox` | Width/height |
| `scroll` | `SDScroll` | `SingleChildScrollView` |
| `listview` | `SDListView` | `ListView` with children |
| `list_tile` | `SDListTile` | `ListTile` |
| `tile` | `SDTile` | Custom tile |
| `list_builder` | `SDListBuilder` | `ListView.builder` backed by `ListBuilder` |

---

## Action system (`sd_action.dart`)

`SDAction` is the payload dispatched when a user interacts with a widget:

```dart
class SDAction {
  final SDActionType type;   // pushNamed | pushWebView | pushExternal | pop | custom
  final String reference;    // target route, URL, or custom key
  final SDEvent? event;      // optional analytics event
  final Map<String,dynamic>? data;
  final String? label;
}
```

Decoded from JSON via `SDAction.fromMap(Map)`. The `ActionCallback` typedef
(`void Function(SDAction)`) is stored on `JsonViewRegistry` and passed to
widgets that need it (e.g. `SDButton`).

---

## Event system (`sd_event.dart`)

`SDEvent` carries analytics metadata attached to an action:

```dart
class SDEvent {
  final String name;
  final Map<String, dynamic> metadata;
}
```

---

## Decoder utilities (`decoder.dart`, `parser.dart`)

Stateless, pure-function decoders translating JSON primitives → Flutter types:

- `decodeColor(value)` — hex string (`#RGB`, `#RRGGBB`, `#AARRGGBB`) → `Color`
- `decodeEdgeInsetsGeometry(value)` — number / list / map → `EdgeInsetsGeometry`
- `decodeAlignment(value)` — string name or `{x, y}` map → `Alignment`
- `decodeCrossAxisAlignment`, `decodeMainAxisAlignment`, `decodeMainAxisSize`
- `decodeVerticalDirection`, `decodeAxis`
- `decodeDecoration(value)` — map → `BoxDecoration`
- `decodeTextStyle(theme, value)` — theme style name → `TextStyle`
- `parseDouble(value)` — int / double / "infinity" / "0x…" → `double?`

---

## Dynamic list (`sd_list_builder.dart` core)

`ListBuilder` wraps two callbacks:

| Typedef | Signature | Purpose |
|---------|-----------|---------|
| `ItemDataBuilder` | `Map Function(String id, int index)` | Return item data for index |
| `ItemCountBuilder` | `int Function(String id)` | Return total item count |

`SDListBuilder` (widget) calls these at build-time inside `ListView.builder`.

---

## Sliver support (`sd_sliver.dart`)

`SDSliverDelegate extends SliverChildDelegate` wraps a `JsonViewDataBuilder`
for use with `SliverList` / `SliverGrid`. Implements `shouldRebuild` to avoid
unnecessary rebuilds when data is identical.

---

## Tests (`test/src/widget_test.dart`)

9 widget tests covering:

1. Single `text` widget renders correctly
2. Missing `text` arg → graceful `SizedBox.shrink` fallback
3. Malformed JSON → no crash, renders `SizedBox`
4. Text + Button renders both widgets
5. Button with wrong action args still renders
6. Button tap fires `ActionCallback` with correct `SDActionType`/`reference`
7. `fromViewData` constructor works
8. State rebuild — `JsonViewData.loadJson` called once, `SDWidget.build` called twice (correct)
9. Helper wrapper classes (`JsonViewDataBuilderWrap`, `SDWidgetWrap`) for call counting

---

## Observations & potential improvements

1. **`SDText` — unsafe `args['text']` cast**: `String text = args['text']` will
   throw if `text` is missing or non-String (test 2 expects a `SizedBox` but
   the cast itself would crash before the `build` wrapper catches it — works
   only because `JsonViewDataBuilder.build` catches all exceptions).
2. **`decodeDecoration` always adds a `Border`**: Even when `borderColor` and
   `width` are absent, a 1 px black border is drawn. An `if` guard would be
   cleaner.
3. **`add()` in registry is silently non-overriding**: `putIfAbsent` means a
   second registration for the same key is ignored (with a log warning). This
   can be surprising when trying to override a built-in widget.
4. **`loadZip` misuse**: The method gzip-decodes a UTF-8 encoded version of the
   string, not raw bytes from a network response. Callers sending actual gzip
   bytes would need to convert first.
5. **No `const` constructors on widgets**: All SD widget classes take a `Map`
   argument so they cannot be `const`, but ensuring `BaseJsonWidget`
   implementations are as stateless as possible aids testability.
