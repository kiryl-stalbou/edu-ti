import 'dart:async';
import 'dart:io';

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
  final _hmController = TextEditingController();
  final _rController = TextEditingController();
  final _sController = TextEditingController();

  File? _selectedFile;

  int get _p => int.tryParse(_pController.text) ?? -1;
  int get _q => int.tryParse(_qController.text) ?? -1;
  int get _h => int.tryParse(_hController.text) ?? -1;
  int get _x => int.tryParse(_xController.text) ?? -1;
  int get _k => int.tryParse(_kController.text) ?? -1;
  int get _n => _p * _q;
  int get _g => powMod(_h, (_p - 1) ~/ _q, _p);
  int get _y => powMod(_g, _x, _p);

  bool get _isInputValid =>
      _p > 0 &&
      _q > 0 &&
      _h > 0 &&
      _x > 0 &&
      _k > 0 &&
      (_p - 1) % _q == 0 &&
      _selectedFile != null;

  Future<void> _onSelectFile() async {
    final file = await pickFile(
      initialDirectory: '${Directory.current.path}/lib/tasks/dsa',
    );

    setState(() => _selectedFile = file);
  }

  Future<void> _onSignSelectedFile() async {
    if (!_isInputValid) return;

    final m = _selectedFile!.readAsBytesSync();
    final hm = _hash(_n, m);
    final r = powMod(_g, _k, _p) % _q;
    final s = powMod2(_k, (hm + _x * r), _q - 2, 1, _q);

    _hmController.text = '$hm';
    _rController.text = '$r';
    _sController.text = '$s';
    File('lib/tasks/dsa/${_selectedFile?.path.split('/').last}.signature')
        .writeAsString('$r $s');
  }

  Future<void> _onVerifySelectedFile() async {
    if (!_isInputValid) return;

    final signature = await pickFile();

    if (signature == null) return;

    final [r, s] = signature
        .readAsStringSync()
        .split(' ')
        .map((e) => int.tryParse(e) ?? -1)
        .toList();

    final m = _selectedFile!.readAsBytesSync();
    final hm = _hash(_n, m);
    final w = powMod(s, _q - 2, _q);
    final u1 = (hm * w) % _q;
    final u2 = (r * w) % _q;
    final v = powMod2(_g, _y, u1, u2, _p) % _q;

    final isSignatureValid = r == v;

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) =>
            _SignatureVerificationResultDialog(isValid: isSignatureValid),
      );
    }
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

        if (_selectedFile != null) ...[
          //
          const SizedBox(height: 30),

          Text('Selected file: ${_selectedFile?.path}'),

          const SizedBox(height: 30),

          Row(
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

          const SizedBox(height: 30),

          Row(
            children: [
              //
              Expanded(
                child: TextField(
                  enabled: false,
                  controller: _hmController,
                  decoration:
                      const InputDecoration(labelText: 'hash', filled: true),
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: TextField(
                  enabled: false,
                  controller: _rController,
                  decoration:
                      const InputDecoration(labelText: 'r', filled: true),
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: TextField(
                  enabled: false,
                  controller: _sController,
                  decoration:
                      const InputDecoration(labelText: 's', filled: true),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SignatureVerificationResultDialog extends StatelessWidget {
  const _SignatureVerificationResultDialog({required this.isValid});

  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        isValid
            ? 'Success, signature is valid'
            : 'Error, signature is not valid',
      ),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
