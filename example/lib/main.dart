import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sd_widget/sd_widget.dart';

import 'package:example/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'JSON Editor',
      home: JsonEditorExample(),
    );
  }
}

class JsonEditorExample extends StatefulWidget {
  const JsonEditorExample({super.key});

  @override
  State<JsonEditorExample> createState() => _JsonEditorExampleState();
}

class _JsonEditorExampleState extends State<JsonEditorExample> {
  String _jsonValue = jsonEncode({
    "type": "column",
    "data": {
      "crossAxisAlignment": "start",
      "children": [
        {
          "type": "container",
          "data": {
            "margin": 8.0,
            "padding": 8.0,
            "color": "#DDDDDD",
            "decoration": {"radius": 8.0, "color": "#DDDDDD", "borderColor": "#A0A0A0", "width": 1.0},
            "alignment": "center",
            "child": {
              "type": "button",
              "data": {
                "style": "outline",
                "text": "Increment",
                "action": {"key": "custom", "reference": "increment"}
              }
            }
          }
        },
        {
          "type": "padding",
          "data": {
            "padding": [10.0, 10.0],
            "child": {
              "type": "text",
              "data": {"text": "This is a title", "style": "titleLarge"}
            },
          },
        },
        {
          "type": "sized_box",
          "data": {"height": 16.0}
        },
        {
          "type": "listview",
          "data": {
            "padding": 8.0,
            "children": [
              {
                "type": "tile",
                "data": {
                  "img": "data:image/svg+xml;base64,$svgSample",
                  "title": "Lorem ipsum dolor sit amet",
                  "subtitle":
                      "In magna lorem, consequat nec augue id, aliquam imperdiet magna. Pellentesque et neque feugiat, facilisis augue in, sollicitudin magna. Donec vel lobortis enim"
                }
              },
              {
                "type": "tile",
                "data": {
                  "img": "data:image/svg+xml;base64,$svgSample",
                  "title": "Lorem ipsum dolor sit amet",
                  "subtitle":
                      "In magna lorem, consequat nec augue id, aliquam imperdiet magna. Pellentesque et neque feugiat, facilisis augue in, sollicitudin magna. Donec vel lobortis enim"
                }
              }
            ]
          }
        }
      ]
    }
  });
  String _formatError = '';
  bool _validJson = true;
  final _controller = TextEditingController();
  final viewData = JsonViewDataBuilder(defaultWidget());

  @override
  void initState() {
    viewData.onAction((action) {
      if (action.reference == "increment") {
        log("action: ${action.type} ref:${action.reference}");
      }
    });
    viewData.loadJson(_jsonValue);
    _controller.text = prettyPrintJson(_jsonValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: _validJson ? Colors.black : Colors.red),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: TextField(
                            decoration: null,
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            controller: _controller,
                            onChanged: (value) {
                              try {
                                json.decode(value);
                                setState(() {
                                  _jsonValue = value;
                                  viewData.loadJson(value);
                                  _validJson = true;
                                  _formatError = '';
                                });
                              } catch (e) {
                                log('$e', name: 'JSON');
                                _formatError = e.toString();
                                setState(() {
                                  _validJson = false;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      ColoredBox(
                        color: Colors.blueGrey,
                        child: Row(
                          children: [
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(_formatError, style: const TextStyle(color: Colors.white, fontSize: 12)),
                            )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  _controller.text = prettyPrintJson(_jsonValue);
                                },
                                child: const Tooltip(
                                  message: 'Format',
                                  child: Icon(Icons.format_align_left, size: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: SDWidget.fromViewData(viewData),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
