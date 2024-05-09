import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils.dart';

final _alphabet = 'abcdefghiklmnopqrstuvwxyz'.split('');

class Playfair extends StatefulWidget {
  const Playfair({super.key});

  @override
  State<Playfair> createState() => _PlayfairState();
}

class _PlayfairState extends State<Playfair>
    with AutomaticKeepAliveClientMixin {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  final _key1Controller = TextEditingController();
  final _key2Controller = TextEditingController();
  final _key3Controller = TextEditingController();
  final _key4Controller = TextEditingController();

  final _toggleState = [true, false];
  bool _encode = true;

  void _onKeyChanged(String rawKey) => _onInputChanged(_inputController.text);

  String _filter(String text) {
    final latin = RegExp('[a-zA-Z]');
    var result = '';

    for (var char in text.characters) {
      if (latin.hasMatch(char)) {
        if (char == 'j') {
          result += 'i';
        } else if (char == 'J') {
          result += 'I';
        } else {
          result += char;
        }
      }
    }

    return result;
  }

  (int, int) _positionOf(List<List<String>> matrix, String char) {
    for (var i = 0; i < matrix.length; i++) {
      for (var j = 0; j < matrix[i].length; j++) {
        if (matrix[i][j] == char.toLowerCase()) return (i, j);
      }
    }
    return (-1, -1);
  }

  void _onInputChanged(String rawInput) {
    final input = _filter(rawInput);
    final keys = [
      _filter(_key1Controller.text),
      _filter(_key2Controller.text),
      _filter(_key3Controller.text),
      _filter(_key4Controller.text),
    ];

    List<List<List<String>>> matrices =
        List.generate(4, (_) => List.generate(5, (_) => List.filled(5, '')));

    for (var i = 0; i < keys.length; i++) {
      final characters = {...keys[i].toLowerCase().characters, ..._alphabet};

      for (final (j, character) in characters.indexed) {
        matrices[i][j ~/ 5][j % 5] = character;
      }
    }

    List<(String, String)> pairs = [];

    final inCharacters = input.characters.toList();

    for (var i = 0; i < inCharacters.length; i += 2) {
      pairs.add((
        inCharacters[i],
        i + 1 < inCharacters.length ? inCharacters[i + 1] : 'X'
      ));
    }

    String output = '';

    for (final pair in pairs) {
      final (row1, col1) = _positionOf(matrices[_encode ? 0 : 1], pair.$1);
      final (row2, col2) = _positionOf(matrices[_encode ? 3 : 2], pair.$2);

      final outCharacter1 = matrices[_encode ? 1 : 0][row1][col2];
      final outCharacter2 = matrices[_encode ? 2 : 3][row2][col1];

      output +=
          pair.$1.isUpperCase ? outCharacter1.toUpperCase() : outCharacter1;
      output +=
          pair.$2.isUpperCase ? outCharacter2.toUpperCase() : outCharacter2;
    }

    _outputController.text = output;
    File('lib/tasks/playfair/in.txt').writeAsString(rawInput);
    File('lib/tasks/playfair/out.txt').writeAsString(output);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        //
        ToggleButtons(
          isSelected: _toggleState,
          onPressed: (int index) {
            for (int i = 0; i < _toggleState.length; i++) {
              _toggleState[i] = i == index;
            }
            setState(() => _encode = index == 0);
            _onInputChanged(_inputController.text);
          },
          constraints: const BoxConstraints(minHeight: 40.0, minWidth: 80.0),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          selectedBorderColor: Colors.blue[700],
          selectedColor: Colors.white,
          fillColor: Colors.blue[200],
          color: Colors.blue[400],
          children: const [Text('encode'), Text('decode')],
        ),

        const SizedBox(height: 20),

        Expanded(
          child: Row(
            children: [
              //
              Expanded(
                child: Column(
                  children: [
                    //
                    Expanded(
                      child: RepaintBoundary(
                        child: TextField(
                          expands: true,
                          maxLines: null,
                          onChanged: _onInputChanged,
                          controller: _inputController,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Input',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _key1Controller,
                      onChanged: _onKeyChanged,
                      decoration: const InputDecoration(
                        labelText: 'key 1',
                        filled: true,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _key3Controller,
                      onChanged: _onKeyChanged,
                      decoration: const InputDecoration(
                        labelText: 'key 3',
                        filled: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  children: [
                    //
                    Expanded(
                      child: TextField(
                        expands: true,
                        maxLines: null,
                        readOnly: true,
                        controller: _outputController,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Output',
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _key2Controller,
                      onChanged: _onKeyChanged,
                      decoration: const InputDecoration(
                        labelText: 'key 2',
                        filled: true,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _key4Controller,
                      onChanged: _onKeyChanged,
                      decoration: const InputDecoration(
                        labelText: 'key 4',
                        filled: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
