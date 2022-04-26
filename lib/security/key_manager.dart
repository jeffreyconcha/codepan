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
      debugPrint('mac: $mac}');
    }
    return encrypted;
  }

  Future<String> decrypt(String text, String mac) async {
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
}
