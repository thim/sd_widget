# SD Widget

A powerful **Server Driven UI (SDUI)** framework for Flutter that enables dynamic UI creation from JSON configurations. Build flexible, maintainable Flutter applications where UI components can be defined, modified, and delivered from your backend without requiring app updates.

## 🎯 Design Goals

- **Minimal Dependencies**: Lightweight framework with only essential dependencies
- **Developer-Friendly**: Simple, intuitive API that's easy to learn and use
- **Highly Extensible**: Flexible architecture for custom widgets and behaviors

## 🚀 Features

- **JSON-Driven UI**: Create Flutter widgets dynamically from JSON configurations
- **Extensible Widget Registry**: Register custom widgets and extend the framework
- **Action System**: Handle user interactions with a comprehensive action framework
- **Event Tracking**: Built-in event system for analytics and custom behaviors
- **Data Management**: Efficient loading and processing of JSON data (including gzipped content)
- **Type Safety**: Full Dart type safety with comprehensive error handling
- **Hot Reload Support**: Seamless development experience with Flutter's hot reload
- **Comprehensive Widget Set**: Pre-built widgets for common UI patterns

## 📦 Installation

Add `sd_widget` to your `pubspec.yaml`:

```yaml
dependencies:
  sd_widget:
    path: ./path/to/sd_widget  # For local development
```

Then run:
```bash
flutter pub get
```

## 🎯 Quick Start

### 1. Basic Setup

```dart
import 'package:sd_widget/sd_widget.dart';

// Create a registry with default widgets
final registry = defaultWidget();

// Create a data manager
final dataManager = JsonViewData.withRegistry(registry);

// Set up action handling
dataManager.onAction((action) {
  print('Action executed: ${action.type} -> ${action.reference}');
  // Handle navigation, API calls, etc.
});
```

### 2. Load UI from JSON

```dart
// JSON configuration for a simple UI
const jsonConfig = '''
[
  {
    "type": "column",
    "data": {
      "children": [
        {
          "type": "text",
          "data": {
            "text": "Welcome to SD Widget!",
            "style": "headlineLarge"
          }
        },
        {
          "type": "button",
          "data": {
            "text": "Get Started",
            "action": {
              "type": "push_named",
              "reference": "/home"
            }
          }
        }
      ]
    }
  }
]
''';

// Load the configuration
dataManager.loadJson(jsonConfig);

// Get the built widgets
final widgets = dataManager.builders;
```

### 3. Use in Your Flutter App

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('SD Widget Demo')),
        body: SDWidget(
          registry: registry,
          dataManager: dataManager,
        ),
      ),
    );
  }
}
```

## 🏗️ Architecture

### Core Components

#### **JsonViewRegistry**
The central registry that manages widget builders and processes JSON data:

```dart
final registry = JsonViewRegistry(widgetBuilders, jsonProcessor);
registry.add('custom_widget', (args) => CustomWidget(args));
```

#### **JsonViewData**
Manages loading and processing of JSON configurations:

```dart
final jsonString = "{...}";
final viewData = JsonViewData.withRegistry(registry);
viewData.loadJson(jsonString);           // Load from string
```

#### **Action System**
Handle user interactions with a comprehensive action framework:

```dart
// Define actions in JSON
{
  "type": "button",
  "data": {
    "text": "Navigate",
    "data": {
        "style": "outline",
        "text": "Increment",
        "action": {"type": "custom", "reference": "increment"}
    }
  }
}
```

## 🎨 Available Widgets

SD Widget comes with a comprehensive set of pre-built widgets:

| Widget | Description | JSON Type |
|--------|-------------|-----------|
| **Layout** | | |
| `SDColumn` | Vertical layout | `column` |
| `SDRow` | Horizontal layout | `row` |
| `SDContainer` | Container with styling | `container` |
| `SDPadding` | Add padding | `padding` |
| `SDExpanded` | Expandable widget | `expanded` |
| `SDSizedBox` | Fixed size box | `sized_box` |
| **Content** | | |
| `SDText` | Text display | `text` |
| `SDSVG` | SVG images | `svg` |
| `SDButton` | Interactive button | `button` |
| **Lists** | | |
| `SDListView` | Scrollable list | `listview` |
| `SDListTile` | List item | `list_tile` |
| `SDTile` | Custom tile | `tile` |
| `SDListBuilder` | Dynamic list | `list_builder` |
| `SDStack` | Free positioning (children use `positioned`) | `stack` |
| `SDPositioned` | Absolute position inside `stack` | `positioned` |
| `SDImage` | Network image (PNG/JPEG/GIF/WebP) | `image` |
| `SDOpacity` | Opacity around a child | `opacity` |
| `SDRotate` | Rotation in degrees, clockwise | `rotate` |
| `SDTap` | Makes any node tappable (fires an action) | `tap` |
| **Scrolling** | | |
| `SDScroll` | Scrollable content | `scroll` |

## 📋 JSON Configuration Examples

### Simple Text and Button
```json
{
  "type": "column",
  "data": {
    "children": [
      {
        "type": "text",
        "data": {
          "text": "Hello World",
          "style": "headlineLarge"
        }
      },
      {
        "type": "button",
        "data": {
          "text": "Click Me",
          "action": {
            "type": "custom",
            "reference": "show_dialog"
          }
        }
      }
    ]
  }
}
```

### Dynamic List
```json
{
  "type": "container",
  "data": {
    "height": 400.0,
    "width": 200.0,
    "child": {
      "type": "list_builder",
      "data": {
        "id": "list",
        "builder": {
          "type": "list_tile",
          "data": {
            "title": "\$title",
            "subtitle": "\$subtitle",
            "trailing": "\$trailing"
          }
        }
      }
    }
  }
}
```

## 🔧 Custom Widgets

Extend the framework with your own widgets:

```dart
// 1. Create your widget class
class CustomWidget implements BaseJsonWidget {
  final Map<String, dynamic> args;
  
  CustomWidget(this.args);

  @override
  Widget build(BuildContext context) {
    return Container(); // returns the Widget here
  }
}

// 2. Register it
registry.add('custom_widget', (args) => CustomWidget(args));

// 3. Use in JSON
{
  "type": "custom_widget",
  "data": {
    "customProperty": "value"
  }
}
```

## 📐 Contrato com o kanvas

O formato JSON aceito é descrito pelo contrato SDUI v1, mantido no [kanvas](https://github.com/thim/kanvas/tree/main/contracts/sdui/v1) e copiado em `test/contract/sdui/v1` (origem em `SOURCE`).

- `flutter test test/contract_test.dart` renderiza cada exemplo do contrato.
- Exemplos marcados como `planned` dependem de recursos ainda não implementados e ficam pulados.
- Para atualizar a cópia: `tool/sync_contract.sh <ref-do-kanvas>`.

Também do contrato v1:

- `text`: `fontSize`, `fontWeight` (100–900), `fontFamily`, `textAlign`, `height`, `maxLines`, `overflow`.
- `column`/`row`: `spacing`. `expanded`: `flex`. `sized_box`: `child`.
- `container`: `clip`. `decoration`: `shape: circle`, `radius` por canto `[te, td, bd, be]`.
- **Mudança:** `decoration` só desenha borda quando há `borderColor` ou `width` (antes era sempre preta de 1 px).

## 🎬 Action Types

Handle various user interactions:

| Action Type | Description | Example Reference |
|-------------|-------------|-------------------|
| `push_named` | Navigate to named route | `/profile` |
| `open_webview` | Open web view | `https://example.com` |
| `open_url` | Open external URL | `https://flutter.dev` |
| `pop` | Go back | `""` |
| `custom` | Custom action | `show_dialog` |

## 📊 Event System

Track user interactions and custom events:

```dart
// In JSON configuration
{
  "action": {
    "type": "push_named",
    "reference": "/home",
    "event": {
      "name": "navigation_event",
      "metadata": {
        "source": "main_menu",
        "timestamp": "2024-01-01T12:00:00Z"
      }
    }
  }
}

// Handle events
viewData.onAction((action) {
  if (action.hasEvent) {
    final event = action.event!;
    analytics.track(event.name, event.metadata);
  }
});
```

## 🔄 Data Loading

Multiple ways to load UI configurations:

```dart
// From JSON string
viewData.loadJson(jsonString);

// From compressed data
viewData.loadZip(gzippedJsonString);

// Append to existing UI
viewData.loadJson(additionalJson, clearExisting: false);
```

## 🛠️ Development

### Project Structure
```
lib/
├── src/
│   ├── core/              # Core framework components
│   │   ├── sd_action.dart     # Action system
│   │   ├── sd_base.dart       # Base interfaces
│   │   ├── sd_data.dart       # Data management
│   │   ├── sd_event.dart      # Event system
│   │   ├── sd_list_builder.dart # List building utilities
│   │   └── sd_registry.dart   # Widget registry
│   └── ui/                # UI components
│       ├── widgets/           # Built-in widgets
│       ├── default_registry.dart # Default widget registry
│       ├── sd_data_builder.dart  # Data builder UI
│       ├── sd_sliver.dart        # Sliver widgets
│       └── sd_widget.dart        # Main widget
└── sd_widget.dart         # Main library export
```

### Running Tests
```bash
flutter test
```

### Example App
Check the `example/` directory for a complete demo application.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Example**: Check the `/example` folder for detailed guides
- **Issues**: Report bugs and request features on GitHub Issues

## 🙏 Acknowledgments

- Built with ❤️ using Flutter
- Inspired by server-driven UI patterns from modern mobile development
- Thanks to the Flutter community for continuous inspiration

---

**Ready to build dynamic UIs?** Start with the [Quick Start](#-quick-start) guide and explore the power of server-driven UI with SD Widget!
