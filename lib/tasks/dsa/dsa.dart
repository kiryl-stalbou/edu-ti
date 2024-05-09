import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ti/utils.dart';

class DSA extends StatefulWidget {
  const DSA({super.key});

  @override
  State<DSA> createState() => _DSAState();
}

class _DSAState extends State<DSA> with AutomaticKeepAliveClientMixin {
  final _pController = TextEditingController();
  final _qController = TextEditingController();
  final _hController = TextEditingController();
  final _xController = TextEditingController();
  final _kController = TextEditingController();

  File? _selectedFile;

  int get _p => int.tryParse(_pController.text) ?? -1;
  int get _q => int.tryParse(_qController.text) ?? -1;
  int get _n => _p * _q;
  int get _h => int.tryParse(_hController.text) ?? -1;
  int get _x => int.tryParse(_xController.text) ?? -1;
  int get _k => int.tryParse(_kController.text) ?? -1;

  bool get _isInputValid =>
      _p != _q && (_p - 1) % _q == 0 && _selectedFile != null;

  Future<void> _onSelectFile() async {
    final file = await pickFile();

    setState(() => _selectedFile = file);
  }

  Future<void> _onSignSelectedFile() async {
    if (!_isInputValid) return;

    final g = powMod(_h, (_p - 1) ~/ _q, _p);

    final y = powMod(g, _x, _p);

    final bytes = _selectedFile!.readAsBytesSync();

    final hm = _hash(_n, bytes);

    final r = powMod(g, _k, _p) % _q;
    final s = ((1 / _k) * (hm + _x * r)) % _q;
  }

  Future<void> _onVerifySelectedFile() async {
    if (!_isInputValid) return;

    // final file = await pickFile();

    // if (file == null) return;

    // final digits = file
    //     .readAsStringSync()
    //     .split(' ')
    //     .map((e) => int.tryParse(e) ?? 0)
    //     .toList();
  }

  int _hash(int n, Uint8List bytes) {
    final hi = [100, for (var i = 1; i <= bytes.length; i++) 0];

    for (var i = 0; i < bytes.length; i++) {
      hi[i + 1] = powMod(hi[i] + bytes[i], 2, n);
    }

    return hi.last;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        //
        Row(
          children: [
            //
            Expanded(
              child: TextField(
                controller: _pController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'p', filled: true),
              ),
            ),

            const SizedBox(width: 5),

            Expanded(
              child: TextField(
                controller: _qController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'q', filled: true),
              ),
            ),

            const SizedBox(width: 5),

            Expanded(
              child: TextField(
                controller: _hController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'h', filled: true),
              ),
            ),

            const SizedBox(width: 5),

            Expanded(
              child: TextField(
                controller: _xController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'x', filled: true),
              ),
            ),

            const SizedBox(width: 5),

            Expanded(
              child: TextField(
                controller: _kController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'k', filled: true),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: _onSelectFile,
          child: const Text('Select file'),
        ),

        if (_selectedFile == null) ...[
          //
          const SizedBox(height: 30),

          Text('Selected file: ${_selectedFile?.path}'),

          const SizedBox(height: 30),

          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //
              ElevatedButton(
                onPressed: _onSignSelectedFile,
                child: const Text('Sign selected file'),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: _onVerifySelectedFile,
                child: const Text('Verify signature'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
