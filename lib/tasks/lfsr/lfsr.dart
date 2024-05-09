import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wt/utils.dart';

class LFSR extends StatefulWidget {
  const LFSR({super.key});

  @override
  State<LFSR> createState() => _LFSRState();
}

class _LFSRState extends State<LFSR> with AutomaticKeepAliveClientMixin {
  static const _polynom = [39, 4];

  final _registerController = TextEditingController(text: '111111111111111111111111111111111111111');
  final _keyController = TextEditingController();
  final _sourceFileController = TextEditingController();
  final _resultFileController = TextEditingController();

  Future<void> _onPickFile() async {
    final sourceFile = await pickFile();

    if (sourceFile == null) return;

    final sourceBytes = sourceFile.readAsBytesSync();
    final resultBytes = Uint8List(sourceBytes.length);
    final keyBytes = _keyBytesFor(sourceBytes.length);

    if (keyBytes == null) return;

    for (var i = 0; i < sourceBytes.length; i++) {
      resultBytes[i] = sourceBytes[i] ^ keyBytes[i];
    }

    _sourceFileController.text = sourceBytes.getRange(0, 10).map((e) => e.toRadixString(2).padLeft(8, '0')).join();
    _resultFileController.text = resultBytes.getRange(0, 10).map((e) => e.toRadixString(2).padLeft(8, '0')).join();
    _keyController.text = keyBytes.getRange(0, 10).map((e) => e.toRadixString(2).padLeft(8, '0')).join();
    File('${sourceFile.path}.result').writeAsBytesSync(resultBytes);
  }

  Uint8List? _keyBytesFor(int lengthInBytes) {
    if (_registerController.text.length != _polynom[0]) return null;

    int register = int.parse(_registerController.text, radix: 2);

    final keyBytes = Uint8List(lengthInBytes);

    for (var i = 0; i < keyBytes.length; i++) {
      for (var j = 0; j < 8; j++) {
        int bit = _bitOf(register, _polynom[0]);

        keyBytes[i] |= (bit << (8 - j - 1));

        for (var k = 1; k < _polynom.length; k++) {
          bit ^= _bitOf(register, _polynom[k]);
        }

        register <<= 1;
        register |= bit;
      }
    }

    return keyBytes;
  }

  int _bitOf(int target, int position) => (target >> position - 1) & 1;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        //
        TextField(
          maxLength: _polynom[0],
          controller: _registerController,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[01]'))],
          decoration: const InputDecoration(labelText: 'Register', filled: true),
        ),

        ElevatedButton(
          onPressed: _onPickFile,
          child: const Text('Pick file'),
        ),

        const SizedBox(height: 20),

        TextField(
          minLines: 1,
          maxLines: 3,
          readOnly: true,
          controller: _keyController,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(labelText: 'Key', filled: true),
        ),

        const SizedBox(height: 20),

        TextField(
          minLines: 1,
          maxLines: 3,
          readOnly: true,
          controller: _sourceFileController,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(labelText: 'Sorce file bits', filled: true),
        ),

        const SizedBox(height: 20),

        TextField(
          minLines: 1,
          maxLines: 3,
          readOnly: true,
          controller: _resultFileController,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(labelText: 'Result file bits', filled: true),
        ),
      ],
    );
  }
}
