import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/random/fortuna_random.dart';

class RSAHelper {
  static encrypt.Encrypter? _encrypter;
  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? _keyPair;

  // Génère une paire de clés RSA
  static Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>>
      getKeyPair() async {
    if (_keyPair != null) return _keyPair!;

    // Configure le générateur de nombres aléatoires sécurisé
    final secureRandom = FortunaRandom();
    final seed = Uint8List(32);
    final random = Random.secure();
    for (int i = 0; i < 32; i++) {
      seed[i] = random.nextInt(256);
    }
    secureRandom.seed(KeyParameter(seed));

    // Configure le générateur de clés RSA
    final keyGen = KeyGenerator('RSA');
    keyGen.init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
      secureRandom,
    ));

    // Génère la paire de clés
    final pair = keyGen.generateKeyPair();
    _keyPair = AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey as RSAPublicKey,
      pair.privateKey as RSAPrivateKey,
    );

    // Initialise l'encrypter avec la clé publique et privée
    _encrypter = encrypt.Encrypter(
      encrypt.RSA(
        publicKey: _keyPair!.publicKey,
        privateKey: _keyPair!.privateKey,
      ),
    );

    return _keyPair!;
  }

  // Chiffre les données avec la clé publique
  static Future<String> encryptData(String data) async {
    await getKeyPair(); // Assure que les clés sont générées
    final encrypted = _encrypter!.encrypt(data);
    return encrypted.base64;
  }

  // Déchiffre les données avec la clé privée
  static Future<String> decryptData(String encryptedBase64) async {
    await getKeyPair(); // Assure que les clés sont générées
    final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);
    return _encrypter!.decrypt(encrypted);
  }
}
