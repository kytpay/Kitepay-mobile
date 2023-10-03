import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/network/network_client.dart';
import 'package:kitepay/provider/account_manager.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/settings/utilities/network_selector.dart';
import 'package:kitepay/utilies/loadstate.dart';
import 'package:kitepay/utilies/tracker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final loadStateProvider = Provider<LoadState>((ref) {
  return LoadState(ref);
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
