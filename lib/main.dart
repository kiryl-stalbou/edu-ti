import 'package:flutter/material.dart';
import 'package:wt/tasks/lfsr/lfsr.dart';
import 'package:wt/tasks/rabin/rabin.dart';

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
  ];

  static const _tabs = <Tab>[
    Tab(text: 'Playfair'),
    Tab(text: 'Vigenere'),
    Tab(text: 'LFSR'),
    Tab(text: 'Rabin'),
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
