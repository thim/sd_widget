import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sd_widget/sd_widget.dart';
import 'package:sd_widget/src/ui/widgets/widgets.dart' show SDText;

String screen(String text, {int version = 1}) => jsonEncode({
      'sdui': version,
      'type': 'text',
      'data': {'text': text},
    });

/// Servidor falso: conta chamadas, responde 304 quando o ETag bate.
class FakeServer {
  final Map<String, String> layouts = {};
  final List<(String, String?)> calls = [];
  Object? failWith;
  Completer<void>? gate;

  String etagOf(String key) => '"${layouts[key].hashCode}"';

  Future<SDLayoutFetchResult> fetch(String key, {String? etag}) async {
    calls.add((key, etag));
    if (gate != null) await gate!.future;
    if (failWith != null) throw failWith!;
    final body = layouts[key];
    if (body == null) throw Exception('404 $key');
    final tag = etagOf(key);
    if (etag == tag) return const SDLayoutNotModified();
    return SDLayoutFetched(body, etag: tag);
  }
}

/// Armazenamento persistente falso (como shared_preferences).
class FakeKv {
  final Map<String, String> data = {};
  KeyValueLayoutStore store() => KeyValueLayoutStore(
        read: (k) async => data[k],
        write: (k, v) async => data[k] = v,
        remove: (k) async => data.remove(k),
      );
}

void main() {
  late FakeServer server;
  late FakeKv kv;
  late DateTime now;

  SDLayoutRepository repo({Duration maxAge = const Duration(minutes: 5)}) => SDLayoutRepository(
        fetch: server.fetch,
        store: kv.store(),
        maxAge: maxAge,
        clock: () => now,
      );

  setUp(() {
    server = FakeServer()..layouts['home'] = screen('v1');
    kv = FakeKv();
    now = DateTime.utc(2026, 11, 27, 10);
  });

  test('primeira abertura baixa e guarda; depois serve da memória sem rede', () async {
    final r = repo();
    final first = await r.get('home');
    expect(first.source, SDLayoutSource.network);
    expect(server.calls, [('home', null)]);
    expect(kv.data.keys, ['sdui.layout.home']);

    final again = await r.get('home');
    expect(again.source, SDLayoutSource.memory);
    expect(again.stale, isFalse);
    expect(server.calls, hasLength(1));
    expect(r.peek('home')!.json, screen('v1'));
  });

  test('app reaberto: lê do armazenamento persistente', () async {
    await repo().get('home');
    final reopened = repo();
    expect(reopened.peek('home'), isNull, reason: 'memória começa vazia');
    final s = await reopened.get('home');
    expect(s.source, SDLayoutSource.store);
    expect(server.calls, hasLength(1));
  });

  test('cache velho: mostra o cache e revalida com ETag (304 não emite de novo)', () async {
    final r = repo();
    await r.get('home');
    now = now.add(const Duration(minutes: 10));

    final emitted = await r.watch('home').toList();
    expect(emitted, hasLength(1));
    expect(emitted.single.stale, isTrue);
    expect(server.calls.last, ('home', server.etagOf('home')));
    // 304 renova a idade.
    expect(r.peek('home')!.stale, isFalse);
  });

  test('layout mudou no servidor: emite o cache e depois o novo', () async {
    final r = repo();
    await r.get('home');
    server.layouts['home'] = screen('v2');
    now = now.add(const Duration(minutes: 10));

    final emitted = await r.watch('home').toList();
    expect(emitted.map((s) => jsonDecode(s.json)['data']['text']), ['v1', 'v2']);
    expect(emitted.last.source, SDLayoutSource.network);
    expect(CachedLayout.fromMap(jsonDecode(kv.data['sdui.layout.home']!))!.json, screen('v2'));
  });

  test('sem rede: fica no último layout bom; sem cache, falha', () async {
    final r = repo();
    await r.get('home');
    now = now.add(const Duration(hours: 1));
    server.failWith = Exception('offline');
    final s = await r.get('home');
    expect(jsonDecode(s.json)['data']['text'], 'v1');
    expect(s.stale, isTrue);

    expect(repo().get('outra'), throwsException);
  });

  test('não guarda JSON quebrado nem versão do contrato que o app não conhece', () async {
    final r = repo();
    await r.get('home');
    now = now.add(const Duration(hours: 1));

    server.layouts['home'] = '{"type": "text", ';
    expect((await r.get('home')).json, screen('v1'));

    server.layouts['home'] = screen('v9', version: 2);
    expect((await r.get('home')).json, screen('v1'));
    expect(() => r.validate(screen('x', version: 2)), throwsA(isA<SDLayoutException>()));
    expect(CachedLayout.fromMap(jsonDecode(kv.data['sdui.layout.home']!))!.json, screen('v1'));
  });

  test('buscas simultâneas da mesma tela viram uma só', () async {
    final r = repo();
    server.gate = Completer();
    final a = r.get('home');
    final b = r.get('home');
    server.gate!.complete();
    expect((await a).json, (await b).json);
    expect(server.calls, hasLength(1));
  });

  test('forceRefresh, prefetch e invalidate', () async {
    server.layouts['perfil'] = screen('perfil');
    final r = repo();
    await r.prefetch(['home', 'perfil', 'nao-existe']);
    expect(r.peek('perfil'), isNotNull);

    await r.get('home', forceRefresh: true);
    expect(server.calls.where((c) => c.$1 == 'home'), hasLength(2));

    await r.invalidate('home');
    expect(r.peek('home'), isNull);
    expect(kv.data.containsKey('sdui.layout.home'), isFalse);
  });

  test('memória descarta o menos usado', () async {
    final m = MemoryLayoutStore(capacity: 2);
    CachedLayout l(String s) => CachedLayout(json: s, fetchedAt: now);
    await m.write('a', l('a'));
    await m.write('b', l('b'));
    await m.read('a'); // a vira o mais recente
    await m.write('c', l('c'));
    expect(m.peek('b'), isNull);
    expect(m.peek('a'), isNotNull);
    expect(m.length, 2);
  });

  test('entrada corrompida no armazenamento é ignorada', () async {
    kv.data['sdui.layout.home'] = 'lixo';
    final s = await repo().get('home');
    expect(s.source, SDLayoutSource.network);
  });

  group('SDLayoutView', () {
    Widget app(SDLayoutRepository r, {String key = 'home'}) => MaterialApp(
          home: Scaffold(
            body: SDLayoutView(
              repository: r,
              layoutKey: key,
              registry: defaultWidget(),
              placeholder: (_) => const Text('carregando'),
              errorBuilder: (_, e, retry) => TextButton(onPressed: retry, child: const Text('tentar de novo')),
            ),
          ),
        );

    testWidgets('placeholder, depois o layout', (tester) async {
      final r = repo();
      await tester.pumpWidget(app(r));
      expect(find.text('carregando'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('v1'), findsOneWidget);
    });

    testWidgets('com cache em memória desenha já no primeiro frame', (tester) async {
      final r = repo();
      await tester.runAsync(() => r.get('home'));
      await tester.pumpWidget(app(r));
      expect(find.text('v1'), findsOneWidget);
      expect(find.text('carregando'), findsNothing);
    });

    testWidgets('troca pelo layout novo quando a revalidação traz mudança', (tester) async {
      final r = repo();
      await tester.runAsync(() => r.get('home'));
      server.layouts['home'] = screen('v2');
      now = now.add(const Duration(minutes: 10));
      await tester.pumpWidget(app(r));
      expect(find.text('v1'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('v2'), findsOneWidget);
    });

    testWidgets('erro sem cache e nova tentativa', (tester) async {
      server.failWith = Exception('offline');
      final r = repo();
      await tester.pumpWidget(app(r));
      await tester.pumpAndSettle();
      expect(find.text('tentar de novo'), findsOneWidget);

      server.failWith = null;
      await tester.tap(find.text('tentar de novo'));
      await tester.pumpAndSettle();
      expect(find.text('v1'), findsOneWidget);
    });

    testWidgets('rebuild do pai não reprocessa o JSON', (tester) async {
      server.layouts['contado'] = jsonEncode({
        'type': 'contador',
        'data': {'text': 'v1'},
      });
      final r = repo();
      await tester.runAsync(() => r.get('contado'));
      var parsed = 0;
      final registry = defaultWidget();
      registry.add('contador', (Map args) {
        parsed++;
        return SDText(args);
      });
      Widget build() => MaterialApp(
            home: SDLayoutView(repository: r, layoutKey: 'contado', registry: registry),
          );
      await tester.pumpWidget(build());
      await tester.pumpWidget(build());
      await tester.pumpWidget(build());
      expect(find.text('v1'), findsOneWidget);
      expect(parsed, 1);
    });
  });
}
