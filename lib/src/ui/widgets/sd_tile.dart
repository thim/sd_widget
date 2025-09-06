import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:sd_widget/src/ui/sd_data_builder.dart';
import 'package:sd_widget/src/ui/widgets/decoder.dart';

const Color grey50 = Color(0xFFF2F2F2);
const Color grey500 = Color(0xFF717171);
const _base64Image = "data:image/svg+xml;base64,";

class SDTile implements BaseJsonWidget {
  final Map args;

  SDTile(this.args);

  @override
  Widget build(BuildContext context) {
    final image = args['img'];
    final svg = base64Decode(image.replaceAll(_base64Image, ""));

    return Container(
      height: args['height'] ?? 100.0,
      width: args['width'],
      margin: decodeEdgeInsetsGeometry(args["margin"]),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(color: grey50),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(
          left: 24.0,
          top: 16.0,
          right: 18.0,
          bottom: 16.0,
        ),
        leading: SvgPicture.memory(svg, fit: BoxFit.contain, height: 72.0),
        title: Text(
          args["title"],
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
        subtitle: Text(
          args["subtitle"],
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        onTap: () {},
      ),
    );
  }
}
