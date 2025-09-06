import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sd_widget/sd_widget.dart';

void main() {
  testWidgets('Creating a layout with Text', (tester) async {
    const json = '''{
      "type": "text",
      "data": {
        "text":"T"
      }
    }''';

    await tester
        .pumpWidget(Directionality(textDirection: TextDirection.ltr, child: SDWidget.fromJson(json, viewRegistry: defaultWidget())));
    final titleFinder = find.text('T');
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('Creating a layout with Text and missing args', (tester) async {
    const json = '''{
      "type": "text",
      "data": {
      }
    }''';

    await tester
        .pumpWidget(Directionality(textDirection: TextDirection.ltr, child: SDWidget.fromJson(json, viewRegistry: defaultWidget())));
    final titleFinder = find.byType(Text);
    expect(titleFinder, findsNothing);
    final findBox = find.byType(SizedBox);
    expect(findBox, findsOneWidget);
  });

  testWidgets('Json with wrong format', (tester) async {
    const json = '''{
      "type": "text"; <- wrong char here
      "data": {
        "text":"T"
      }
    }''';

    await tester
        .pumpWidget(Directionality(textDirection: TextDirection.ltr, child: SDWidget.fromJson(json, viewRegistry: defaultWidget())));
    final findBox = find.byType(SizedBox);
    expect(findBox, findsOneWidget);
  });

  testWidgets('Creating a layout with Text and Button', (tester) async {
    const json = '''[
    {
        "type": "text",
        "data": {
            "text": "The quick fox jumps over the lazy dog."
        }
    },
    {
        "type": "button",
        "data": {
            "text": "my button"
        }
    }
    ]''';

    await tester
        .pumpWidget(Directionality(textDirection: TextDirection.ltr, child: SDWidget.fromJson(json, viewRegistry: defaultWidget())));
    final findText = find.text("The quick fox jumps over the lazy dog.");
    expect(findText, findsOneWidget);

    final findButtonText = find.text("my button");
    expect(findButtonText, findsOneWidget);

    final findButton = find.byType(FilledButton);
    expect(findButton, findsOneWidget);
  });

  testWidgets('Creating a layout with Text and Button and wrong args', (tester) async {
    const json = '''[
    {
        "type": "text",
        "data": {
            "text": "The quick fox jumps over the lazy dog."
        }
    },
    {
        "type": "button",
        "data": {
            "text": "my button",
            "action": {
                "key": "custom",
                "reference": 1234
            }
        }
    }
    ]''';

    await tester
        .pumpWidget(Directionality(textDirection: TextDirection.ltr, child: SDWidget.fromJson(json, viewRegistry: defaultWidget())));
    final findText = find.text("The quick fox jumps over the lazy dog.");
    expect(findText, findsOneWidget);

    final findButtonText = find.text("my button");
    expect(findButtonText, findsOneWidget);

    final findButton = find.byType(FilledButton);
    expect(findButton, findsOneWidget);
  });

  testWidgets('Creating a layout with Button and action, using fromJson', (tester) async {
    const json = '''[
    {
        "type": "button",
        "data": {
            "text": "my button",
            "action": {
                "key": "custom",
                "reference": "increment"
            }
        }
    }
    ]''';

    final registry = defaultWidget();
    registry.onAction((action) {
      expect(action.type, SDActionType.custom);
      expect(action.reference, "increment");
    });
    await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: SDWidget.fromJson(json, viewRegistry: registry)));

    final findButtonText = find.text("my button");
    expect(findButtonText, findsOneWidget);

    final findButton = find.byType(FilledButton);
    expect(findButton, findsOneWidget);

    await tester.tap(findButton);
  });

  testWidgets('Creating a layout with Button and action, using fromViewData', (tester) async {
    const json = '''[
    {
        "type": "text",
        "data": {
            "text": "The quick fox jumps over the lazy dog."
        }
    },
    {
        "type": "button",
        "data": {
            "text": "my button"
        }
    }
    ]''';
    final viewData = JsonViewDataBuilder(defaultWidget());
    viewData.loadJson(json);

    await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: SDWidget.fromViewData(viewData)));
    final findText = find.text("The quick fox jumps over the lazy dog.");
    expect(findText, findsOneWidget);

    final findButtonText = find.text("my button");
    expect(findButtonText, findsOneWidget);

    final findButton = find.byType(FilledButton);
    expect(findButton, findsOneWidget);
  });

  testWidgets('Creating a layout with Text and Button, refreshing the view', (tester) async {
    const json = '''[
    {
        "type": "text",
        "data": {
            "text": "The quick fox jumps over the lazy dog."
        }
    },
    {
        "type": "button",
        "data": {
            "text": "my button"
        }
    }
    ]''';
    final viewData = JsonViewDataBuilderWrap(defaultWidget());
    viewData.loadJson(json);

    final builder = StatefulBuilder(
      builder: (context, setState) {
        final sd = SDWidgetWrap.fromViewData(viewData);
        return Column(children: [
          sd,
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            child: const Text('Rebuild'),
          ),
        ]);
      },
    );

    await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: builder));
    final findButtonText = find.text("Rebuild");
    expect(findButtonText, findsOneWidget);

    await tester.tap(findButtonText);
    await tester.pump();

    expect(JsonViewDataBuilderWrap.counter, 1);
    expect(SDWidgetWrap.counter, 2);
  });
}

class JsonViewDataBuilderWrap extends JsonViewDataBuilder {
  static int counter = 0;

  JsonViewDataBuilderWrap(super.registry);

  @override
  void loadJson(String jsonString, {bool clearExisting = true}) {
    counter++;
    super.loadJson(jsonString);
  }
}

class SDWidgetWrap extends SDWidget {
  static int counter = 0;

  SDWidgetWrap.fromViewData(
    super.viewData, {
    super.key,
  }) : super.fromViewData();

  SDWidgetWrap.fromJson(
    super.json, {
    required super.viewRegistry,
    super.key,
  }) : super.fromJson();

  @override
  Widget build(BuildContext context) {
    counter++;
    return super.build(context);
  }
}
