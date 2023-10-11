import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/components/material_key.dart';
import 'package:kitepay/firebase_options.dart';
import 'package:kitepay/home/base_page.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:kitepay/payments/utilities/uri_pay.dart';
import 'package:kitepay/settings/manage_accounts.dart';
import 'package:kitepay/onboarding/onboarding_page.dart';
import 'package:kitepay/settings/manage_networks.dart';
import 'package:kitepay/settings/settings.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/utilies/const/material_colors.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/onboarding/create_wallet.dart';
import 'package:kitepay/onboarding/import_wallet.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kitepay/utilies/network_connectivity.dart';
import 'package:uni_links/uni_links.dart';

var loggedIn;
var boxes;
bool firstLoad = false;
// ignore: unused_element
StreamSubscription? _sub;
var networkConnected;

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  boxes = await hiveInit();
  var loginBox = boxes['auth'];
  loggedIn = loginBox.get('loggedIn');
  print('LoggedIn: ${loginBox.get('loggedIn')}');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      // ignore: body_might_complete_normally_catch_error
      .catchError((e) {
    print(" Error : ${e.toString()}");
  });

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  //network check to pass the value to loadstate()

  networkConnected = await NetworkConnectivity.isConnected();

  final container = ProviderContainer();

  container
      .read(loadStateProvider)
      .SetParams(boxes['accounts'], boxes['settings'], firstLoad);

  runApp(UncontrolledProviderScope(
    container: container,
    child: const App(),
  ));
}

class App extends HookConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _handleIncomingLinks(ref);
    _handleInitialUri(ref);

    //Remove Splash screen
    FlutterNativeSplash.remove();
    return MaterialApp(
      title: 'Kitepay',
      navigatorKey: AppNavigation.materialKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch:
              CustomColors.generateMaterialColorFromColor(kPrimanyColor),
        ),
      ),
      initialRoute: loggedIn == 'true' ? '/home' : '/onboarding_page',
      routes: {
        '/home': (_) => BasePage(),
        '/create_wallet': (_) => CreateWallet(),
        '/import_wallet': (_) => ImportWallet(),
        '/onboarding_page': (_) => OnBoardingPage(),
        '/manage_accounts': (_) => ManageAccountsPage(),
        '/settings': (_) => SettingsPage(),
        '/manage_networks': (_) => ManageNetworkPage(),
      },
    );
  }
}

/// Handle incoming links - the ones that the app will recieve from the OS
/// while already started.
void _handleIncomingLinks(WidgetRef ref) {
  if (!kIsWeb) {
    // It will handle app links while the app is already started - be it in
    // the foreground or in the background.
    _sub = uriLinkStream.listen((Uri? uri) async {
      print('got uri: $uri');

      if (uri != null) {
        final account = ref.read(selectedAccountProvider);
        print(uri.toString());
        await uriPay(AppNavigation.materialKey.currentContext!,
            account as WalletAccount, uri.toString());
      }
    }, onError: (Object err) {
      print('got err: $err');
    });
  }
}

/// Handle the initial Uri - the one the app was started with
///
/// **ATTENTION**: `getInitialLink`/`getInitialUri` should be handled
/// ONLY ONCE in your app's lifetime, since it is not meant to change
/// throughout your app's life.
///
/// We handle all exceptions, since it is called from initState.
Future<void> _handleInitialUri(WidgetRef ref) async {
  if (!firstLoad) {
    firstLoad = true;
    print('_handleInitialUri called');
    try {
      final uri = await getInitialUri();
      if (uri != null) {
        print('got initial uri: $uri');
        final account = ref.read(selectedAccountProvider);
        print(uri.toString());
        await uriPay(AppNavigation.materialKey.currentContext!,
            account as WalletAccount, uri.toString());
      } else {
        print('no initial uri');
      }
    } on PlatformException {
      // Platform messages may fail but we ignore the  exception
      print('falied to get initial uri');
    } on FormatException catch (err) {
      print('invalid uri $err');
    }
  }
}
