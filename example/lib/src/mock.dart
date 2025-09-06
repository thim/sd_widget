import 'dart:convert';

final svgSample = base64.encode(utf8.encode('''
<?xml version="1.0" encoding="utf-8"?>
<!-- Uploaded to: SVG Repo, www.svgrepo.com, Generator: SVG Repo Mixer Tools -->
<svg width="800px" height="800px" viewBox="0 0 1024 1024" class="icon"  version="1.1" xmlns="http://www.w3.org/2000/svg">
<path d="M910.4 843.8H174.6c-27.4 0-49.7-22.3-49.7-49.7V298.2c0-27.4 22.3-49.7 49.7-49.7h735.8c27.4 0 49.7 22.3 49.7 49.7v495.9c0 27.4-22.3 49.7-49.7 49.7z" fill="#A7B8C6" />
<path d="M272.1 193.8H118.7c-22.8 0-41.2 18.5-41.2 41.2v512.7c0 22.8 18.5 41.2 41.2 41.2h752.7c22.8 0 41.2-18.5 41.2-41.2V235c0-22.8-18.5-41.2-41.2-41.2H272.1z" fill="#FFFFFF" />
<path d="M871.4 802.5H118.7c-30.2 0-54.8-24.6-54.8-54.8V235c0-30.2 24.6-54.8 54.8-54.8h752.7c30.2 0 54.8 24.6 54.8 54.8v512.7c0 30.3-24.6 54.8-54.8 54.8zM118.7 207.3c-15.3 0-27.7 12.4-27.7 27.7v512.7c0 15.3 12.4 27.7 27.7 27.7h752.7c15.3 0 27.7-12.4 27.7-27.7V235c0-15.3-12.4-27.7-27.7-27.7H118.7z" fill="#3E3A39" />
<path d="M302.8 246.7H170.5c-19.6 0-35.6 13.6-35.6 30.3v376.5c0 16.7 15.9 30.3 35.6 30.3h649.1c19.6 0 35.6-13.6 35.6-30.3V277c0-16.7-15.9-30.3-35.6-30.3H302.8z" fill="#95D4EB" />
<path d="M430.8 683.8L230.3 483.3 135 578.6v105.2z" fill="#75BFAB" />
<path d="M374.4 394.3m-98.8 0a98.8 98.8 0 1 0 197.6 0 98.8 98.8 0 1 0-197.6 0Z" fill="#F9F5B1" />
<path d="M855.1 630L551.5 326.4 194.3 683.7h660.8z" fill="#57B79C" /><path d="M855.1 521.8l-83-83-245 245h328z" fill="#75BFAB" />
<path d="M709.9 743.8h-33.1c-0.8 0-1.5-0.7-1.5-1.5v-33.1c0-0.8 0.7-1.5 1.5-1.5h33.1c0.8 0 1.5 0.7 1.5 1.5v33.1c0 0.9-0.7 1.5-1.5 1.5zM774.2 743.8h-33.1c-0.8 0-1.5-0.7-1.5-1.5v-33.1c0-0.8 0.7-1.5 1.5-1.5h33.1c0.8 0 1.5 0.7 1.5 1.5v33.1c0 0.9-0.6 1.5-1.5 1.5zM838.6 743.8h-33.1c-0.8 0-1.5-0.7-1.5-1.5v-33.1c0-0.8 0.7-1.5 1.5-1.5h33.1c0.8 0 1.5 0.7 1.5 1.5v33.1c0 0.9-0.7 1.5-1.5 1.5z" fill="#3E3A39" />
</svg>
'''
    .trim()));

final json5Data = '''{
    "type": "column",
    "data": {
        "crossAxisAlignment": "start",
        "children": [
            {
                "type": "container",
                "data": {
                   "margin": 8.0,
                   "padding": 8.0,
                   "color" : "#DDDDDD",
                   "decoration":{
                    "radius": 8.0,
                    "color" : "#DDDDDD",
                    "borderColor" : "#A0A0A0",
                    "width": 1.0
                   },
                   "alignment": "center",
                    "child":{
                      "type": "button",
                      "data": {
                          "style": "outline",
                          "text": "Increment",
                          "action": {
                            "key": "custom",
                            "reference": "increment"
                          }
                      }
                    }
                }
            },
            {
                "type": "padding",
                "data": {
                   "padding": [10.0,10.0],
                    "child": {
                      "type": "text",
                      "data": {
                          "text": "This is a title",
                          "style": "titleLarge"
                      }
                    }
                   
                }
            },
            { 
              "type": "sized_box",
              "data": {
                "height": 16.0
              }
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
                                "subtitle": "In magna lorem, consequat nec augue id, aliquam imperdiet magna. Pellentesque et neque feugiat, facilisis augue in, sollicitudin magna. Donec vel lobortis enim"
                            }
                        },
                   
                          {
                            "type": "tile",
                            "data": {
                                "img": "data:image/svg+xml;base64,$svgSample",
                                "title": "Lorem ipsum dolor sit amet",
                                "subtitle": "In magna lorem, consequat nec augue id, aliquam imperdiet magna. Pellentesque et neque feugiat, facilisis augue in, sollicitudin magna. Donec vel lobortis enim"
                            }
                        }
                    ]
                }
            }
        ]
    }
}
''';

const json6Data = '''{

            "type": "container",
            "data": {
                "height": 400.0,
                "width": 200.0,
                "child": {
                    "type": "list_builder",
                    "data": {
                        "id": "list",
                        "builder": {
                            "type": "list_tile",
                            "data": {
                                "title": "\$title",
                                "subtitle": "\$subtitle",
                                "trailing": "\$trailing"
                            }
                        }
                    }
                }
            }
}
''';

final json8Data = '''{          
"type": "tile",
"data": {
    "title": "Lorem ipsum dolor sit amet",
    "subtitle": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In magna lorem, consequat nec augue id, aliquam imperdiet magna. Pellentesque et neque feugiat, facilisis augue in, sollicitudin magna. Donec vel lobortis enim",
    "img": "data:image/svg+xml;base64,$svgSample"
    }
}
''';

final json9Data = '''{
  "type": "text",
  "data": {
      "text": "Counter counter",
      "replace": "counter"
  }
}
'''
    .trim();
