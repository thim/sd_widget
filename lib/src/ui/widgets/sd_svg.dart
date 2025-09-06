import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:sd_widget/src/ui/sd_data_builder.dart';

const _base64Image = "data:image/svg+xml;base64,";

class SDSVG implements BaseJsonWidget {
  final Map args;

  SDSVG(this.args);

  @override
  Widget build(BuildContext context) {
    final image = args['img'] as String?;
    final url = args['url'] as String?;

    if (url != null) return SvgPicture.network(url);

    if (image != null && image.startsWith(_base64Image)) {
      return SvgPicture.memory(
        base64Decode(image.replaceFirst(_base64Image, "")),
        fit: BoxFit.contain,
      );
    }

    if (image != null) return SvgPicture.string(image);

    return const SizedBox.shrink();
  }
}
