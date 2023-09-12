import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/payments/manuallypay_page.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/utilies/const/ui_constant.dart';
import 'package:kitepay/utilies/solanapay.dart';
import 'package:kitepay/provider/states.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'dart:ui' as ui;
import 'package:image/image.dart' as image;

class ProfilePage extends HookConsumerWidget {
  final Account account;

  const ProfilePage({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var sendAmount = 0.0;
    final transactionData = useState<TransactionSolanaPay>(TransactionSolanaPay(
      recipient: account.address,
      amount: sendAmount,
    ));

    String address = account.address;

    var name = account.name;
    var client = ref.read(networkClient).url.network;
    var coins = getAllPayableTokens(account);
    print("Receive page: $name, $client, $coins");

    GlobalKey repaintGlobalKey = GlobalKey();

    return Padding(
      padding: const EdgeInsets.all(20),
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
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 80,
                backgroundImage: AssetImage('assets/profile.png'),
              ),
              Text(account.name, style: TextStyle(fontSize: 25)),
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 10, right: 10, bottom: 0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: OutlinedButton(
                    onPressed: () {
                      copyPublicKey(context);
                    },
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
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    key: repaintGlobalKey,
                    child: Container(
                      color: Colors.white,
                      child: PrettyQr(
                        image: AssetImage('assets/png/kite_qr1.png'),
                        typeNumber: 5,
                        size: 200,
                        data: transactionData.value.toUri(),
                        errorCorrectLevel: QrErrorCorrectLevel.M,
                        roundEdges: true,
                      ),
                    ),
                    // QrImage(
                    //   data: transactionData.value.toUri(),
                    //   errorCorrectionLevel: QrErrorCorrectLevel.M,
                    //   version: QrVersions.auto,
                    //   embeddedImage: AssetImage('assets/png/ko.png'),
                    //   embeddedImageStyle: QrEmbeddedImageStyle(
                    //     size: Size(80, 80),
                    //   ),
                    // ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 0.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(kPrimanyColor),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                    side: BorderSide(color: kPrimanyColor)))),
                        child: const Text(
                          'DOWNLOAD',
                          style: TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => downloadQR(
                            context, repaintGlobalKey, transactionData.value),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 0.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                    side: BorderSide(color: kPrimanyColor)))),
                        child: const Text(
                          'SHARE',
                          style: TextStyle(
                              color: kPrimanyColor,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => shareQR(
                            context, repaintGlobalKey, transactionData.value),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void copyPublicKey(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: account.address),
    ).then(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Copied"),
          ),
        );
      },
    );
  }

  downloadQR(BuildContext context, GlobalKey key,
      TransactionSolanaPay transactionData) async {
    String? path = await createQR(context, key, transactionData);

    if (path != null) {
      final success = await GallerySaver.saveImage(path);

      ScaffoldMessenger.of(context).showSnackBar((SnackBar(
        content: success!
            ? Text('Profile QR Downloaded!')
            : Text('Error downloading the QR'),
      )));
    }
  }
}

shareQR(BuildContext context, GlobalKey key,
    TransactionSolanaPay transactionData) async {
  String? path = await createQR(context, key, transactionData);

  if (path != null) {
    await Share.shareFiles([path],
        mimeTypes: ["image/png"],
        subject: 'My Kitepay🪁 QR code',
        text: 'Scan and pay SOL & SPL tokens');
  }
}

Future<void> writeToFile(ByteData data, String path) async {
  final buffer = data.buffer;
  await File(path)
      .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

Future<String?> createQR(BuildContext context, GlobalKey key,
    TransactionSolanaPay transactionData) async {
  String qr = transactionData.toUri();

  // random file name
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  final ts = DateTime.now().millisecondsSinceEpoch.toString();
  String? path = '$tempPath/$ts.png';

  // QR Validation
  final qrValidationResult = QrValidator.validate(
    data: qr,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.L,
  );

  // Check if QR is valid
  if (qrValidationResult.status == QrValidationStatus.valid) {
    //If the verification is successful, we get our QrCode
    //final qrCode = qrValidationResult.qrCode;

    //create painter
    // final painter = QrPainter.withQr(
    //   qr: qrCode!,
    //   color: Color.fromARGB(255, 255, 255, 255),
    //   gapless: true,
    //   embeddedImageStyle: QrEmbeddedImageStyle(
    //     size: Size(500, 500),
    //   ),
    //   embeddedImage: await getUiImage('assets/png/ko.png', 400, 400),
    // );

    // final picData =
    //     await painter.toImageData(2048, format: ImageByteFormat.png);

    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    // await writeToFile(byteData, path);

    await File(path).writeAsBytes(pngBytes);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Some error occured creating the QR, please try again!"),
      ),
    );
    //Assign null ro path if QrValidationStatus is not valid
    path = null;
  }
  return path;
}

// Converting Assert to ui.Image
Future<ui.Image> getUiImage(
    String imageAssetPath, int height, int width) async {
  final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);

  image.Image? baseSizeImage =
      image.decodeImage(assetImageByteData.buffer.asUint8List());

  image.Image resizeImage =
      image.copyResize(baseSizeImage!, height: height, width: width);

  ui.Codec codec = await ui
      .instantiateImageCodec(Uint8List.fromList(image.encodePng(resizeImage)));

  ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}
