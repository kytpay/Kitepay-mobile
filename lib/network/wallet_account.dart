import 'package:kitepay/network/network_client.dart';
import 'package:solana/base58.dart';

import 'package:solana/solana.dart' show Ed25519HDKeyPair, Wallet;
import 'package:kitepay/utilies/tracker.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'base_account.dart';

// Master key to encrypt and decrypt mnemonics, aka passphrases, this is included when creating the build
// final secureKey = Key.fromUtf8(
//   // ignore: prefer_const_constructors
//   String.fromEnvironment("secureKey", defaultValue: "SolanaIsLove"),
// );
// final iv = IV.fromLength(16);

class WalletAccount extends BaseAccount implements Account {
  // final AccountType accountType = AccountType.Wallet;

  late Wallet wallet;
  final String mnemonic;

  WalletAccount(
    double balance,
    String name,
    this.mnemonic,
    TokenTrackers tokensTracker,
  ) : super(balance, name, tokensTracker) {}

  /*
   * Constructor in case the address is already known
   */
  WalletAccount.withAddress(
    double balance,
    String address,
    name,
    //   NetworkUrl url,
    this.mnemonic,
    tokensTracker,
  ) : super(balance, name, tokensTracker) {
    this.address = address;
  }

  /*
   * Create the keys pair in Isolate to prevent blocking the main thread
   */
  static Future<Ed25519HDKeyPair> createKeyPair(String mnemonic) async {
    final Ed25519HDKeyPair keyPair =
        await Ed25519HDKeyPair.fromMnemonic(mnemonic);
    return keyPair;
  }

  /*
   * Load the keys pair into the WalletAccount
   */
  Future<void> loadKeyPair() async {
    try {
      final Ed25519HDKeyPair? keyPair = await createKeyPair(mnemonic);
      //await compute(createKeyPair, mnemonic);

      if (keyPair != null) {
        wallet = keyPair;
        address = wallet.address;
      } else {
        print('loadKeyPair(): keypair is null');
      }
    } catch (error) {
      print(error.toString());
    }
  }

  /*
   * Create a WalletAccount with a random mnemonic
   */
  static Future<WalletAccount> generate(
      NetworkClient client, String name, tokensTracker) async {
    final String randomMnemonic = bip39.generateMnemonic();

    WalletAccount account = WalletAccount(
      0,
      name,
      randomMnemonic,
      tokensTracker,
    );
    await account.loadKeyPair();
    await account.refreshSolBalance(client);
    return account;
  }

  static Future<String> getPrivateKey(WalletAccount walletAccount) async {
    final privateKey = await (await walletAccount.wallet.extract()).bytes;
    final publicKey =
        await (await walletAccount.wallet.extractPublicKey()).bytes;
    print(privateKey + publicKey);

    var encodedPrivateKey = base58encode(privateKey + publicKey);
    print(encodedPrivateKey);

    return encodedPrivateKey;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "address": address,
      "balance": balance,
      "mnemonic": mnemonic,
      "transactions": transactions.map((tx) => tx.toJson()).toList()
    };
  }
}
