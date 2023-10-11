import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/balance/balance_page.dart';
import 'package:kitepay/home/models/info_card_model.dart';
import 'package:kitepay/payments/manuallypay_page.dart';
import 'package:kitepay/payments/receivepay_page.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/payments/utilities/qr_pay.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:kitepay/utilies/url_launch.dart';

class HomePage extends StatefulWidget {
  final Account account;

  HomePage(this.account);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Current selected
  int current = 0;
  int cardNo = 0;

  // Handle Indicator
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    double width_ItemContainer = MediaQuery.of(context).size.width;
    double height_ItemContainer = 180;

    String address = this.widget.account.address;

    var name = this.widget.account.name;

    var coins = getAllPayableTokens(this.widget.account);
    print("Home screen: $name,  $coins");
    return Scaffold(
      backgroundColor: kBackgroundDarkColor,
      body: Container(
        margin: EdgeInsets.only(top: 8),
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Container(
              height: height_ItemContainer,
              width: width_ItemContainer,
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  viewportFraction: 0.95,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 1000),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  scrollDirection: Axis.horizontal,
                ),
                itemCount: cards.length,
                itemBuilder:
                    (BuildContext context, int index, int pageViewIndex) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        cardNo = index;
                        if (cards[index].url != null) {
                          LaunchURL.openURL(context, cards[index].url!);
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      height: height_ItemContainer,
                      width: width_ItemContainer,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: Color(
                            cards[index].backgroundColor ?? kWhiteColor.value),
                        image: DecorationImage(
                            image: AssetImage(cards[index].backgroundImage ??
                                "assets/png/kitepay.png"),
                            fit: BoxFit.fill),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: 20,
                            bottom: 15,
                            child: Text(
                              cards[index].caption ?? " ",
                              style: GoogleFonts.inter(
                                  color: kBlackColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
              decoration: BoxDecoration(
                  color: kWhiteColor, borderRadius: BorderRadius.circular(28)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, bottom: 13, top: 10, right: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Transfer',
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: kBlackColor),
                      ),
                    ),
                  ),
                  PayMethods(this.widget.account),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 15, right: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Public Key',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kBlackColor),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        copyPublicKey(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(color: kWhiteColor),
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.copy, size: 20),
                            ),
                            Flexible(
                              child: Text(
                                "$address",
                                style: TextStyle(
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                    color: kPrimanyColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
              decoration: BoxDecoration(
                  color: kWhiteColor, borderRadius: BorderRadius.circular(28)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, bottom: 13, top: 10, right: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Coming Soon...',
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      UpcomingFeatures(
                          'NFT Billing', FontAwesomeIcons.stickyNote),
                      UpcomingFeatures('NFC Payments', Icons.contactless),
                      UpcomingFeatures('Solana-UPI Bridge', Icons.double_arrow),
                      UpcomingFeatures('On-Chain BNPL', FontAwesomeIcons.coins),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void copyPublicKey(BuildContext context) {
    return setState(() {
      Clipboard.setData(
        ClipboardData(text: this.widget.account.address),
      ).then(
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Copied"),
            ),
          );
        },
      );
    });
  }
}

class UpcomingFeatures extends StatelessWidget {
  final String feature;
  final IconData icon;

  const UpcomingFeatures(
    this.feature,
    this.icon, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(5),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey,
          //     offset: Offset(0.0, 1.0), //(x,y)
          //     blurRadius: 6.0,
          //   ),
          // ],
        ),
        child: Row(
          //  crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: SizedBox(
                height: 60,
                width: 60,
                child: Container(
                  decoration: payButtonBoxDecoration(),
                  child: IconButton(
                      color: kWhiteColor,
                      icon: Icon(
                        icon,
                        size: 40,
                      ),
                      onPressed: () => null),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                feature,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PayMethods extends ConsumerWidget {
  final Account account;

  const PayMethods(this.account, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAccount = ref.watch(selectedAccountProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: selectedAccount is WalletAccount
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: Container(
                          decoration: payButtonBoxDecoration(),
                          child: IconButton(
                              color: kWhiteColor,
                              icon: Icon(
                                Icons.keyboard_double_arrow_up_rounded,
                                size: 40,
                              ),
                              onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ManuallyPayPage(
                                          account as WalletAccount),
                                    ),
                                  )
                              // makePaymentManuallyDialog(context, selectedAccount),
                              ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text("Pay to Address",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.w600)),
                    ],
                  )
                : null, // <-- Text
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: selectedAccount is WalletAccount
                ? Column(
                    children: [
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: Container(
                          decoration: payButtonBoxDecoration(),
                          child: IconButton(
                            color: kWhiteColor,
                            icon: Icon(
                              Icons.qr_code_scanner,
                              size: 40,
                            ),
                            onPressed: () {
                              qrPay(context, selectedAccount);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Pay to QR",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12.0, fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                : null, // <-- Text
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Container(
                    decoration: payButtonBoxDecoration(),
                    child: IconButton(
                        color: kWhiteColor,
                        icon: Icon(
                          Icons.person,
                          size: 40,
                        ),
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReceivePayPage(account),
                              ),
                            )
                        //createQRTransaction(context, account),
                        ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Receive Pay",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                ),
              ],
            ), // <-- Text
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Container(
                    decoration: payButtonBoxDecoration(),
                    child: IconButton(
                      color: kWhiteColor,
                      icon: Icon(
                        Icons.account_balance,
                        size: 40,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BalancePage(account),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Check Balance",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                ),
              ],
            ), // <-- Text
          ),
        ),
      ],
    );
  }
}

BoxDecoration payButtonBoxDecoration() {
  return BoxDecoration(
      borderRadius: BorderRadius.circular(15), gradient: kGradient);
}
