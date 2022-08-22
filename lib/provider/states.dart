import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/network/network_client.dart';
import 'package:kitepay/provider/account_manager.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/settings/utilities/network_selector.dart';
import 'package:kitepay/utilies/tracker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitepay/network/wallet_account.dart';

final appLoadedProvider = StateProvider<bool>((_) {
  return false;
});

final isNfcEnabled = StateProvider<bool>((_) {
  return false;
});

final networkClient = StateProvider<NetworkClient>((_) {
  return NetworkClient(url: NetworkUrl.getNetworkUrl(Network.Mainnet.name));
});

final selectedNetwork = StateProvider<String>((_) {
  return Network.Mainnet.name;
});

final selectedAccountProvider = StateProvider<Account?>((_) {
  return null;
});

final tokensTrackerProvider = Provider<TokenTrackers>((_) {
  return TokenTrackers();
});

var initialAccountsBox;
late Map<String, Account> initialAccounts;
final accountsProvider =
    StateNotifierProvider<AccountsManager, Map<String, Account>>((ref) {
  TokenTrackers tokensTracker = ref.watch(tokensTrackerProvider);
  return AccountsManager(
      initialAccounts, ref, tokensTracker, initialAccountsBox as Box<dynamic>);
});

Future<Map<String, Box<dynamic>>> hiveInit() async {
  await Hive.initFlutter('hive');

  var loginBox = await Hive.openBox('auth');
  var accountsBox = await Hive.openBox('accounts');
  var settingsBox = await Hive.openBox('settings');

  var boxes = {
    'auth': loginBox,
    'accounts': accountsBox,
    'settings': settingsBox
  };
  return boxes;
}

/*
 * Read, parse andl load the stored data from Hive into the state providers
 */
void loadState(Box<dynamic> accountsBox, Box<dynamic> settingsBox,
    WidgetRef ref, bool networkConnected, bool firstLoad) {
  if (settingsBox.isNotEmpty) {
    ref.read(selectedNetwork.notifier).state = settingsBox.get('network');
  }

//  var materialAppContext = AppNavigation.materialKey.currentContext;

//if(materialAppContext != null){

  //  materialAppContext.read().state = NetworkClient(
  //     url: NetworkUrl.getNetworkUrl(ref.watch(selectedNetwork)));
//  Future.delayed(
//         Duration.zero,
//       () => Provider.of
//        materialAppContext!
//           .read(networkClient)
//           .getDetailedWeather(widget.masterWeather.cityName));

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
