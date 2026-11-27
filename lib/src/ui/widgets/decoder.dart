import 'package:flutter/material.dart';
import 'package:sd_widget/src/ui/widgets/parser.dart';

CrossAxisAlignment? decodeCrossAxisAlignment(String? value) {
  return {
    'baseline': CrossAxisAlignment.baseline,
    'center': CrossAxisAlignment.center,
    'end': CrossAxisAlignment.end,
    'start': CrossAxisAlignment.start,
    'stretch': CrossAxisAlignment.stretch,
  }[value];
}

MainAxisAlignment? decodeMainAxisAlignment(String? value) {
  return {
    'center': MainAxisAlignment.center,
    'end': MainAxisAlignment.end,
    'spaceAround': MainAxisAlignment.spaceAround,
    'spaceBetween': MainAxisAlignment.spaceBetween,
    'spaceEvenly': MainAxisAlignment.spaceEvenly,
    'start': MainAxisAlignment.start,
  }[value];
}

MainAxisSize? decodeMainAxisSize(String? value) {
  return {
    'max': MainAxisSize.max,
    'min': MainAxisSize.min,
  }[value];
}

Alignment? decodeAlignment(dynamic value) {
  Alignment? result;

  if (value is Map) {
    result = Alignment(
      parseDouble(value['x']) ?? 0.0,
      parseDouble(value['y']) ?? 0.0,
    );
  } else if (value is String) {
    result = {
      'bottomCenter': Alignment.bottomCenter,
      'bottomLeft': Alignment.bottomLeft,
      'bottomRight': Alignment.bottomRight,
      'center': Alignment.center,
      'centerLeft': Alignment.centerLeft,
      'centerRight': Alignment.centerRight,
      'topCenter': Alignment.topCenter,
      'topLeft': Alignment.topLeft,
      'topRight': Alignment.topRight,
    }[value];
  }

  return result;
}

VerticalDirection? decodeVerticalDirection(String? value) {
  return {
    'down': VerticalDirection.down,
    'up': VerticalDirection.up,
  }[value];
}

Axis? decodeAxis(String? value) {
  return {
    'vertical': Axis.vertical,
    'horizontal': Axis.horizontal,
  }[value];
}

EdgeInsetsGeometry? decodeEdgeInsetsGeometry(dynamic value) {
  EdgeInsetsGeometry? result;

  if (value != null) {
    if (value is String || value is double || value is int) {
      result = EdgeInsets.all(parseDouble(value)!);
    } else if (value is List) {
      assert(value.length == 2 || value.length == 4);
      // LR,TB
      if (value.length == 2) {
        result = EdgeInsets.symmetric(
          horizontal: parseDouble(value[0], 0)!,
          vertical: parseDouble(value[1], 0)!,
        );
      }
      // L,T,R,B
      else if (value.length == 4) {
        result = EdgeInsets.fromLTRB(
          parseDouble(value[0])!,
          parseDouble(value[1])!,
          parseDouble(value[2])!,
          parseDouble(value[3])!,
        );
      }
    } else if (value is Map) {
      result = EdgeInsets.only(
        bottom: parseDouble(value['bottom'], 0.0)!,
        left: parseDouble(value['left'], 0.0)!,
        right: parseDouble(value['right'], 0.0)!,
        top: parseDouble(value['top'], 0.0)!,
      );
    }
  }
  return result;
}

Color? decodeColor(dynamic value) {
  Color? result;

  if (value != null) {
    var i = 0;

    if (value?.startsWith('#') == true) {
      value = value.substring(1);
    }

    if (value?.length == 3) {
      value = value.substring(0, 1) +
          value.substring(0, 1) +
          value.substring(1, 2) +
          value.substring(1, 2) +
          value.substring(2, 3) +
          value.substring(2, 3);
    }

    if (value?.length == 6 || value?.length == 8) {
      i = int.parse(value, radix: 16);

      if (value?.length != 8) {
        i = 0xff000000 + i;
      }

      result = Color(i);
    }
  }
  return result;
}

BoxDecoration? decodeDecoration(dynamic value) {
  if (value is! Map) return null;

  final circle = value['shape'] == 'circle';
  final borderColor = decodeColor(value['borderColor']);
  final borderWidth = parseDouble(value['width']);

  // Só há borda quando borderColor ou width é informado.
  final border = borderColor == null && borderWidth == null
      ? null
      : Border.all(color: borderColor ?? const Color(0xFF000000), width: borderWidth ?? 1.0);

  return BoxDecoration(
    color: decodeColor(value['color']),
    shape: circle ? BoxShape.circle : BoxShape.rectangle,
    borderRadius: circle ? null : decodeBorderRadius(value['radius']),
    border: border,
  );
}

/// Raio único ou [topo-esq, topo-dir, base-dir, base-esq].
BorderRadius? decodeBorderRadius(dynamic value) {
  if (value is List && value.length == 4) {
    Radius r(int i) => Radius.circular(parseDouble(value[i], 0.0)!);
    return BorderRadius.only(topLeft: r(0), topRight: r(1), bottomRight: r(2), bottomLeft: r(3));
  }
  final r = parseDouble(value);
  return r == null || r == 0 ? null : BorderRadius.circular(r);
}

FontWeight? decodeFontWeight(dynamic value) {
  final w = value is num ? value.toInt() : int.tryParse('$value');
  if (w == null || w < 100 || w > 900 || w % 100 != 0) return null;
  return FontWeight.values[w ~/ 100 - 1];
}

TextAlign? decodeTextAlign(dynamic value) {
  return {
    'left': TextAlign.left,
    'center': TextAlign.center,
    'right': TextAlign.right,
    'justify': TextAlign.justify,
    'start': TextAlign.start,
    'end': TextAlign.end,
  }[value];
}

TextOverflow? decodeTextOverflow(dynamic value) {
  return {
    'clip': TextOverflow.clip,
    'ellipsis': TextOverflow.ellipsis,
    'fade': TextOverflow.fade,
    'visible': TextOverflow.visible,
  }[value];
}

TextStyle? decodeTextStyle(TextTheme theme, dynamic value) {
  return {
    'headlineLarge': theme.headlineLarge,
    'headlineMedium': theme.headlineMedium,
    'headlineSmall': theme.headlineSmall,
    'titleLarge': theme.titleLarge,
    'titleMedium': theme.titleMedium,
    'titleSmall': theme.titleSmall,
    'bodyLarge': theme.bodyLarge,
    'bodyMedium': theme.bodyMedium,
    'bodySmall': theme.bodySmall,
    'labelLarge': theme.labelLarge,
    'labelMedium': theme.labelMedium,
    'labelSmall': theme.labelSmall,
  }[value];
}
