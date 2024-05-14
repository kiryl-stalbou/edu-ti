import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ti/utils.dart';

const _alphabet = 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя';

class Vigenere extends StatefulWidget {
  const Vigenere({super.key});

  @override
  State<Vigenere> createState() => _VigenereState();
}

class _VigenereState extends State<Vigenere>
    with AutomaticKeepAliveClientMixin {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  final _keyController = TextEditingController();

  final _toggleState = [true, false];
  bool _encode = true;

  void _onKeyChanged(String rawKey) => _onInputChanged(_inputController.text);

  String _filter(String text) => text.replaceAll(RegExp('[^а-яА-ЯёË]'), '');

  int _indexOf(String char) {
    if (char == 'Ë') char = 'ё';

    return _alphabet.indexOf(char.toLowerCase());
  }

  void _onInputChanged(String rawInput) {
    final input = _filter(rawInput);
    final key = _filter(_keyController.text);

    final length = key.isEmpty ? 0 : input.length;

    String output = '';

    for (var i = 0; i < length; i++) {
      final inChar = input[i];
      final keyChar = key[i % key.length];

      final inIndex = _indexOf(inChar);
      final keyIndex = _indexOf(keyChar);

      final outIndex = (inIndex + (_encode ? keyIndex : -keyIndex)) % 33;
      final outChar = _alphabet[outIndex];

      output += inChar.isUpperCase ? outChar.toUpperCase() : outChar;
    }

    _outputController.text = output;
    File('lib/tasks/vigenere/in.txt').writeAsString(rawInput);
    File('lib/tasks/vigenere/out.txt').writeAsString(output);
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
            _encode = index == 0;
            _onInputChanged(_inputController.text);
            setState(() {});
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

              const SizedBox(width: 20),

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
            ],
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: _keyController,
          onChanged: _onKeyChanged,
          decoration: const InputDecoration(
            labelText: 'key',
            filled: true,
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
