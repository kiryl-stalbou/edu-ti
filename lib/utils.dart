import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';

final random = Random.secure();

extension StringUpperCaseExt on String {
  bool get isUpperCase => this == toUpperCase();
}

Future<File?> pickFile() async {
  final result = await FilePicker.platform.pickFiles(dialogTitle: 'Pick File');

  if (result == null) return null;

  return File(result.files[0].xFile.path);
}

bool isPrime(int n) {
  if (n <= 1) return false;

  for (var i = 2; i * i <= n; i++) {
    if (n % i == 0) return false;
  }

  return true;
}

int gcd(int a, int b) {
  while (b != 0) {
    (a, b) = (b, a % b);
  }

  return a;
}

(int x, int y) gcdex(int a, int b) {
  if (b == 0) return (1, 0);

  final (y, x) = gcdex(b, a % b);

  return (x, y - (a ~/ b) * x);
}

int powMod(int b, int e, int m) {
  int result = 1;
  b %= m;

  while (e > 0) {
    if (e % 2 != 0) result = (result * b) % m;
    e ~/= 2;
    b = (b * b) % m;
  }

  return result;
}

int fpow(int b, int e) {
  int result = 1;

  while (e > 0) {
    if (e % 2 == 1) result *= b;
    b *= b;
    e ~/= 2;
  }

  return result;
}
