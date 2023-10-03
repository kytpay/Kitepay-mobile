import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/network/network_client.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:kitepay/provider/account_manager.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/settings/utilities/network_selector.dart';
import 'package:kitepay/utilies/tracker.dart';

class LoadState {
  final ProviderRef ref;
  late Box<dynamic> accountsBox, settingsBox;
  late bool firstLoad;

  LoadState(this.ref);

   SetParams(Box<dynamic> accountsBox, Box<dynamic> settingsBox, bool firstLoad){
    this.accountsBox = accountsBox;
    this.settingsBox = settingsBox;
    this.firstLoad = firstLoad;
    _init(accountsBox, settingsBox, ref, firstLoad);
  }

  void _init(Box<dynamic> accountsBox, Box<dynamic> settingsBox, ProviderRef ref, bool firstLoad) {
    
    if (settingsBox.isNotEmpty) {
      ref.read(selectedNetwork.notifier).state = settingsBox.get('network');
    }

//Only once while loading
    if (firstLoad == false) {
      ref.read(networkClient.notifier).state = NetworkClient(
          url: NetworkUrl.getNetworkUrl(ref.watch(selectedNetwork)));
    }
//}

    initialAccountsBox = accountsBox;

    TokenTrackers tokensTracker = ref.read(tokensTrackerProvider);

// Parse the accounts into instances
    Map<dynamic, dynamic> jsonAccounts = accountsBox.toMap();

    initialAccounts = jsonAccounts.map((accountAddress, account) {
      WalletAccount walletAccount = WalletAccount.withAddress(
        account["balance"],
        account["address"],
        account["name"],
        account["mnemonic"],
        tokensTracker,
      );
      return MapEntry(accountAddress, walletAccount);
    });

    if (initialAccounts.values.isNotEmpty) {
      ref.read(accountsProvider.notifier).selectAccount();
    }

// Create an account manager
    AccountsManager accountManager = ref.read(accountsProvider.notifier);

// Mark the app as loaded
    ref.watch(appLoadedProvider.notifier).state = true;

// Load the whole tokens list
    tokensTracker.loadTokenList();

    for (Account account in initialAccounts.values) {
// Fetch every saved account's balance
// if (account.accountType == AccountType.Wallet) {
      account = account as WalletAccount;

// Load the key's pair if it's a Wallet account
      account.loadKeyPair().then((_) {
//  accountManager.refreshAllState();
      });

// Load the transactions list and the tokens list
      account.loadTransactions(ref.read(networkClient)).then((_) {
//   accountManager.refreshAllState();
      });

      account.loadSplTokens(ref.read(networkClient)).then((_) async {});
    }

//accountManager.refreshAllState();
    accountManager.loadUSDValues(ref.read(networkClient));
    
    
    
  }
  }

