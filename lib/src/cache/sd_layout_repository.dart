import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:sd_widget/src/cache/sd_layout_store.dart';

/// Resposta de [SDLayoutFetcher].
sealed class SDLayoutFetchResult {
  const SDLayoutFetchResult();
}

/// Layout novo (HTTP 200).
class SDLayoutFetched extends SDLayoutFetchResult {
  final String json;
  final String? etag;
  const SDLayoutFetched(this.json, {this.etag});
}

/// O layout em cache continua valendo (HTTP 304).
class SDLayoutNotModified extends SDLayoutFetchResult {
  const SDLayoutNotModified();
}

/// Busca um layout na rede. Recebe o ETag em cache para mandar em `If-None-Match`.
///
/// Fica com o app (http, dio, autenticação…); o sd_widget não faz rede.
/// ```dart
/// Future<SDLayoutFetchResult> fetch(String key, {String? etag}) async {
///   final res = await http.get(Uri.parse('$base/$key'),
///       headers: {if (etag != null) 'If-None-Match': etag});
///   if (res.statusCode == 304) return const SDLayoutNotModified();
///   if (res.statusCode != 200) throw HttpException('${res.statusCode}');
///   return SDLayoutFetched(res.body, etag: res.headers['etag']);
/// }
/// ```
typedef SDLayoutFetcher = Future<SDLayoutFetchResult> Function(String key, {String? etag});

/// De onde veio um [SDLayoutSnapshot].
enum SDLayoutSource { memory, store, network }

class SDLayoutSnapshot {
  final String key;
  final String json;
  final String? etag;
  final DateTime fetchedAt;
  final SDLayoutSource source;

  /// Mais velho que `maxAge`: está sendo (ou será) revalidado.
  final bool stale;

  const SDLayoutSnapshot({
    required this.key,
    required this.json,
    required this.etag,
    required this.fetchedAt,
    required this.source,
    required this.stale,
  });
}

/// Layout recusado: JSON inválido ou versão do contrato que este app não conhece.
class SDLayoutException implements Exception {
  final String message;
  const SDLayoutException(this.message);
  @override
  String toString() => 'SDLayoutException: $message';
}

/// Cache de layouts SDUI: memória → armazenamento persistente → rede.
///
/// - Mostra o que estiver em cache na hora e revalida em segundo plano quando
///   passou de [maxAge] (stale-while-revalidate), mandando o ETag guardado.
/// - Sem rede, continua no último layout bom; só falha se nunca houve cache.
/// - Só guarda layouts que decodificam e cuja versão `sdui` é suportada, para
///   uma publicação quebrada não apagar o layout que funciona.
/// - Buscas simultâneas da mesma chave viram uma só.
class SDLayoutRepository {
  final SDLayoutFetcher _fetch;
  final SDLayoutStore? _store;
  final MemoryLayoutStore _memory;
  final Duration maxAge;
  final int maxSupportedVersion;
  final DateTime Function() _now;
  final Map<String, Future<SDLayoutSnapshot?>> _inflight = {};

  SDLayoutRepository({
    required SDLayoutFetcher fetch,
    SDLayoutStore? store,
    int memoryCapacity = 20,
    this.maxAge = const Duration(minutes: 5),
    this.maxSupportedVersion = 1,
    DateTime Function()? clock,
  })  : _fetch = fetch,
        _store = store,
        _memory = MemoryLayoutStore(capacity: memoryCapacity),
        _now = clock ?? DateTime.now;

  /// Layout em memória, sem esperar: permite desenhar já no primeiro frame.
  SDLayoutSnapshot? peek(String key) {
    final c = _memory.peek(key);
    return c == null ? null : _snapshot(key, c, SDLayoutSource.memory);
  }

  /// Emite o layout em cache (se houver) e, se estiver velho, ausente ou
  /// [forceRefresh], o layout revalidado quando ele mudar. Depois fecha.
  Stream<SDLayoutSnapshot> watch(String key, {bool forceRefresh = false}) async* {
    final cached = await _cached(key);
    if (cached != null) yield cached;
    if (cached != null && !cached.stale && !forceRefresh) return;

    try {
      final fresh = await refresh(key);
      if (fresh == null && cached == null) {
        throw SDLayoutException('"$key": servidor respondeu 304 mas não há layout em cache');
      }
      if (fresh != null && fresh.json != cached?.json) yield fresh;
    } catch (e, s) {
      if (cached == null) rethrow;
      log('Revalidação de "$key" falhou; mantendo o cache', error: e, stackTrace: s, name: 'SDLayoutRepository');
    }
  }

  /// Último valor de [watch]: o cache se estiver fresco, senão o da rede
  /// (ou o cache, se a rede falhar).
  Future<SDLayoutSnapshot> get(String key, {bool forceRefresh = false}) => watch(key, forceRefresh: forceRefresh).last;

  /// Vai à rede (com ETag). Devolve o layout vigente, ou null se não havia
  /// cache e o servidor respondeu 304.
  Future<SDLayoutSnapshot?> refresh(String key) {
    // Bloco, não arrow: remove() devolve este Future e whenComplete o esperaria.
    return _inflight[key] ??= _refresh(key).whenComplete(() {
      _inflight.remove(key);
    });
  }

  /// Baixa em segundo plano layouts que o usuário deve abrir em seguida.
  Future<void> prefetch(Iterable<String> keys) async {
    await Future.wait(keys.map((k) => get(k).then<void>((_) {}, onError: (Object e) {
          log('Prefetch de "$k" falhou', error: e, name: 'SDLayoutRepository');
        })));
  }

  /// Esquece o layout nos dois níveis de cache.
  Future<void> invalidate(String key) async {
    await _memory.remove(key);
    await _store?.remove(key);
  }

  Future<SDLayoutSnapshot?> _cached(String key) async {
    final m = await _memory.read(key);
    if (m != null) return _snapshot(key, m, SDLayoutSource.memory);
    final CachedLayout? s;
    try {
      s = await _store?.read(key);
    } catch (e) {
      log('Leitura do cache persistente falhou', error: e, name: 'SDLayoutRepository');
      return null;
    }
    if (s == null) return null;
    await _memory.write(key, s);
    return _snapshot(key, s, SDLayoutSource.store);
  }

  Future<SDLayoutSnapshot?> _refresh(String key) async {
    final old = _memory.peek(key) ?? await _store?.read(key);
    final result = await _fetch(key, etag: old?.etag);
    final CachedLayout next;
    switch (result) {
      case SDLayoutNotModified():
        if (old == null) return null;
        next = old.copyWith(fetchedAt: _now());
      case SDLayoutFetched(:final json, :final etag):
        validate(json);
        next = CachedLayout(json: json, etag: etag, fetchedAt: _now());
    }
    await _memory.write(key, next);
    try {
      await _store?.write(key, next);
    } catch (e) {
      log('Gravação do cache persistente falhou', error: e, name: 'SDLayoutRepository');
    }
    return _snapshot(key, next, SDLayoutSource.network);
  }

  /// Lança [SDLayoutException] se o JSON não puder virar tela neste app.
  void validate(String json) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException catch (e) {
      throw SDLayoutException('JSON inválido: ${e.message}');
    }
    if (decoded is List) return;
    if (decoded is! Map) throw const SDLayoutException('a raiz deve ser um nó ou uma lista de nós');
    final v = decoded['sdui'];
    if (v != null && (v is! int || v > maxSupportedVersion)) {
      throw SDLayoutException('contrato sdui $v não suportado (máximo $maxSupportedVersion)');
    }
  }

  SDLayoutSnapshot _snapshot(String key, CachedLayout c, SDLayoutSource source) => SDLayoutSnapshot(
        key: key,
        json: c.json,
        etag: c.etag,
        fetchedAt: c.fetchedAt,
        source: source,
        stale: _now().difference(c.fetchedAt) > maxAge,
      );
}
