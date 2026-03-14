import 'package:flutter_test/flutter_test.dart';
import 'package:sd_widget/sd_widget.dart';

void main() {
  group('SDActionType.decodeAction', () {
    test('null returns custom', () {
      expect(SDActionType.decodeAction(null), SDActionType.custom);
    });

    test('empty string returns custom', () {
      expect(SDActionType.decodeAction(''), SDActionType.custom);
    });

    test('case insensitive matching', () {
      expect(SDActionType.decodeAction('PUSH_NAMED'), SDActionType.pushNamed);
      expect(SDActionType.decodeAction('Open_WebView'), SDActionType.pushWebView);
      expect(SDActionType.decodeAction('POP'), SDActionType.pop);
    });

    test('all known type names', () {
      expect(SDActionType.decodeAction('push_named'), SDActionType.pushNamed);
      expect(SDActionType.decodeAction('open_webview'), SDActionType.pushWebView);
      expect(SDActionType.decodeAction('open_url'), SDActionType.pushExternal);
      expect(SDActionType.decodeAction('pop'), SDActionType.pop);
      expect(SDActionType.decodeAction('custom'), SDActionType.custom);
    });

    test('unknown string returns custom', () {
      expect(SDActionType.decodeAction('navigate'), SDActionType.custom);
    });
  });

  group('SDAction.fromMap', () {
    test('null returns null', () {
      expect(SDAction.fromMap(null), isNull);
    });

    test('valid push_named action', () {
      final action = SDAction.fromMap({'type': 'push_named', 'reference': '/home'});
      expect(action, isNotNull);
      expect(action!.type, SDActionType.pushNamed);
      expect(action.reference, '/home');
    });

    test('valid pop action', () {
      final action = SDAction.fromMap({'type': 'pop', 'reference': ''});
      expect(action!.type, SDActionType.pop);
    });

    test('valid open_webview action', () {
      final action = SDAction.fromMap({'type': 'open_webview', 'reference': 'https://example.com'});
      expect(action!.type, SDActionType.pushWebView);
    });

    test('valid open_url action', () {
      final action = SDAction.fromMap({'type': 'open_url', 'reference': 'https://example.com'});
      expect(action!.type, SDActionType.pushExternal);
    });

    test('valid custom action', () {
      final action = SDAction.fromMap({'type': 'custom', 'reference': 'increment'});
      expect(action!.type, SDActionType.custom);
      expect(action.reference, 'increment');
    });

    test('unknown type falls back to custom', () {
      final action = SDAction.fromMap({'type': 'unknown_xyz', 'reference': 'r'});
      expect(action!.type, SDActionType.custom);
    });

    test('missing reference defaults to empty string', () {
      final action = SDAction.fromMap({'type': 'pop'});
      expect(action!.reference, '');
    });

    test('with label', () {
      final action = SDAction.fromMap({'type': 'custom', 'reference': 'r', 'label': 'Tap me'});
      expect(action!.label, 'Tap me');
    });

    test('without label is null', () {
      final action = SDAction.fromMap({'type': 'custom', 'reference': 'r'});
      expect(action!.label, isNull);
    });

    test('with nested event', () {
      final action = SDAction.fromMap({
        'type': 'custom',
        'reference': 'ev',
        'event': {'name': 'click', 'metadata': {'key': 'value'}},
      });
      expect(action!.hasEvent, isTrue);
      expect(action.event!.name, 'click');
      expect(action.event!.metadata['key'], 'value');
    });

    test('hasEvent is false when no event', () {
      final action = SDAction.fromMap({'type': 'custom', 'reference': 'r'});
      expect(action!.hasEvent, isFalse);
    });

    test('with eventProperties key (alias)', () {
      final action = SDAction.fromMap({
        'type': 'custom',
        'reference': 'r',
        'eventProperties': {'name': 'alias_event'},
      });
      expect(action!.hasEvent, isTrue);
      expect(action.event!.name, 'alias_event');
    });

    test('toString contains type and reference', () {
      final action = SDAction.fromMap({'type': 'custom', 'reference': 'myRef'})!;
      expect(action.toString(), contains('myRef'));
    });
  });

  group('SDEvent.fromMap', () {
    test('null returns null', () {
      expect(SDEvent.fromMap(null), isNull);
    });

    test('non-Map types return null', () {
      expect(SDEvent.fromMap('string'), isNull);
      expect(SDEvent.fromMap(42), isNull);
      expect(SDEvent.fromMap([1, 2, 3]), isNull);
      expect(SDEvent.fromMap(true), isNull);
    });

    test('missing name returns null', () {
      expect(SDEvent.fromMap({'metadata': {}}), isNull);
    });

    test('valid event with metadata', () {
      final event = SDEvent.fromMap({'name': 'purchase', 'metadata': {'amount': 99, 'currency': 'USD'}});
      expect(event, isNotNull);
      expect(event!.name, 'purchase');
      expect(event.metadata['amount'], 99);
      expect(event.metadata['currency'], 'USD');
    });

    test('valid event without metadata defaults to empty map', () {
      final event = SDEvent.fromMap({'name': 'click'});
      expect(event, isNotNull);
      expect(event!.name, 'click');
      expect(event.metadata, isEmpty);
    });

    test('metadata not a Map defaults to empty', () {
      final event = SDEvent.fromMap({'name': 'ev', 'metadata': 'not-a-map'});
      expect(event!.metadata, isEmpty);
    });

    test('metadata as list defaults to empty', () {
      final event = SDEvent.fromMap({'name': 'ev', 'metadata': [1, 2, 3]});
      expect(event!.metadata, isEmpty);
    });
  });
}
