import 'package:flutter/material.dart';
import 'package:ti/tasks/dsa/dsa.dart';
import 'package:ti/tasks/lfsr/lfsr.dart';
import 'package:ti/tasks/rabin/rabin.dart';

import 'tasks/playfair/playfair.dart';
import 'tasks/vigenere/vigenere.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  static const _views = <Widget>[
    Playfair(),
    Vigenere(),
    LFSR(),
    Rabin(),
    DSA(),
  ];

  static const _tabs = <Tab>[
    Tab(text: 'Playfair'),
    Tab(text: 'Vigenere'),
    Tab(text: 'LFSR'),
    Tab(text: 'Rabin'),
    Tab(text: 'DSA'),
  ];

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'TI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        home: DefaultTabController(
          length: _views.length,
          initialIndex: _views.length - 1,
          child: const Scaffold(
            appBar: TabBar(tabs: _tabs),
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TabBarView(children: _views),
            ),
          ),
        ),
      );
}
