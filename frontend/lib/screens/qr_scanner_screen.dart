import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../providers/session_provider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing) return;
      
      setState(() => _isProcessing = true);
      controller.pauseCamera();

      final tableId = scanData.code;
      if (tableId != null && tableId.startsWith('Table')) {
        final success = await Provider.of<SessionProvider>(context, listen: false)
            .startSession(tableId);
        
        if (success && mounted) {
          // Temporarily show success, later we will navigate to MenuScreen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Connected to $tableId!')),
          );
        }
      } else {
        setState(() => _isProcessing = false);
        controller.resumeCamera();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Table QR Code')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.orange,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: _isProcessing 
                ? const CircularProgressIndicator()
                : const Text('Scan the QR code on your table to view the menu.'),
            ),
          )
        ],
      ),
    );
  }
}
