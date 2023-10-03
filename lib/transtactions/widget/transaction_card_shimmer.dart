import 'package:flutter/material.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:shimmer/shimmer.dart';

class TransactionCardWithShimmer extends StatelessWidget {
  const TransactionCardWithShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Shimmer.fromColors(
                  //     baseColor: Colors.grey[300]!,
                  //     highlightColor: Colors.grey[100]!,
                  //     child: Container(
                  //       width: 45,
                  //       height: 35,
                  //       decoration: BoxDecoration(
                  //         color: const Color.fromARGB(150, 0, 0, 0),
                  //         borderRadius: BorderRadius.circular(50),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 200,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(150, 0, 0, 0),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //  Spacer(),
                            Flexible(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 50,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(150, 0, 0, 0),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 180,
                              height: 25,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(150, 0, 0, 0),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Shimmer.fromColors(
                            baseColor: kBackgroundDark10Color,
                            highlightColor: kBackgroundDarkColor,
                            child: Container(
                              width: 200,
                              height: 20,
                              decoration: BoxDecoration(
                                color: kBackgroundDark10Color,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Padding newMethod() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: const Color.fromARGB(150, 0, 0, 0),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(150, 0, 0, 0),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
