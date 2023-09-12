import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kitepay/home/models/info_card_model.dart';
import 'package:kitepay/home/widgets/feature.dart';
import 'package:kitepay/home/widgets/paymethods.dart';
import 'package:kitepay/payments/manuallypay_page.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/utilies/const/ui_constant.dart';
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
              height: UIConstants.ScreenHeight / 4.5,
              width: UIConstants.ScreenWidth,
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
                      height: UIConstants.ScreenHeight / 4.5,
                      width: UIConstants.ScreenWidth,
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
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
              decoration: BoxDecoration(
                  color: kWhiteColor, borderRadius: BorderRadius.circular(28)),
              child: Column(
                children: [
                  GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    children: [
                      Feature(this.widget.account,'Create TipLink', Icons.add_link),
                      Feature(this.widget.account,'Swap Tokens', Icons.contactless),
                      Feature(this.widget.account, 'Private Transfer', Icons.security),
                      Feature(this.widget.account, 'DePIN', Icons.map),
                    ],
                  ),
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



BoxDecoration payButtonBoxDecoration() {
  return BoxDecoration(
      borderRadius: BorderRadius.circular(15), gradient: kGradient);
}
