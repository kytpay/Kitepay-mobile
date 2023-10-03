import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/network/network_client.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/utilies/network_connectivity.dart';
import 'package:kitepay/utilies/tracker.dart';
import 'package:kitepay/network/wallet_account.dart';

class AccountsManager extends StateNotifier<Map<String, Account>> {
  final Map<String, Account>? initialAccounts;
  final StateNotifierProviderRef ref;
  final TokenTrackers tokensTracker;
  final Box<dynamic> accountsBox;

  AccountsManager(
      this.initialAccounts, this.ref, this.tokensTracker, this.accountsBox)
      : super(initialAccounts ?? {});

  Future<void> loadUSDValues(NetworkClient client) async {
    if (await NetworkConnectivity.isConnected() == false) {
      return;
    }

    List<String> tokenNames = tokensTracker.trackers.values
        .where((e) => !e.name.contains("Unknown"))
        .map((e) => e.name.toLowerCase())
        .toList();

    Map<String, double> usdValues = await getTokenUsdValue(tokenNames);

    for (var tracker in tokensTracker.trackers.values) {
      double? usdValue = usdValues[tracker.name.toLowerCase()];

      if (usdValue != null) {
        tokensTracker.setTokenValue(tracker.programMint, usdValue);
      }
    }

    for (final account in state.values) {
      await account.refreshSolBalance(client);
    }
  }

  void selectAccount() {
    final selectedAccount = ref.read(selectedAccountProvider.notifier);

    selectedAccount.state ??= state.values.first;
  }

  Future<void> refreshAccounts(NetworkClient client) async {
    for (final account in state.values) {
      // Refresh the account transactions
      await account.loadTransactions(client);
      // Refresh the tokens list
      await account.loadSplTokens(client);
    }

    // Refresh all balances value
    await loadUSDValues(client);

    //state = [...state, Map.from(state)] as Map<String, Account>;

    // It is not necessary to save it to the DB again

    //  refreshAllState();
  }

  /*
   * Create a wallet instance
   */
  Future<WalletAccount> createWallet(
      NetworkClient client, String accountName) async {
    // Create the account
    WalletAccount walletAccount =
        await WalletAccount.generate(client, accountName, tokensTracker);

    print(walletAccount.mnemonic);

    // Add the account
    state[walletAccount.address] = walletAccount;

    // Refresh the balances
    await loadUSDValues(client);

    // Mark tokens as loaded since there isn't any token to load
    walletAccount.itemsLoaded[AccountItem.tokens] = true;
    walletAccount.itemsLoaded[AccountItem.transactions] = true;

    // Add the account to the DB
    accountsBox.put(walletAccount.address, walletAccount.toJson());

    // Select this wallet if there wasn't any account created
    selectAccount();

    // refreshAllState();

    return walletAccount;
  }

  /*
   * Import a wallet
   */
  Future<WalletAccount> importWallet(
      NetworkClient client, String mnemonic, String accountName) async {
    // Create the account
    WalletAccount walletAccount =
        WalletAccount(0, accountName, mnemonic, tokensTracker);

    // Create key pair
    await walletAccount.loadKeyPair();

    if (await NetworkConnectivity.isConnected()) {
      // Load account transactions
      await walletAccount.loadTransactions(client);

      // Load account tokens
      await walletAccount.loadSplTokens(client);

      // Refresh the balances
      await loadUSDValues(client);
    }

    // Add the account to the state
    state[walletAccount.address] = walletAccount;

    // Add the account to the DB
    accountsBox.put(walletAccount.address, walletAccount.toJson());

    // Select this wallet if there wasn't any account created
    selectAccount();

    // refreshAllState();

    return walletAccount;
  }

  /*
   * Refresh the balanace, tokens, and transactions of an account
   */
  Future<void> refreshAccount(
      NetworkClient client, String accountAddress) async {
    Account? account = state[accountAddress];

    if (account != null) {
      await account.loadSplTokens(client);
      await account.loadTransactions(client);
      await account.refreshSolBalance(client);
    }
  }

  /*
   * Remove an account
   */
  void removeAccount(NetworkClient client, Account account) {
    // Remove from the state
    state.remove(account.address);

    updateState();
    // Remove from the DB
    accountsBox.delete(account.address);
  }

  //App logout
  Future<void> logOut(BuildContext context, String? message) async {
    try {
      // Remove accounts from the DB
      print(accountsBox.length);
      await accountsBox.deleteAll(accountsBox.keys).then((value) async {
        print(accountsBox.length);
        var loginBox = await Hive.openBox('auth');
        loginBox.put('loggedIn', 'false');
        Navigator.pushNamedAndRemoveUntil(
            context, '/onboarding_page', ModalRoute.withName('/'));
        print('VAR4');
        message != null
            ? ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              )
            : null;
      });
    } catch (error) {
      print(error.toString());
    }
    // clear all entries
    state.clear();
    // refreshAllState();
  }

  /*
   * Rename an account's name
   */
  void renameAccount(Account account, String accountName) {
    // Rename
    account.name = accountName;

    updateState();
    //update account data
    accountsBox.put(account.address, account.toJson());
  }

  void updateState() {
    state = Map.from(state);
  }
}
