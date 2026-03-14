import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sd_widget/sd_widget.dart';

void main() {
  group('decodeColor', () {
    test('null returns null', () {
      expect(decodeColor(null), isNull);
    });

    test('6-digit hex without # prefix', () {
      expect(decodeColor('FF0000'), const Color(0xFFFF0000));
    });

    test('6-digit hex with # prefix', () {
      expect(decodeColor('#00FF00'), const Color(0xFF00FF00));
    });

    test('8-digit hex preserves alpha channel', () {
      expect(decodeColor('80FF0000'), const Color(0x80FF0000));
    });

    test('3-digit shorthand expands to 6-digit', () {
      // 'F00' → 'FF0000'
      expect(decodeColor('F00'), const Color(0xFFFF0000));
    });

    test('invalid hex characters fall back to black', () {
      // int.tryParse returns null → i=0 → 0xFF000000
      expect(decodeColor('GGGGGG'), const Color(0xFF000000));
    });

    test('wrong length (5 chars) returns null', () {
      expect(decodeColor('12345'), isNull);
    });

    test('wrong length (7 chars after stripping #) returns null', () {
      expect(decodeColor('#1234567'), isNull);
    });

    test('empty string returns null', () {
      expect(decodeColor(''), isNull);
    });

    test('non-String input returns null', () {
      expect(decodeColor(42), isNull);
    });
  });

  group('decodeEdgeInsetsGeometry', () {
    test('null returns null', () {
      expect(decodeEdgeInsetsGeometry(null), isNull);
    });

    test('single double → EdgeInsets.all', () {
      expect(decodeEdgeInsetsGeometry(8.0), const EdgeInsets.all(8.0));
    });

    test('single int → EdgeInsets.all', () {
      expect(decodeEdgeInsetsGeometry(4), const EdgeInsets.all(4.0));
    });

    test('single string number → EdgeInsets.all', () {
      expect(decodeEdgeInsetsGeometry('12'), const EdgeInsets.all(12.0));
    });

    test('array of 2 → symmetric (horizontal, vertical)', () {
      expect(
        decodeEdgeInsetsGeometry([10.0, 20.0]),
        const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      );
    });

    test('array of 4 → fromLTRB', () {
      expect(
        decodeEdgeInsetsGeometry([1.0, 2.0, 3.0, 4.0]),
        const EdgeInsets.fromLTRB(1.0, 2.0, 3.0, 4.0),
      );
    });

    test('map with named fields → EdgeInsets.only', () {
      expect(
        decodeEdgeInsetsGeometry({'left': 5.0, 'top': 10.0, 'right': 15.0, 'bottom': 20.0}),
        const EdgeInsets.only(left: 5.0, top: 10.0, right: 15.0, bottom: 20.0),
      );
    });

    test('map with partial fields defaults missing to 0', () {
      expect(
        decodeEdgeInsetsGeometry({'left': 8.0}),
        const EdgeInsets.only(left: 8.0),
      );
    });

    test('array of wrong length returns null (not an assert crash)', () {
      expect(decodeEdgeInsetsGeometry([1.0, 2.0, 3.0]), isNull);
      expect(decodeEdgeInsetsGeometry([1.0]), isNull);
    });
  });

  group('decodeAlignment', () {
    test('null returns null', () {
      expect(decodeAlignment(null), isNull);
    });

    test('known string keywords', () {
      expect(decodeAlignment('center'), Alignment.center);
      expect(decodeAlignment('topLeft'), Alignment.topLeft);
      expect(decodeAlignment('topRight'), Alignment.topRight);
      expect(decodeAlignment('bottomCenter'), Alignment.bottomCenter);
      expect(decodeAlignment('centerLeft'), Alignment.centerLeft);
      expect(decodeAlignment('centerRight'), Alignment.centerRight);
    });

    test('unknown string returns null', () {
      expect(decodeAlignment('middle'), isNull);
    });

    test('map with x and y creates numeric Alignment', () {
      expect(decodeAlignment({'x': 0.5, 'y': -0.5}), const Alignment(0.5, -0.5));
    });

    test('map missing x/y defaults to 0.0', () {
      expect(decodeAlignment({}), const Alignment(0.0, 0.0));
    });
  });

  group('decodeAxis', () {
    test('vertical', () => expect(decodeAxis('vertical'), Axis.vertical));
    test('horizontal', () => expect(decodeAxis('horizontal'), Axis.horizontal));
    test('null returns null', () => expect(decodeAxis(null), isNull));
    test('unknown string returns null', () => expect(decodeAxis('diagonal'), isNull));
  });

  group('decodeMainAxisAlignment', () {
    test('known values', () {
      expect(decodeMainAxisAlignment('center'), MainAxisAlignment.center);
      expect(decodeMainAxisAlignment('spaceBetween'), MainAxisAlignment.spaceBetween);
      expect(decodeMainAxisAlignment('spaceAround'), MainAxisAlignment.spaceAround);
      expect(decodeMainAxisAlignment('spaceEvenly'), MainAxisAlignment.spaceEvenly);
      expect(decodeMainAxisAlignment('start'), MainAxisAlignment.start);
      expect(decodeMainAxisAlignment('end'), MainAxisAlignment.end);
    });

    test('null returns null', () => expect(decodeMainAxisAlignment(null), isNull));
    test('unknown returns null', () => expect(decodeMainAxisAlignment('stretch'), isNull));
  });

  group('decodeCrossAxisAlignment', () {
    test('known values', () {
      expect(decodeCrossAxisAlignment('start'), CrossAxisAlignment.start);
      expect(decodeCrossAxisAlignment('end'), CrossAxisAlignment.end);
      expect(decodeCrossAxisAlignment('center'), CrossAxisAlignment.center);
      expect(decodeCrossAxisAlignment('stretch'), CrossAxisAlignment.stretch);
      expect(decodeCrossAxisAlignment('baseline'), CrossAxisAlignment.baseline);
    });

    test('null returns null', () => expect(decodeCrossAxisAlignment(null), isNull));
  });

  group('decodeMainAxisSize', () {
    test('max', () => expect(decodeMainAxisSize('max'), MainAxisSize.max));
    test('min', () => expect(decodeMainAxisSize('min'), MainAxisSize.min));
    test('null returns null', () => expect(decodeMainAxisSize(null), isNull));
  });

  group('decodeVerticalDirection', () {
    test('down', () => expect(decodeVerticalDirection('down'), VerticalDirection.down));
    test('up', () => expect(decodeVerticalDirection('up'), VerticalDirection.up));
    test('null returns null', () => expect(decodeVerticalDirection(null), isNull));
  });

  group('parseDouble', () {
    test('from int', () => expect(parseDouble(42), 42.0));
    test('from double', () => expect(parseDouble(3.14), 3.14));
    test('from numeric string', () => expect(parseDouble('2.5'), 2.5));
    test('null with default returns default', () => expect(parseDouble(null, 99.0), 99.0));
    test('null without default returns null', () => expect(parseDouble(null), isNull));
  });
}
