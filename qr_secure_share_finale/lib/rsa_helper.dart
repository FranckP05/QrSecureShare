import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/random/fortuna_random.dart';

class RSAHelper {
  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? _keyPair;

  /// Retourne la paire de clés actuelle (si elle existe déjà)
  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? get keyPair =>
      _keyPair;

  /// Génère une paire de clés RSA si elle n'existe pas encore
  static Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>>
      getKeyPair() async {
    if (_keyPair != null) return _keyPair!;

    // Générateur de nombres aléatoires sécurisé
    final secureRandom = FortunaRandom();
    final seed = Uint8List(32);
    final random = Random.secure();
    for (int i = 0; i < 32; i++) {
      seed[i] = random.nextInt(256);
    }
    secureRandom.seed(KeyParameter(seed));

    // Initialisation du générateur RSA
    final keyGen = KeyGenerator('RSA');
    keyGen.init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
      secureRandom,
    ));

    // Génération de la paire de clés
    final pair = keyGen.generateKeyPair();
    _keyPair = AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey as RSAPublicKey,
      pair.privateKey as RSAPrivateKey,
    );

    return _keyPair!;
  }

  /// Génère une clé AES 256 bits
  static encrypt.Key generateAESKey() {
    return encrypt.Key.fromSecureRandom(32);
  }

  /// Chiffre des données avec AES, puis chiffre la clé AES avec RSA
  static Future<Map<String, String>> encryptDataWithAESAndRSA(
      String data, RSAPublicKey publicKey) async {
    final aesKey = generateAESKey();
    final iv = encrypt.IV.fromLength(16);

    final aesEncrypter = encrypt.Encrypter(encrypt.AES(aesKey));
    final encryptedText = aesEncrypter.encrypt(data, iv: iv);

    final rsaEncrypter = encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));
    final encryptedAESKey = rsaEncrypter.encryptBytes(aesKey.bytes);

    return {
      'encryptedText': encryptedText.base64,
      'encryptedAESKey': encryptedAESKey.base64,
      'iv': iv.base64,
    };
  }

  /// Déchiffre la clé AES avec RSA, puis les données avec AES
  static Future<String> decryptDataWithAESAndRSA({
    required String encryptedText,
    required String encryptedAESKey,
    required String iv,
  }) async {
    await getKeyPair(); // Assure la disponibilité des clés

    final rsaEncrypter = encrypt.Encrypter(encrypt.RSA(
      publicKey: _keyPair!.publicKey,
      privateKey: _keyPair!.privateKey,
    ));

    final encryptedAESKeyData = encrypt.Encrypted.fromBase64(encryptedAESKey);
    final aesKeyBytes = rsaEncrypter.decryptBytes(encryptedAESKeyData);
    final aesKey = encrypt.Key(Uint8List.fromList(aesKeyBytes));

    final aesEncrypter = encrypt.Encrypter(encrypt.AES(aesKey));
    final ivBytes = encrypt.IV.fromBase64(iv);
    final encryptedTextBytes = encrypt.Encrypted.fromBase64(encryptedText);

    return aesEncrypter.decrypt(encryptedTextBytes, iv: ivBytes);
  }

  /// Convertit une clé publique RSA en chaîne Base64
  static String publicKeyToBase64(RSAPublicKey publicKey) {
    final modulusBytes = bigIntToBytes(publicKey.modulus!);
    final exponentBytes = bigIntToBytes(publicKey.exponent!);
    return base64Encode([...modulusBytes, ...exponentBytes]);
  }

  /// Convertit une chaîne Base64 en clé publique RSA
  static RSAPublicKey publicKeyFromBase64(String base64Key) {
    final bytes = base64Decode(base64Key);
    final modulusLength = bytes.length ~/ 2;
    final modulusBytes = bytes.sublist(0, modulusLength);
    final exponentBytes = bytes.sublist(modulusLength);
    return RSAPublicKey(
      bytesToBigInt(modulusBytes),
      bytesToBigInt(exponentBytes),
    );
  }

  /// Convertit un BigInt en tableau de bytes (Uint8List)
  static Uint8List bigIntToBytes(BigInt bigInt) {
    final byteMask = BigInt.from(0xff);
    final length = (bigInt.bitLength + 7) >> 3;
    final result = Uint8List(length);
    for (var i = 0; i < length; i++) {
      result[length - i - 1] = (bigInt & byteMask).toInt();
      bigInt = bigInt >> 8;
    }
    return result;
  }

  /// Convertit un tableau de bytes en BigInt
  static BigInt bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (var byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }
}
