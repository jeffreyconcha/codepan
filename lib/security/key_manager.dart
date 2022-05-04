import 'dart:convert';

import 'package:crypto/crypto.dart' as c;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

extension ByteLengthChecker on List<int> {
  List<int> ensureLength([int? newLength]) {
    if (newLength != null) {
      final length = this.length;
      if (newLength > length) {
        final list = List<int>.from(this);
        list.addAll(
          List.generate(newLength - length, (index) => 0),
        );
        return list;
      } else {
        return this.sublist(0, newLength);
      }
    }
    return this;
  }
}

class KeyManager {
  final String seed;
  final cipher = AesGcm.with256bits();

  KeyManager(this.seed);

  List<int> get key {
    final data = utf8.encode(seed);
    final digest = c.sha256.convert(data);
    return digest.bytes;
  }

  List<int> get iv => key.ensureLength(cipher.nonceLength);

  Future<SecretKey> get secretKey async {
    final data = key.ensureLength(cipher.secretKeyLength);
    return await cipher.newSecretKeyFromBytes(data);
  }

  Future<String> encrypt(
    String text, [
    bool showLog = false,
  ]) async {
    final box = await cipher.encrypt(
      utf8.encode(text),
      secretKey: await secretKey,
      nonce: iv,
    );
    final encrypted = base64.encode(box.cipherText);
    final mac = base64.encode(box.mac.bytes);
    if (showLog) {
      debugPrint('encrypted: $encrypted');
      debugPrint('mac: $mac');
    }
    return encrypted;
  }

  Future<String> decryptBytes({
    required List<int> text,
    required List<int> mac,
  }) async {
    return decrypt(
      text: utf8.decode(text),
      mac: utf8.decode(mac),
    );
  }

  Future<String> decrypt({
    required String text,
    required String mac,
  }) async {
    final decoded = base64.decode(text);
    final box = SecretBox(
      decoded,
      mac: Mac(base64.decode(mac)),
      nonce: iv,
    );
    final data = await cipher.decrypt(
      box,
      secretKey: await secretKey,
    );
    return utf8.decode(data);
  }

  factory KeyManager.fromBytes(List<int> data) {
    final seed = utf8.decode(data).toString();
    return KeyManager(seed);
  }

  static String prepare(String input, [int maxCol = 20]) {
    final buffer = StringBuffer('{');
    buffer.write('\n\t');
    bool alternate = true;
    int counter = 0;
    final units = List.from(input.codeUnits);
    while (units.isNotEmpty) {
      if (alternate) {
        buffer.write(units.first);
        units.removeAt(0);
        alternate = false;
      } else {
        buffer.write(units.last);
        units.removeLast();
        alternate = true;
      }
      if (units.isNotEmpty) {
        buffer.write(', ');
      }
      if (counter++ == maxCol - 1) {
        buffer.write('\n\t');
        counter = 0;
      }
    }
    buffer.write('\n}');
    return buffer.toString();
  }
}
