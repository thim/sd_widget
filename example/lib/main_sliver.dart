import 'package:flutter/material.dart';
import 'package:sd_widget/sd_widget.dart';

import 'package:example/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final viewData = JsonViewDataBuilder(defaultWidget());

  _MyHomePageState() {
    viewData.onAction((action) {
      if (action.reference == "increment") {
        _incrementCounter();
      }
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    viewData.loadJson(json5Data);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: [
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SDSliverDelegate(viewData),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

final mockList = [
  {"category": "Lanches", "title": "Sanduíche", "value": "30,00"},
  {"category": "Lanches", "title": "Hambúrguere", "value": "30,00"},
  {"category": "Bebidas", "title": "Café", "value": "12,00"},
  {"category": "Bebidas", "title": "Cappuccino", "value": "15,00"},
  {"category": "Sobremesas", "title": "Bolo em fatia", "value": "20,00"},
  {"category": "Sobremesas", "title": "Sorvete", "value": "20,00"}
];
