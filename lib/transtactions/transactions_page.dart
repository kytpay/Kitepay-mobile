import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/payments/manuallypay_page.dart';
import 'package:kitepay/transtactions/widget/transaction_card.dart';
import 'package:kitepay/transtactions/widget/transaction_card_shimmer.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:kitepay/utilies/const/ui_constant.dart';
import 'package:kitepay/utilies/network_connectivity.dart';

class AccountTransactions extends HookConsumerWidget {
  final Account account;

  const AccountTransactions({Key? key, required this.account})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for changes
    final account = ref.watch(selectedAccountProvider)!;
    ref.watch(accountsProvider);
    //check network connection
    NetworkConnectivity.isConnected(snackbar: true);

    var name = account.name;
    var client = ref.read(networkClient).url.network;
    var coins = getAllPayableTokens(account);
    print("Transaction page: $name, $client, $coins");

    return Padding(
      key: key,
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: UIConstants.ScreenHeight,
        child: RefreshIndicator(
          key: Key(account.address),
          onRefresh: () async {
            // Refresh the account when pulling down
            final accountsProv = ref.read(accountsProvider.notifier);
            await accountsProv.refreshAccount(
                ref.watch(networkClient.notifier).state, account.address);
          },
          child: Builder(builder: (BuildContext context) {
            if (account.isItemLoaded(AccountItem.transactions)) {
              if (account.transactions.isNotEmpty) {
                List<TransactionDetails> txs = account.transactions;

                // Wrap the transactions and block times in the same list
                // List items = getAllBlockNumbers(txs);

                return ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    final tx = txs[index];

                    return TransactionCard(tx, account as WalletAccount);
                  },
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Flexible(
                          child: Image(
                            image: AssetImage('assets/transparent_icon.png'),
                            height: 200,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "No transactions found",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            } else {
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 30,
                itemBuilder: (context, index) {
                  return const TransactionCardWithShimmer();
                },
              );
            }
          }),
        ),
      ),
    );
  }
}
