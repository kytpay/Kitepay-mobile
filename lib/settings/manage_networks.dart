import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/network/network_client.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/settings/utilities/network_selector.dart';

class ManageNetworkPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networks = NetworkUrl.urlOptions.values.toList();
    final selectNetwork = ref.watch(selectedNetwork);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight,
        title: const Text("Change Network"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
            itemCount: networks.length,
            itemBuilder: ((context, index) {
              return Container(
                margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
                decoration: BoxDecoration(
                    color: kBackgroundDarkColor,
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    networks[index].network,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    networks[index].rpc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: selectNetwork == networks[index].network
                      ? Icon(FontAwesomeIcons.checkCircle)
                      : null,
                  onTap: () {
                    var network = networks[index].network;
                    ref.read(selectedNetwork.notifier).state = network;
                    print('yoyo');
                    saveNetwork(ref, network);
                    print(8);
                  },
                ),
              );

              //networkItem(
              //  ref, networks[index].network, networks[index].rpc);
            })),
      ),
    );
  }
}

Future<void> saveNetwork(WidgetRef ref, String network) async {
  var client = NetworkClient(url: NetworkUrl.getNetworkUrl(network));
  print(0);
  ref.read(networkClient.notifier).state = client;
  print(1);
  var settingsBox = await Hive.openBox('settings');
  settingsBox.put('network', network);
  print(client.url.network);
  ref.read(accountsProvider.notifier).refreshAccounts(client);
}
