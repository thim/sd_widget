// Recursos adicionados para o contrato SDUI v1 (fase 1 da integração com o kanvas).

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sd_widget/sd_widget.dart';

Future<JsonViewRegistry> pump(WidgetTester tester, Object node, {JsonViewRegistry? registry}) async {
  final r = registry ?? defaultWidget();
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: SDWidget.fromJson(jsonEncode(node), viewRegistry: r)),
  ));
  expect(tester.takeException(), isNull);
  return r;
}

Map<String, dynamic> text(String t, [Map<String, dynamic> extra = const {}]) => {
      'type': 'text',
      'data': {'text': t, ...extra},
    };

BoxDecoration decorationOf(WidgetTester tester) =>
    tester.widget<Container>(find.byType(Container).first).decoration! as BoxDecoration;

void main() {
  group('text', () {
    testWidgets('fonte, tamanho, peso, altura, alinhamento e linhas', (tester) async {
      await pump(
          tester,
          text('Olá', {
            'fontSize': 22,
            'fontWeight': 700,
            'fontFamily': 'Inter',
            'height': 1.2,
            'textAlign': 'center',
            'maxLines': 2,
            'overflow': 'ellipsis',
            'color': '#FF0000',
          }));
      final t = tester.widget<Text>(find.text('Olá'));
      expect(t.style!.fontSize, 22.0);
      expect(t.style!.fontWeight, FontWeight.w700);
      expect(t.style!.fontFamily, 'Inter');
      expect(t.style!.height, 1.2);
      expect(t.style!.color, const Color(0xFFFF0000));
      expect(t.textAlign, TextAlign.center);
      expect(t.maxLines, 2);
      expect(t.overflow, TextOverflow.ellipsis);
    });

    testWidgets('cor vale mesmo sem style', (tester) async {
      await pump(tester, text('x', {'color': '#00FF00'}));
      expect(tester.widget<Text>(find.text('x')).style!.color, const Color(0xFF00FF00));
    });
  });

  testWidgets('column e row com spacing', (tester) async {
    await pump(tester, {
      'type': 'column',
      'data': {
        'spacing': 12,
        'children': [
          {
            'type': 'row',
            'data': {
              'spacing': 4,
              'children': [text('a'), text('b')]
            }
          },
          text('c'),
        ],
      }
    });
    expect(tester.widget<Column>(find.byType(Column)).spacing, 12.0);
    expect(tester.widget<Row>(find.byType(Row)).spacing, 4.0);
    final dy = tester.getTopLeft(find.text('c')).dy - tester.getBottomLeft(find.text('a')).dy;
    expect(dy, closeTo(12, 0.01));
  });

  testWidgets('sized_box com filho e expanded com flex', (tester) async {
    await pump(tester, {
      'type': 'column',
      'data': {
        'children': [
          {
            'type': 'sized_box',
            'data': {'width': 120, 'height': 40, 'child': text('fixo')}
          },
          {
            'type': 'sized_box',
            'data': {
              'width': 300,
              'height': 10,
              'child': {
                'type': 'row',
                'data': {
                  'children': [
                    {
                      'type': 'expanded',
                      'data': {
                        'flex': 2,
                        'child': {
                          'type': 'container',
                          'data': {'color': '#FF0000', 'child': text('dois')}
                        }
                      }
                    },
                    {
                      'type': 'expanded',
                      'data': {
                        'child': {
                          'type': 'container',
                          'data': {'color': '#00FF00', 'child': text('um')}
                        }
                      }
                    },
                  ]
                }
              }
            }
          },
        ]
      }
    });
    expect(tester.getSize(find.ancestor(of: find.text('fixo'), matching: find.byType(SizedBox)).first),
        const Size(120, 40));
    final two = tester.getSize(find.ancestor(of: find.text('dois'), matching: find.byType(Container)).first);
    final one = tester.getSize(find.ancestor(of: find.text('um'), matching: find.byType(Container)).first);
    expect(two.width, closeTo(200, 0.01));
    expect(one.width, closeTo(100, 0.01));
  });

  group('decoration', () {
    testWidgets('sem borderColor e sem width não há borda', (tester) async {
      await pump(tester, {
        'type': 'container',
        'data': {
          'decoration': {'color': '#FFFFFF', 'radius': 8}
        }
      });
      final d = decorationOf(tester);
      expect(d.border, isNull);
      expect(d.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('borda quando pedida', (tester) async {
      await pump(tester, {
        'type': 'container',
        'data': {
          'decoration': {'borderColor': '#0000FF', 'width': 2}
        }
      });
      expect(decorationOf(tester).border, Border.all(color: const Color(0xFF0000FF), width: 2));
    });

    testWidgets('raio por canto e círculo', (tester) async {
      await pump(tester, {
        'type': 'column',
        'data': {
          'children': [
            {
              'type': 'container',
              'data': {
                'decoration': {
                  'radius': [1, 2, 3, 4]
                }
              }
            },
            {
              'type': 'container',
              'data': {
                'decoration': {'shape': 'circle', 'radius': 9}
              }
            },
          ]
        }
      });
      final boxes = tester.widgetList<Container>(find.byType(Container)).toList();
      final corners = boxes[0].decoration! as BoxDecoration;
      expect(
          corners.borderRadius,
          const BorderRadius.only(
            topLeft: Radius.circular(1),
            topRight: Radius.circular(2),
            bottomRight: Radius.circular(3),
            bottomLeft: Radius.circular(4),
          ));
      final circle = boxes[1].decoration! as BoxDecoration;
      expect(circle.shape, BoxShape.circle);
      expect(circle.borderRadius, isNull);
    });

    testWidgets('container.clip recorta, mesmo só com color', (tester) async {
      await pump(tester, {
        'type': 'container',
        'data': {'color': '#FF0000', 'clip': true, 'child': text('x')}
      });
      final c = tester.widget<Container>(find.byType(Container));
      expect(c.clipBehavior, Clip.antiAlias);
      expect((c.decoration! as BoxDecoration).color, const Color(0xFFFF0000));
    });
  });

  testWidgets('stack com positioned', (tester) async {
    await pump(tester, {
      'type': 'stack',
      'data': {
        'width': 200,
        'height': 100,
        'children': [
          {
            'type': 'positioned',
            'data': {'left': 10, 'top': 20, 'width': 50, 'height': 30, 'child': text('p')}
          },
          {
            'type': 'positioned',
            'data': {'left': 0, 'right': 0, 'bottom': 0, 'height': 10, 'child': text('base')}
          },
        ]
      }
    });
    final ours = find.ancestor(of: find.text('p'), matching: find.byType(Stack)).first;
    expect(tester.widget<Stack>(ours).clipBehavior, Clip.hardEdge);
    expect(tester.getSize(ours), const Size(200, 100));
    final origin = tester.getTopLeft(ours);
    expect(tester.getTopLeft(find.text('p')) - origin, const Offset(10, 20));
    // left + right sem width: estica na largura do stack.
    final base = find.ancestor(of: find.text('base'), matching: find.byType(Positioned));
    final box = tester.renderObject<RenderBox>(find.descendant(of: base, matching: find.byType(Text)).first);
    expect(tester.getTopLeft(find.text('base')).dy - origin.dy, 90);
    expect(box.constraints.maxWidth, 200);
  });

  testWidgets('opacity e rotate', (tester) async {
    await pump(tester, {
      'type': 'opacity',
      'data': {
        'opacity': 0.5,
        'child': {
          'type': 'rotate',
          'data': {'angle': 90, 'child': text('r')}
        }
      }
    });
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.5);
    final t = tester.widget<Transform>(find.ancestor(of: find.text('r'), matching: find.byType(Transform)).first);
    // Rotação de 90° no sentido horário: cos = 0, sen = 1.
    expect(t.transform.storage[0], closeTo(math.cos(math.pi / 2), 1e-9));
    expect(t.transform.storage[1], closeTo(1, 1e-9));
  });

  testWidgets('tap dispara a ação', (tester) async {
    final registry = defaultWidget();
    final actions = <SDAction>[];
    registry.onAction(actions.add);
    await pump(
        tester,
        {
          'type': 'tap',
          'data': {
            'action': {'type': 'push_named', 'reference': '/perfil'},
            'child': text('abrir'),
          }
        },
        registry: registry);
    await tester.tap(find.text('abrir'));
    expect(actions, hasLength(1));
    expect(actions.single.reference, '/perfil');
  });

  testWidgets('image mostra placeholder quando a URL falha', (tester) async {
    await pump(tester, {
      'type': 'image',
      'data': {'url': 'https://example.com/x.png', 'width': 80, 'height': 60, 'radius': 8, 'fit': 'contain'}
    });
    final img = tester.widget<Image>(find.byType(Image));
    expect(img.fit, BoxFit.contain);
    expect(find.byType(ClipRRect), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(Image)), const Size(80, 60));
  });
}
