import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sd_widget/src/cache/sd_layout_repository.dart';
import 'package:sd_widget/src/core/sd_registry.dart';
import 'package:sd_widget/src/ui/sd_data_builder.dart';

/// Tela SDUI carregada por um [SDLayoutRepository].
///
/// Desenha o layout em cache imediatamente (no primeiro frame, se estiver em
/// memória) e troca pelo novo quando a revalidação trouxer mudança. O JSON é
/// analisado uma vez por versão do layout: rebuilds do pai não reprocessam.
class SDLayoutView extends StatefulWidget {
  final SDLayoutRepository repository;
  final String layoutKey;
  final JsonViewRegistry registry;

  /// Enquanto não há nenhum layout (primeira abertura sem cache).
  final WidgetBuilder? placeholder;

  /// Quando não há cache e a busca falhou.
  final Widget Function(BuildContext context, Object error, VoidCallback retry)? errorBuilder;

  /// Avisa cada layout aplicado (útil para métricas: origem e idade do cache).
  final ValueChanged<SDLayoutSnapshot>? onLayout;

  const SDLayoutView({
    super.key,
    required this.repository,
    required this.layoutKey,
    required this.registry,
    this.placeholder,
    this.errorBuilder,
    this.onLayout,
  });

  @override
  State<SDLayoutView> createState() => _SDLayoutViewState();
}

class _SDLayoutViewState extends State<SDLayoutView> {
  StreamSubscription<SDLayoutSnapshot>? _sub;
  String? _json;
  JsonViewDataBuilder? _builder;
  Object? _error;

  @override
  void initState() {
    super.initState();
    final first = widget.repository.peek(widget.layoutKey);
    if (first != null) _apply(first, notify: false);
    _listen();
  }

  @override
  void didUpdateWidget(SDLayoutView old) {
    super.didUpdateWidget(old);
    if (old.layoutKey != widget.layoutKey || old.repository != widget.repository) {
      _json = null;
      _builder = null;
      _error = null;
      final first = widget.repository.peek(widget.layoutKey);
      if (first != null) _apply(first, notify: false);
      _listen();
    } else if (old.registry != widget.registry && _json != null) {
      _builder = _parse(_json!);
    }
  }

  void _listen({bool force = false}) {
    _sub?.cancel();
    _sub = widget.repository.watch(widget.layoutKey, forceRefresh: force).listen(
      _apply,
      onError: (Object e) {
        if (mounted && _builder == null) setState(() => _error = e);
      },
    );
  }

  void _apply(SDLayoutSnapshot s, {bool notify = true}) {
    widget.onLayout?.call(s);
    if (s.json == _json) return;
    void change() {
      _json = s.json;
      _builder = _parse(s.json);
      _error = null;
    }

    if (notify && mounted) {
      setState(change);
    } else {
      change();
    }
  }

  JsonViewDataBuilder _parse(String json) => JsonViewDataBuilder(widget.registry)..loadJson(json);

  void _retry() {
    setState(() => _error = null);
    _listen(force: true);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = _builder;
    if (b != null) return b.build(context);
    final e = _error;
    if (e != null && widget.errorBuilder != null) return widget.errorBuilder!(context, e, _retry);
    return widget.placeholder?.call(context) ?? const SizedBox.shrink();
  }
}
