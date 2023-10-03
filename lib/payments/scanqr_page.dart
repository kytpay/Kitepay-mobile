import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrPage extends StatefulWidget {
  ScanQrPage({Key? key}) : super(key: key);

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  late bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    double scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan & Pay')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController controller) {
                controller.scannedDataStream.listen((scanData) {
                  if (hasScanned == false) {
                    hasScanned = true;
                    print(scanData.toString());
                    Navigator.pop(context, scanData);
                  }
                });
              },
              overlay: QrScannerOverlayShape(
                borderColor: Colors.green,
                borderWidth: 2,
                cutOutSize: scanArea,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
