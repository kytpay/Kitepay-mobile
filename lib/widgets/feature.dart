// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:kitepay/home/home_page.dart';
// import 'package:kitepay/network/base_account.dart';
// import 'package:kitepay/utilies/const/color_constant.dart';
// import 'package:kitepay/utilies/const/ui_constant.dart';

// class Feature extends StatelessWidget {
//   final Account account;
//   final String feature;
//   final IconData icon;

//   const Feature(
//     this.account,
//     this.feature,
//     this.icon, {
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) {
//             switch (feature) {
//               case 'Create TipLink':
//                 {
//                   print(feature);
//                   return TiplinkPage(account);
//                 }
//               case 'Swap Tokens':
//                 {
//                   return TiplinkPage(account);
//                 }
//               case "C":
//                 {
//                   return TiplinkPage(account);
//                 }

//               case "D":
//                 {
//                   return TiplinkPage(account);
//                 }
//               default:
//                 {
//                   return TiplinkPage(account);
//                 }
//             }
//           },
//         ),
//       ),
//       // switch (feature) {
//       //       case 'Create TipLink':
//       //         {
//       //           print(feature);
//       //           return TiplinkPage(account);
//       //         }
//       //       case 'Swap Tokens':
//       //         {
//       //           return TiplinkPage(account);
//       //         }
//       //       case "C":
//       //         {
//       //           return TiplinkPage(account);
//       //         }

//       //       case "D":
//       //         {
//       //           return TiplinkPage(account);
//       //         }
//       //       default:
//       //         {
//       //           return TiplinkPage(account);
//       //         }
//       //     }
//       // MaterialPageRoute(
//       //   builder: (context) {

//       //   },

//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Flexible(
//               child: SizedBox(
//                 height: UIConstants.ScreenWidth / 2 - 20,
//                 width: UIConstants.ScreenWidth / 2 - 20,
//                 child: Container(
//                   decoration: payButtonBoxDecoration(),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         height: 110,
//                         width: 110,
//                         child: Icon(
//                           icon,
//                           size: 100,
//                           color: kWhiteColor,
//                         ),
//                       ),
//                       Text(feature,
//                           overflow: TextOverflow.visible,
//                           maxLines: 2,
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.openSans(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: kWhiteColor)),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
