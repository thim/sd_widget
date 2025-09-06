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
  BoxDecoration? result;

  if (value is Map) {
    result = BoxDecoration(
      color: decodeColor(value['color']),
      borderRadius: BorderRadius.all(Radius.circular(parseDouble(value['radius']) ?? 0.0)),
      border: Border.all(
        color: decodeColor(value['borderColor']) ?? const Color(0xFF000000),
        width: parseDouble(value['width']) ?? 1.0,
      ),
    );
  }
  return result;
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
