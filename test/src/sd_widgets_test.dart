import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sd_widget/sd_widget.dart';

// ── helpers ──────────────────────────────────────────────────────────────────

/// Wraps a widget with the minimum required Directionality.
Widget wrap(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

/// Wraps with MaterialApp + Scaffold to provide MediaQuery and layout bounds.
Widget wrapMaterial(Widget child) => MaterialApp(home: Scaffold(body: child));

/// Builds a widget from a raw JSON string using the default registry.
Widget fromJson(String json) =>
    wrap(SDWidget.fromJson(json, viewRegistry: defaultWidget()));

// ── tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── SDText ─────────────────────────────────────────────────────────────────
  group('SDText', () {
    testWidgets('renders text value', (tester) async {
      await tester.pumpWidget(fromJson('{"type":"text","data":{"text":"Hello"}}'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('missing text key returns SizedBox.shrink (no crash)', (tester) async {
      await tester.pumpWidget(fromJson('{"type":"text","data":{}}'));
      expect(find.byType(Text), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('variable substitution with item_data', (tester) async {
      final viewData = JsonViewDataBuilder(defaultWidget());
      viewData.fromList([
        {'type': 'text', 'data': {'text': '\$greeting'}},
      ], itemData: {'\$greeting': 'World'});
      await tester.pumpWidget(wrap(SDWidget.fromViewData(viewData)));
      expect(find.text('World'), findsOneWidget);
    });

    testWidgets('non-substituted text (no \$ prefix) renders literally', (tester) async {
      await tester.pumpWidget(fromJson('{"type":"text","data":{"text":"literal"}}'));
      expect(find.text('literal'), findsOneWidget);
    });
  });

  // ── SDButton ───────────────────────────────────────────────────────────────
  group('SDButton', () {
    testWidgets('default style is FilledButton', (tester) async {
      await tester.pumpWidget(fromJson('{"type":"button","data":{"text":"Go"}}'));
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('elevated style', (tester) async {
      await tester.pumpWidget(
          fromJson('{"type":"button","data":{"text":"Go","style":"elevated"}}'));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('outline style', (tester) async {
      await tester.pumpWidget(
          fromJson('{"type":"button","data":{"text":"Go","style":"outline"}}'));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('text style', (tester) async {
      await tester.pumpWidget(
          fromJson('{"type":"button","data":{"text":"Go","style":"text"}}'));
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('missing text renders empty string, not "null"', (tester) async {
      await tester.pumpWidget(fromJson('{"type":"button","data":{}}'));
      expect(find.text('null'), findsNothing);
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('button action fires callback on tap', (tester) async {
      const json = '''[{
        "type": "button",
        "data": {"text": "tap", "action": {"type": "custom", "reference": "doSomething"}}
      }]''';
      SDAction? received;
      final registry = defaultWidget();
      registry.onAction((a) => received = a);
      await tester.pumpWidget(
          wrap(SDWidget.fromJson(json, viewRegistry: registry)));
      await tester.tap(find.byType(FilledButton));
      expect(received, isNotNull);
      expect(received!.type, SDActionType.custom);
      expect(received!.reference, 'doSomething');
    });
  });

  // ── SDContainer ────────────────────────────────────────────────────────────
  group('SDContainer', () {
    testWidgets('renders child', (tester) async {
      const json =
          '{"type":"container","data":{"child":{"type":"text","data":{"text":"inside"}}}}';
      await tester.pumpWidget(fromJson(json));
      expect(find.text('inside'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('renders without child', (tester) async {
      await tester.pumpWidget(fromJson('{"type":"container","data":{}}'));
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('applies padding', (tester) async {
      const json =
          '{"type":"container","data":{"padding":16.0,"child":{"type":"text","data":{"text":"p"}}}}';
      await tester.pumpWidget(fromJson(json));
      expect(find.text('p'), findsOneWidget);
    });
  });

  // ── SDColumn ───────────────────────────────────────────────────────────────
  group('SDColumn', () {
    testWidgets('renders multiple children', (tester) async {
      const json = '''{"type":"column","data":{"children":[
        {"type":"text","data":{"text":"A"}},
        {"type":"text","data":{"text":"B"}}
      ]}}''';
      await tester.pumpWidget(fromJson(json));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('missing children renders empty Column', (tester) async {
      await tester.pumpWidget(fromJson('{"type":"column","data":{}}'));
      // JsonViewDataBuilder.build() wraps multiple in Column; 0 items → SizedBox.shrink
      // 0 items → builders.isEmpty → SizedBox.shrink
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('respects crossAxisAlignment arg', (tester) async {
      const json = '''{"type":"column","data":{"crossAxisAlignment":"start","children":[
        {"type":"text","data":{"text":"aligned"}}
      ]}}''';
      await tester.pumpWidget(fromJson(json));
      final col = tester.widget<Column>(find.byType(Column));
      expect(col.crossAxisAlignment, CrossAxisAlignment.start);
    });
  });

  // ── SDRow ──────────────────────────────────────────────────────────────────
  group('SDRow', () {
    testWidgets('renders children side by side', (tester) async {
      const json = '''{"type":"row","data":{"children":[
        {"type":"text","data":{"text":"X"}},
        {"type":"text","data":{"text":"Y"}}
      ]}}''';
      await tester.pumpWidget(fromJson(json));
      expect(find.text('X'), findsOneWidget);
      expect(find.text('Y'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('propagates item_data to children (parity with SDColumn)', (tester) async {
      final viewData = JsonViewDataBuilder(defaultWidget());
      viewData.fromList([
        {
          'type': 'row',
          'data': {
            'children': [
              {'type': 'text', 'data': {'text': '\$val'}}
            ]
          }
        }
      ], itemData: {'\$val': 'Propagated'});
      await tester.pumpWidget(wrap(SDWidget.fromViewData(viewData)));
      expect(find.text('Propagated'), findsOneWidget);
    });

    testWidgets('missing children renders empty Row', (tester) async {
      await tester.pumpWidget(fromJson('{"type":"row","data":{}}'));
      expect(find.byType(Row), findsOneWidget);
    });
  });

  // ── SDPadding ──────────────────────────────────────────────────────────────
  group('SDPadding', () {
    testWidgets('renders child inside Padding', (tester) async {
      const json =
          '{"type":"padding","data":{"padding":8.0,"child":{"type":"text","data":{"text":"padded"}}}}';
      await tester.pumpWidget(fromJson(json));
      expect(find.text('padded'), findsOneWidget);
      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('padding amount is applied', (tester) async {
      const json =
          '{"type":"padding","data":{"padding":24.0,"child":{"type":"text","data":{"text":"p"}}}}';
      await tester.pumpWidget(fromJson(json));
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(24.0));
    });
  });

  // ── SDSizedBox ─────────────────────────────────────────────────────────────
  group('SDSizedBox', () {
    testWidgets('renders SizedBox with given dimensions', (tester) async {
      const json = '{"type":"sized_box","data":{"width":100.0,"height":50.0}}';
      await tester.pumpWidget(wrap(Center(
          child: SDWidget.fromJson(json, viewRegistry: defaultWidget()))));
      final box = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(box.width, 100.0);
      expect(box.height, 50.0);
    });

    testWidgets('zero dimensions returns SizedBox.shrink', (tester) async {
      await tester.pumpWidget(fromJson('{"type":"sized_box","data":{}}'));
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  // ── SDScroll ───────────────────────────────────────────────────────────────
  group('SDScroll', () {
    testWidgets('renders children inside SingleChildScrollView', (tester) async {
      const json = '''{"type":"scroll","data":{"children":[
        {"type":"text","data":{"text":"scrollable"}}
      ]}}''';
      await tester.pumpWidget(wrapMaterial(
          SDWidget.fromJson(json, viewRegistry: defaultWidget())));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('scrollable'), findsOneWidget);
    });

    testWidgets('vertical axis uses Column layout inside scroll', (tester) async {
      const json = '''{"type":"scroll","data":{"axis":"vertical","children":[
        {"type":"text","data":{"text":"v"}}
      ]}}''';
      await tester.pumpWidget(wrapMaterial(
          SDWidget.fromJson(json, viewRegistry: defaultWidget())));
      final scrollView =
          tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(scrollView.scrollDirection, Axis.vertical);
      expect(find.text('v'), findsOneWidget);
    });

    testWidgets('default (horizontal) axis uses Row layout inside scroll', (tester) async {
      const json = '''{"type":"scroll","data":{"children":[
        {"type":"text","data":{"text":"h"}}
      ]}}''';
      await tester.pumpWidget(wrapMaterial(
          SDWidget.fromJson(json, viewRegistry: defaultWidget())));
      final scrollView =
          tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(scrollView.scrollDirection, Axis.horizontal);
    });
  });

  // ── SDExpanded ─────────────────────────────────────────────────────────────
  group('SDExpanded', () {
    testWidgets('renders inside Row', (tester) async {
      const json = '''{"type":"row","data":{"children":[
        {"type":"expanded","data":{"child":{"type":"text","data":{"text":"expanded"}}}}
      ]}}''';
      await tester.pumpWidget(wrapMaterial(
          SDWidget.fromJson(json, viewRegistry: defaultWidget())));
      expect(find.byType(Expanded), findsOneWidget);
      expect(find.text('expanded'), findsOneWidget);
    });

    testWidgets('flex parameter is applied from JSON', (tester) async {
      const json = '''{"type":"row","data":{"children":[
        {"type":"expanded","data":{"flex":3,"child":{"type":"text","data":{"text":"flex"}}}}
      ]}}''';
      await tester.pumpWidget(wrapMaterial(
          SDWidget.fromJson(json, viewRegistry: defaultWidget())));
      final expanded = tester.widget<Expanded>(find.byType(Expanded));
      expect(expanded.flex, 3);
    });

    testWidgets('default flex is 1', (tester) async {
      const json = '''{"type":"row","data":{"children":[
        {"type":"expanded","data":{"child":{"type":"text","data":{"text":"d"}}}}
      ]}}''';
      await tester.pumpWidget(wrapMaterial(
          SDWidget.fromJson(json, viewRegistry: defaultWidget())));
      final expanded = tester.widget<Expanded>(find.byType(Expanded));
      expect(expanded.flex, 1);
    });
  });

  // ── SDListView ─────────────────────────────────────────────────────────────
  group('SDListView', () {
    testWidgets('renders ListView.separated', (tester) async {
      const json = '''{"type":"listview","data":{"children":[
        {"type":"text","data":{"text":"item1"}},
        {"type":"text","data":{"text":"item2"}}
      ]}}''';
      await tester.pumpWidget(wrapMaterial(
          SDWidget.fromJson(json, viewRegistry: defaultWidget())));
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('propagates item_data to children', (tester) async {
      final viewData = JsonViewDataBuilder(defaultWidget());
      viewData.fromList([
        {
          'type': 'listview',
          'data': {
            'children': [
              {'type': 'text', 'data': {'text': '\$item'}}
            ]
          }
        }
      ], itemData: {'\$item': 'ListItem'});
      await tester.pumpWidget(wrapMaterial(SDWidget.fromViewData(viewData)));
      expect(find.text('ListItem'), findsOneWidget);
    });
  });

  // ── SDTile ─────────────────────────────────────────────────────────────────
  group('SDTile', () {
    testWidgets('missing img returns SizedBox.shrink (no crash)', (tester) async {
      const json = '{"type":"tile","data":{"title":"T","subtitle":"S"}}';
      await tester.pumpWidget(fromJson(json));
      // SizedBox.shrink is returned when img is null
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });
  });

  // ── SDListTile ─────────────────────────────────────────────────────────────
  group('SDListTile', () {
    testWidgets('renders with static text', (tester) async {
      const json =
          '{"type":"list_tile","data":{"title":"My Title","subtitle":"Sub","trailing":"Trail"}}';
      await tester.pumpWidget(fromJson(json));
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('My Title'), findsOneWidget);
      expect(find.text('Sub'), findsOneWidget);
      expect(find.text('Trail'), findsOneWidget);
    });

    testWidgets('variable substitution with item_data', (tester) async {
      final viewData = JsonViewDataBuilder(defaultWidget());
      viewData.fromList([
        {
          'type': 'list_tile',
          'data': {'title': '\$name', 'subtitle': 'fixed', 'trailing': ''}
        }
      ], itemData: {'\$name': 'Alice'});
      await tester.pumpWidget(wrap(SDWidget.fromViewData(viewData)));
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('fixed'), findsOneWidget);
    });

    testWidgets('missing keys render empty string (no crash)', (tester) async {
      await tester.pumpWidget(fromJson('{"type":"list_tile","data":{}}'));
      expect(find.byType(ListTile), findsOneWidget);
    });
  });

  // ── SDListBuilder ──────────────────────────────────────────────────────────
  group('SDListBuilder', () {
    testWidgets('renders empty ListView when registry has no data', (tester) async {
      const json =
          '{"type":"list_builder","data":{"id":"test","builder":{"type":"text","data":{"text":"item"}}}}';
      await tester.pumpWidget(wrapMaterial(
          SDWidget.fromJson(json, viewRegistry: defaultWidget())));
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders items from listDataBuilder', (tester) async {
      final items = ['Alpha', 'Beta', 'Gamma'];
      const json =
          '{"type":"list_builder","data":{"id":"fruits","builder":{"type":"text","data":{"text":"\$label"}}}}';
      await tester.pumpWidget(wrapMaterial(SDWidget.listDataBuilder(
        fromJson: json,
        viewRegistry: defaultWidget(),
        itemCount: (id) => items.length,
        itemData: (id, index) => {'\$label': items[index]},
      )));
      await tester.pump();
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });
  });

  // ── JsonViewRegistry ───────────────────────────────────────────────────────
  group('JsonViewRegistry', () {
    test('add() does not throw on duplicate key', () {
      final registry = defaultWidget();
      expect(
        () {
          registry.add('text', (_) => _StubWidget());
          registry.add('text', (_) => _StubWidget());
        },
        returnsNormally,
      );
    });

    test('add() second registration for same key is ignored (first wins)', () {
      final registry = defaultWidget();
      int first = 0, second = 0;

      registry.add('_probe', (_) {
        first++;
        return _StubWidget();
      });
      registry.add('_probe', (_) {
        second++;
        return _StubWidget();
      });

      final viewData = JsonViewDataBuilder(registry);
      viewData.loadJson('{"type":"_probe","data":{}}');

      expect(viewData.length, 1);
      expect(first, 1);
      expect(second, 0);
    });
  });

  // ── SDSliverDelegate ───────────────────────────────────────────────────────
  group('SDSliverDelegate', () {
    test('shouldRebuild returns false when widgetData is the same object', () {
      final viewData = JsonViewDataBuilder(defaultWidget());
      final d1 = SDSliverDelegate(viewData);
      final d2 = SDSliverDelegate(viewData);
      expect(d2.shouldRebuild(d1), isFalse);
    });

    test('shouldRebuild returns false for two different objects with same length', () {
      final v1 = JsonViewDataBuilder(defaultWidget())
        ..loadJson('[{"type":"text","data":{"text":"A"}}]');
      final v2 = JsonViewDataBuilder(defaultWidget())
        ..loadJson('[{"type":"text","data":{"text":"B"}}]');

      expect(SDSliverDelegate(v2).shouldRebuild(SDSliverDelegate(v1)), isFalse);
    });

    test('shouldRebuild returns true when length differs', () {
      final v1 = JsonViewDataBuilder(defaultWidget())
        ..loadJson('[{"type":"text","data":{"text":"A"}}]');
      final v2 = JsonViewDataBuilder(defaultWidget())
        ..loadJson('[{"type":"text","data":{"text":"A"}},{"type":"text","data":{"text":"B"}}]');

      expect(SDSliverDelegate(v2).shouldRebuild(SDSliverDelegate(v1)), isTrue);
    });

    test('estimatedChildCount matches builder count', () {
      final viewData = JsonViewDataBuilder(defaultWidget())
        ..loadJson('[{"type":"text","data":{"text":"A"}},{"type":"text","data":{"text":"B"}}]');
      final delegate = SDSliverDelegate(viewData);
      expect(delegate.estimatedChildCount, 2);
    });
  });

  // ── loadZip error handling ─────────────────────────────────────────────────
  group('JsonViewData.loadZip', () {
    test('invalid (non-gzip) input does not throw', () {
      final viewData = JsonViewDataBuilder(defaultWidget());
      expect(() => viewData.loadZip('not-gzipped'), returnsNormally);
    });

    test('after failed loadZip the builder list is empty', () {
      final viewData = JsonViewDataBuilder(defaultWidget());
      viewData.loadZip('garbage');
      expect(viewData.length, 0);
    });
  });
}

// ── test helpers ──────────────────────────────────────────────────────────────

/// Minimal BaseJsonWidget implementation used in registry tests.
class _StubWidget implements BaseJsonWidget {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
