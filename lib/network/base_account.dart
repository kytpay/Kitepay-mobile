import 'dart:async';
import 'package:kitepay/network/network_client.dart';
import 'package:kitepay/utilies/network_connectivity.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:solana/metaplex.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kitepay/utilies/tracker.dart';

class ImageInfo {
  final String uri;
  final OffChainMetadata? data;

  const ImageInfo(this.uri, this.data);
}

Future<ImageInfo?> getImageFromUri(String uri) async {
  try {
    Map<String, String> headers = {};
    headers['Accept'] = 'application/json';
    headers['Access-Control-Allow-Origin'] = '*';
    http.Response response = await http.get(
      Uri.parse(uri),
      headers: headers,
    );

    final body = json.decode(response.body) as Map<String, dynamic>;

    final sanitizedUri = body["image"];

    OffChainMetadata? data;

    try {
      data = OffChainMetadata.fromJson(body);
    } catch (err) {
      data = null;
    }
    return ImageInfo(sanitizedUri, data);
  } catch (err) {
    return null;
  }
}

class Token {
  // How much of this token
  late double balance = 0;
  // USD equivalent of the balance
  late double usdBalance = 0;
  // Mint of this token
  late String mint;
  // Info about the token
  final TokenInfo info;

  Token(this.balance, this.mint, this.info);
}

class NFT extends Token {
  final ImageInfo? imageInfo;

  NFT(
    double balance,
    String mint,
    TokenInfo info,
    this.imageInfo,
  ) : super(balance, mint, info);
}

class SOL extends Token {
  SOL(
    double balance,
  ) : super(balance, "", TokenInfo(name: "Solana", symbol: "SOL")) {
    info.logoUrl =
        "https://upload.wikimedia.org/wikipedia/en/b/b9/Solana_logo.png";
  }
}

class USDC extends Token {
  USDC(
    double balance,
  ) : super(balance, "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            TokenInfo(name: "USD Coin", symbol: "USDC")) {
    info.logoUrl =
        "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png";
  }
}

class USDT extends Token {
  USDT(
    double balance,
  ) : super(balance, "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
            TokenInfo(name: "Tether", symbol: "USDT")) {
    info.logoUrl = "https://tether.to/images/logoMarkGreen.png";
  }
}

class DAI extends Token {
  DAI(
    double balance,
  ) : super(balance, "EjmyN6qEC1Tf1JxiG1ae7UTJhUxSwk1TCWNWqxWV4J6o",
            TokenInfo(name: "Dai", symbol: "DAI")) {
    info.logoUrl =
        "https://user-images.githubusercontent.com/67560900/168100708-efbb183d-944a-48f5-b4c8-c7f7163dfd70.png";
  }
}

class BUSD extends Token {
  BUSD(
    double balance,
  ) : super(balance, "33fsBLA8djQm82RpHmE3SuVrPGtZBWNYExsEUeKX1HXX",
            TokenInfo(name: "Binance USD", symbol: "BUSD")) {
    info.logoUrl =
        "https://s2.coinmarketcap.com/static/img/coins/64x64/4687.png";
  }
}

enum AccountItem {
  tokens,
  usdBalance,
  balance,
  transactions,
}

class BaseAccount {
  //late NetworkUrl url;
  // late SolanaClient client;

  late String name;
  late bool isLoaded = true;
  late String address;
  late double balance = 0;
  late double usdBalance = 0;
  late TokenTrackers tokensTracker;
  late List<TransactionDetails> transactions = [];
  late Map<String, Token> tokens = {};
  final itemsLoaded = <AccountItem, bool>{};

  BaseAccount(this.balance, this.name, this.tokensTracker);

  /*
   * Determine if an item of this account, e.g, if token are loaded
   */
  bool isItemLoaded(AccountItem item) {
    return itemsLoaded[item] != null;
  }

  /*
   * Get a token by it's mint address
   */
  Token getTokenByMint(String mint) {
    return tokens[mint] as Token;
  }

  /*
   * Refresh the account balance
   */
  Future<void> refreshSolBalance(NetworkClient client) async {

     if (await NetworkConnectivity.isConnected() == false) {
      return;
    }
    
    int balance = await client.getSolBalance(address);

    this.balance = balance.toDouble() / lamportsPerSol;
    itemsLoaded[AccountItem.balance] = true;

    usdBalance =
        this.balance * tokensTracker.getTokenValue(SystemProgram.programId);

    itemsLoaded[AccountItem.usdBalance] = true;

    for (final token in tokens.values) {
      updateUsdFromTokenValue(token);
    }
  }

  /*
   * Sum a token value into the account's global USD balance
   */
  void updateUsdFromTokenValue(Token token) {
    try {
      Tracker? tracker = tokensTracker.getTracker(token.mint);
      if (tracker != null) {
        double tokenUsdBalance = (token.balance * tracker.usdValue);
        token.usdBalance = tokenUsdBalance;
        usdBalance += tokenUsdBalance;
      }
      // ignore: empty_catches
    } catch (err) {}
  }

  /*
   * Loads all the tokens (spl-program mints) owned by this account
   */
  Future<void> loadSplTokens(NetworkClient client) async {

     if (await NetworkConnectivity.isConnected() == false) {
      return;
    }
    
    final completer = Completer();

    // Get all the tokens owned by the account
    final tokenAccounts = await client.rpcClient.getTokenAccountsByOwner(
      address,
      const TokenAccountsFilter.byProgramId(TokenProgram.programId),
      commitment: Commitment.confirmed,
      encoding: Encoding.jsonParsed,
    );
    //client.rpcClient.getTokenAccountBalance(address);
    //client.rpcClient.getTokenAccountsByDelegate(pubKey, filter);

    int notOwnedNFTs = 0;

    tokenAccounts.asMap().forEach(
      (index, tokenAccount) {
        ParsedAccountData? data =
            tokenAccount.account.data as ParsedAccountData?;
        if (data != null) {
          data.when(
            splToken: (data) {
              data.when(
                  account: (mintData, type, accountType) {
                    String tokenMint = mintData.mint;
                    int decimals = mintData.tokenAmount.decimals;
                    String? uiBalance = mintData.tokenAmount.uiAmountString;
                    double balance = double.parse(uiBalance ?? "0");

                    String defaultName = "Unknown $index";
                    TokenInfo defaultTokenInfo = TokenInfo(
                      name: defaultName,
                      symbol: defaultName,
                      decimals: decimals,
                    );

                    // Start tracking the token
                    TokenInfo tokenInfo = tokensTracker.addTrackerByProgramMint(
                      tokenMint,
                      defaultValue: defaultTokenInfo,
                    );

                    // Add the token to this account
                    client.rpcClient
                        .getMetadata(
                            mint: Ed25519HDPublicKey.fromBase58(tokenMint))
                        .then(
                      (value) async {
                        try {
                          ImageInfo imageInfo =
                              await getImageFromUri(value!.uri) as ImageInfo;
                          if (balance > 0) {
                            tokens[tokenMint] =
                                NFT(balance, tokenMint, tokenInfo, imageInfo);
                          } else {
                            notOwnedNFTs++;
                          }
                        } catch (_) {
                          tokens[tokenMint] =
                              Token(balance, tokenMint, tokenInfo);
                        } finally {
                          if (tokens.length + notOwnedNFTs ==
                              tokenAccounts.length) {
                            itemsLoaded[AccountItem.tokens] = true;
                            try {
                              completer.complete();
                            } catch (_) {}
                          }
                        }
                      },
                    );
                  },
                  mint: (_, __, ___) {},
                  unknown: (_) {});
            },
            unsupported: (_) {},
            stake: (_) {},
          );
        }
      },
    );

    if (tokenAccounts.isEmpty) {
      itemsLoaded[AccountItem.tokens] = true;
      completer.complete();
    }

    return completer.future;
  }

  /*
   * Load the Address's transactions into the account
   */
  Future<void> loadTransactions(NetworkClient client) async {
    if (await NetworkConnectivity.isConnected() == false) {
      return;
    }

    transactions = [];

    try {
      final response = await client.rpcClient.getTransactionsList(
        Ed25519HDPublicKey.fromBase58(address),
        limit: 100,
        commitment: Commitment.confirmed,
      );

      for (final tx in response) {
        final message = tx.transaction.message;

        for (final instruction in message.instructions) {
          if (instruction is ParsedInstruction) {
            instruction.map(
              system: (data) {
                data.parsed.map(
                  transfer: (data) {
                    ParsedSystemTransferInformation transfer = data.info;
                    bool receivedOrSent = transfer.destination == address;
                    double amount =
                        transfer.lamports.toDouble() / lamportsPerSol;

                    transactions.add(
                      TransactionDetails(
                          transfer.source,
                          transfer.destination,
                          amount,
                          receivedOrSent,
                          SystemProgram.programId,
                          tx.blockTime!,
                          tx.transaction.signatures.first),
                    );
                  },
                  transferChecked: (_) {},
                  unsupported: (data) {
                    //transactions.add(UnsupportedTransaction(tx.blockTime!));
                    //ParsedSystemTransferInformation transfer =

                    // bool receivedOrSent = transfer.destination == address;
                    // double amount =
                    //     transfer.lamports.toDouble() / lamportsPerSol;
                    //  transactions.add(
                    //   TransactionDetails(
                    //     transfer.source,
                    //     transfer.destination,
                    //     amount,
                    //     receivedOrSent,
                    //     SystemProgram.programId,
                    //     tx.blockTime!,
                    //   ),
                    // );
                  },
                );
              },
              splToken: (data) {
                data.parsed.map(
                  transfer: (data) {
                    // print("SPL: {$data}");
                    // transactions.add(UnsupportedTransaction(tx.blockTime!));
                    SplTokenTransferInfo transfer = data.info;
                    data.type;
                    // print(data.type);
                    bool receivedOrSent = transfer.destination == address;
                    double amount =
                        double.parse(transfer.amount) / lamportsPerSol * 1000;
                    // print(transfer.amount);
                    // print(double.parse(transfer.amount) / lamportsPerSol);

                    transactions.add(
                      TransactionDetails(
                          transfer.source,
                          transfer.destination,
                          amount,
                          receivedOrSent,
                          TokenProgram.programId,
                          tx.blockTime!,
                          tx.transaction.signatures.first),
                    );
                  },
                  transferChecked: (data) {},
                  generic: (data) {},
                );
              },
              memo: (data) {
                //print("memo: {$data}");
                //transactions.add(UnsupportedTransaction(tx.blockTime!));
              },
              unsupported: (data) {
                // print("unsupported: {$data}");
                // print(data.toString());
                // ParsedInstructionUnsupported transfer = data;
                // transactions.add(TransactionDetails(
                //     address,
                //     'associated token account',
                //     0.0,
                //     false,
                //     TokenProgram.programId,
                //     tx.blockTime!));
              },
            );
          }
        }
      }
    } catch (err) {
      print(err.toString());
    }

    itemsLoaded[AccountItem.transactions] = true;
  }
}

/*
 * WalletAccount implement this
 */
abstract class Account {
// late String name; -
//   late bool isLoaded = true;-
//   late String address;-
//   late double balance = 0; -
//   late double usdBalance = 0; -
//   late TokenTrackers tokensTracker;-
//   late List<TransactionDetails> transactions = []; -
//   late Map<String, Token> tokens = {};-
//   final itemsLoaded = <AccountItem, bool>{}; -

  // Account's Type, e.g, Watcher or Wallet
  //final AccountType accountType;
  // Account's name
  late String name;
  // Account network configuration, aka json rpc / websockets node
  //late NetworkUrl url;
  // Account's client to the the configured node
  //late SolanaClient client;
  // SOL balance
  late double balance = 0;
  // USD balance of SOL and all the tokens combined
  late double usdBalance = 0;
  // Account's address
  late String address;
  // A tokens tracker used to share token information like USD equivalent values across all the user's accounts, this makes prevent making the same request multiple times, e.g
  // If two accounts own the same token, fetching the USD value of that token will only be made once.
  late TokenTrackers tokensTracker;
  // Recent transactions
  late List<TransactionDetails> transactions = [];
  // Tokens owned by this account
  late Map<String, Token> tokens = {};

  // Flag used only to easily create an account with shimmer effects on the Home page
  late bool isLoaded = true;

  //Account(this.name, this.url);

  // Know if an account item is loaded, e.g, tokens or transactions
  bool isItemLoaded(AccountItem item);
  // Increase the USD value of the account when a new token is added
  void updateUsdFromTokenValue(Token token);
  // Fetch the SOL balance
  Future<void> refreshSolBalance(NetworkClient client);
  // Fetch the latest transactions
  Future<void> loadTransactions(NetworkClient client);
  // Fetch the owned tokens
  Future<void> loadSplTokens(NetworkClient client);

  // Convert the account data into JSON
  Map<String, dynamic> toJson();
}

class TransactionDetails {
  // Who sent the transaction
  final String origin;
  // Recipient of the transaction
  final String destination;
  // How much
  final double amount;
  // Was the account of this transaction the same as the destination
  final bool receivedOrNot;
  // The Program ID of this transaction, e.g, System Program, Token Program...
  final String programId;
  // The UNIX timestamp of the block where the transaction was included
  final int blockTime;

  final String signature;

  TransactionDetails(
    this.origin,
    this.destination,
    this.amount,
    this.receivedOrNot,
    this.programId,
    this.blockTime,
    this.signature,
  );

  Map<String, dynamic> toJson() {
    return {
      "origin": origin,
      "destination": destination,
      "amount": amount,
      "receivedOrNot": receivedOrNot,
      "tokenMint": programId,
      "blockNumber": blockTime
    };
  }
}

class Transaction {
  // Who sent the transaction
  final String origin;
  // Recipient of the transaction
  final String destination;
  // How much
  final double amount;
  // Was the account of this transaction the same as the destination
  final bool receivedOrNot;
  // The Program ID of this transaction, e.g, System Program, Token Program...
  final String programId;
  // Token used in the transaction
  late Token token;
  // References used in the transaction, https://docs.solanapay.com/spec#reference
  late List<String> references = [];

  Transaction(this.origin, this.destination, this.amount, this.receivedOrNot,
      this.programId, this.token, this.references);
}
