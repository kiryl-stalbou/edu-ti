import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wt/utils.dart';

class Rabin extends StatefulWidget {
  const Rabin({super.key});

  @override
  State<Rabin> createState() => _RabinState();
}

class _RabinState extends State<Rabin> with AutomaticKeepAliveClientMixin {
  final _pController = TextEditingController();
  final _qController = TextEditingController();
  final _bController = TextEditingController();

  int get _p => int.tryParse(_pController.text) ?? -1;
  int get _q => int.tryParse(_qController.text) ?? -1;
  int get _b => int.tryParse(_bController.text) ?? -1;
  int get _n => _p * _q;

  bool get _isInputValid => _p != _q && isPrime(_p) && isPrime(_q) && _b < _n && _p % 4 == 3 && _q % 4 == 3;

  Future<void> _onPickFileToEncode() async {
    if (!_isInputValid) return;

    final file = await pickFile();

    if (file == null) return;

    final bytes = file.readAsBytesSync();

    final encodedBytes = _encode(bytes, _n, _b);
    final encodedString = encodedBytes.map((e) => '$e').join(' ');

    File('lib/tasks/rabin/${file.path.split('/').last}.e').writeAsStringSync(encodedString);
  }

  Future<void> _onPickFileToDecode() async {
    if (!_isInputValid) return;

    final file = await pickFile();

    if (file == null) return;

    final digits = file.readAsStringSync().split(' ').map((e) => int.tryParse(e) ?? 0).toList();

    final decodedBytes = _decode(digits, _p, _q, _n, _b);

    File('lib/tasks/rabin/${file.path.split('/').last}.d').writeAsBytesSync(decodedBytes);
  }

  List<int> _encode(Uint8List bytes, int n, int b) => bytes.map((byte) => byte * (byte + b) % n).toList();

  Uint8List _decode(List<int> digits, int p, int q, int n, int b) {
    final decodedBytes = Uint8List(digits.length);

    for (var i = 0; i < decodedBytes.length; i++) {
      final d = (b * b + 4 * digits[i]) % n;

      final mp = powMod(d, (p + 1) ~/ 4, p);
      final mq = powMod(d, (q + 1) ~/ 4, q);

      final (yp, yq) = gcdex(p, q);

      final di = [0, 0, 0, 0];

      di[0] = (yp * p * mq + yq * q * mp) % n;
      di[1] = n - di[0];
      di[2] = (yp * p * mq - yq * q * mp) % n;
      di[3] = n - di[2];

      final mi = [0, 0, 0, 0];

      for (var j = 0; j < 4; j++) {
        if ((di[j] - b) % 2 == 0) {
          mi[j] = ((-b + di[j]) ~/ 2) % n;
        } else {
          mi[j] = ((-b + n + di[j]) ~/ 2) % n;
        }

        if (mi[j] < 256) {
          decodedBytes[i] = mi[j];
          break;
        }
      }
    }

    return decodedBytes;
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
                controller: _bController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'b', filled: true),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //
            ElevatedButton(onPressed: _onPickFileToEncode, child: const Text('Pick file to encode')),

            const SizedBox(width: 10),

            ElevatedButton(onPressed: _onPickFileToDecode, child: const Text('Pick file to decode')),
          ],
        ),
      ],
    );
  }
}
