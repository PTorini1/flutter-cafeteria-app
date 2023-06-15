import 'package:encrypt/encrypt.dart' as encrypt;

class Encrypt {
  const Encrypt();

  static encryptAES(text) {
    final key = encrypt.Key.fromUtf8('gH+32%5HdFG3&key2Kjv70aDsr1/yZ=L');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);

    String peru = encrypted.base64.toString();
    return peru;
  }
}