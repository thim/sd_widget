// Testes do contrato SDUI v1 com o kanvas (https://github.com/thim/kanvas).
//
// Os exemplos em test/contract/sdui/v1 são copiados do kanvas por
// tool/sync_contract.sh. Exemplos "current" precisam renderizar aqui sem erro;
// os "planned" usam recursos da fase 1 e ficam pulados até o contrato marcar
// esses recursos como implementados.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sd_widget/sd_widget.dart';

const _dir = 'test/contract/sdui/v1/fixtures';

/// Percorre todos os nós de um documento SDUI (raiz única ou lista).
void _walk(dynamic node, void Function(String type, Map data) visit) {
  if (node is List) {
    for (final n in node) {
      _walk(n, visit);
    }
    return;
  }
  if (node is! Map || node['type'] is! String) return;
  final data = (node['data'] as Map?) ?? const {};
  visit(node['type'] as String, data);
  for (final e in data.entries) {
    // Ações também têm "type", mas não são nós de UI.
    if (e.key == 'action') continue;
    final v = e.value;
    if (v is Map && v['type'] is String) _walk(v, visit);
    if (v is List) _walk(v, visit);
  }
}

/// Textos que precisam aparecer na tela (placeholders "$campo" ficam de fora).
List<String> _expectedTexts(dynamic doc) {
  final out = <String>[];
  void add(dynamic v) {
    if (v is String && v.isNotEmpty && !v.startsWith(r'$')) out.add(v);
  }

  _walk(doc, (type, data) {
    switch (type) {
      case 'text':
      case 'button':
        add(data['text']);
      case 'list_tile':
        add(data['title']);
        add(data['subtitle']);
        add(data['trailing']);
      case 'tile':
        add(data['title']);
        add(data['subtitle']);
    }
  });
  return out;
}

void main() {
  final manifest = jsonDecode(File('$_dir/manifest.json').readAsStringSync()) as Map<String, dynamic>;
  final fixtures = (manifest['fixtures'] as List).cast<Map<String, dynamic>>();

  test('manifesto da versão 1 com exemplos existentes', () {
    expect(manifest['version'], 1);
    expect(fixtures, isNotEmpty);
    for (final f in fixtures) {
      expect(File('$_dir/${f['file']}').existsSync(), isTrue, reason: f['file'] as String);
    }
  });

  for (final f in fixtures) {
    final file = f['file'] as String;
    final planned = f['status'] == 'planned';
    final requires = (f['requires'] as List).cast<String>();
    final name = planned ? '$file — PLANEJADO, aguarda: ${requires.join(', ')}' : '$file — ${f['title']}';

    testWidgets(name, skip: planned, (tester) async {
      final source = File('$_dir/$file').readAsStringSync();
      final doc = jsonDecode(source);
      final registry = defaultWidget();

      // Todo tipo usado tem builder registrado.
      final types = <String>{};
      _walk(doc, (type, _) => types.add(type));
      for (final t in types) {
        expect(registry.supports(t), isTrue, reason: 'tipo "$t" não registrado');
      }
      expect(types, (f['types'] as List).cast<String>().toSet(), reason: 'manifesto desatualizado');

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SDWidget.fromJson(source, viewRegistry: registry)),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      // Erros de construção viram SizedBox.shrink silenciosamente; conferir o
      // conteúdo garante que cada nó realmente chegou na tela.
      for (final t in _expectedTexts(doc)) {
        expect(find.text(t), findsWidgets, reason: 'texto "$t" não renderizou');
      }
      var svgs = 0;
      _walk(doc, (type, _) {
        if (type == 'svg' || type == 'tile') svgs++;
      });
      expect(find.byType(SvgPicture), findsNWidgets(svgs));
    });
  }
}
