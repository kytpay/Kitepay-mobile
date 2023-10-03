import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:kitepay/settings/utilities/network_selector.dart';
import 'package:kitepay/utilies/network_connectivity.dart';
import 'package:solana/dto.dart' show FutureContextResultExt, ProgramAccount;
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

/*
*All Solana network related work here!
*/
class NetworkClient extends SolanaClient {
  final NetworkUrl url;
  NetworkClient({required this.url})
      : super(
          rpcUrl: Uri.parse(url.rpc),
          websocketUrl: Uri.parse(url.ws),
        ) {}

  /*
   * Refresh the account balance
   */
  Future<int> getSolBalance(String address) async {
    int balance = 0;
    var connection = await NetworkConnectivity.isConnected();
    if(connection){
      balance =
        await rpcClient.getBalance(address, commitment: Commitment.confirmed).value;
    }

    return balance;
  }

  //Send transaction

  Future<String> sendTransaction(WalletAccount account, Transaction transaction) {
    if (transaction.token is SOL) {
     
      return sendLamportsTo(
       account,transaction
      );
    } else {
    
      return sendSPLTokenTo(
        account, transaction
      );
    }
  }

  /*
   * Send SOLs to an address
   */
  Future<String> sendLamportsTo(
    WalletAccount account, Transaction transaction
     ) async {
     // Convert SOL to lamport
    int lamports = (transaction.amount * lamportsPerSol).toInt();

    
    final instruction = SystemInstruction.transfer(
      fundingAccount: Ed25519HDPublicKey.fromBase58(transaction.origin),
      recipientAccount: Ed25519HDPublicKey.fromBase58(transaction.destination),
      lamports: lamports,
    );

    for (final reference in transaction.references) {
      instruction.accounts.add(
        AccountMeta(
          pubKey: Ed25519HDPublicKey.fromBase58(reference),
          isWriteable: false,
          isSigner: false,
        ),
      );
    }
    

    final message = Message(
      instructions: [instruction],
    );

    final signature =
        await rpcClient.signAndSendTransaction(message, [account.wallet]);

    return signature;
  }

  /*
   * Send a SPL Token to an adress
   */
  Future<String> sendSPLTokenTo(
    WalletAccount account, Transaction transaction
  ) async {
    // Input by the user
    int userAmount = transaction.amount.toInt();
    // Token's configured decimals
    int tokenDecimals = transaction.token.info.decimals;
    int amount = int.parse('$userAmount${'0' * tokenDecimals}');

    var associatedAccounts =
        await getassociatedAccounts(account, transaction.origin, transaction.destination,  transaction.token.mint);

    TokenInstruction instruction = TokenInstruction.transfer(
        amount: amount,
        source: Ed25519HDPublicKey.fromBase58(associatedAccounts[0].pubkey),
        destination:
            Ed25519HDPublicKey.fromBase58(associatedAccounts[1].pubkey),
        owner: Ed25519HDPublicKey.fromBase58(transaction.origin));

    for (final reference in transaction.references) {
      instruction.accounts.add(
        AccountMeta(
          pubKey: Ed25519HDPublicKey.fromBase58(reference),
          isWriteable: false,
          isSigner: false,
        ),
      );
    }

    final message = Message(
      instructions: [instruction],
    );

    final signature =
        await rpcClient.signAndSendTransaction(message, [account.wallet]);

    return signature;
  }

  Future<List<ProgramAccount>> getassociatedAccounts(WalletAccount account,
      String address, String destinationAddress, String tokenMint) async {
    
    var associatedRecipientAccount = await getAssociatedTokenAccount(
      owner: Ed25519HDPublicKey.fromBase58(destinationAddress),
      mint: Ed25519HDPublicKey.fromBase58(tokenMint),
    );

    //if associatedRecipientAccount is null create a new associate token account
    if (associatedRecipientAccount == null) {
      associatedRecipientAccount = await createAssociatedTokenAccount(
          owner: Ed25519HDPublicKey.fromBase58(destinationAddress),
          mint: Ed25519HDPublicKey.fromBase58(tokenMint),
          funder: account.wallet);
    }
    var associatedSenderAccount = await getAssociatedTokenAccount(
      owner: Ed25519HDPublicKey.fromBase58(address),
      mint: Ed25519HDPublicKey.fromBase58(tokenMint),
    );

    //if associatedSenderAccount is null create a new associate token account
    if (associatedSenderAccount == null) {
      associatedSenderAccount = await createAssociatedTokenAccount(
          owner: Ed25519HDPublicKey.fromBase58(address),
          mint: Ed25519HDPublicKey.fromBase58(tokenMint),
          funder: account.wallet);
    }

    return [associatedSenderAccount, associatedRecipientAccount];
  }
}
