import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nostr_pay_kids/component_library/src/flushbar_helper.dart';

import 'scan_overlay.dart';

final Logger _logger = Logger('QRScanView');

class QrScanView extends StatefulWidget {
  const QrScanView({super.key});

  @override
  State<QrScanView> createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool popped = false;
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  late StreamSubscription<BarcodeCapture> _barcodeSubscription;

  @override
  void initState() {
    super.initState();
    _barcodeSubscription = cameraController.barcodes.listen(onDetect);
  }

  void onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final Barcode barcode in barcodes) {
      _logger.info('Barcode detected. ${barcode.displayValue}');
      if (popped || !mounted) {
        _logger.info('Skipping, already popped or not mounted');
        return;
      }
      final String? code = barcode.rawValue;
      if (code == null) {
        _logger.warning('Failed to scan QR code.');
      } else {
        popped = true;
        _logger.info('Popping read QR code: $code');
        Navigator.of(context).pop(code);
      }
    }
  }

  @override
  void dispose() {
    _barcodeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: MobileScanner(
                    key: qrKey,
                    controller: cameraController,
                  ),
                ),
              ],
            ),
          ),
          const ScanOverlay(),
          SafeArea(
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: 10,
                  top: 5,
                  child: ImagePickerButton(
                    cameraController: cameraController,
                    onDetect: onDetect,
                  ),
                ),
                if (defaultTargetPlatform == TargetPlatform.iOS) ...<Widget>[
                  const Positioned(
                    bottom: 30.0,
                    right: 0,
                    left: 0,
                    child: QRScanCancelButton(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImagePickerButton extends StatefulWidget {
  final MobileScannerController cameraController;
  final void Function(BarcodeCapture capture) onDetect;

  const ImagePickerButton({
    required this.cameraController,
    required this.onDetect,
    super.key,
  });

  @override
  State<ImagePickerButton> createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  bool _isLoading = false; // Add a loading state

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      icon:
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_outlined),
              ),
      color: Colors.white,
      onPressed:
          _isLoading
              ? null
              : () async {
                setState(() {
                  _isLoading = true;
                });

                final ImagePicker picker = ImagePicker();

                final XFile? image = await picker
                    .pickImage(source: ImageSource.gallery)
                    .catchError((Object err) {
                      _logger.warning('Failed to pick image', err);
                      return null;
                    });

                if (image == null) {
                  return;
                }

                final String filePath = image.path;
                _logger.info('Picked image: $filePath');

                final BarcodeCapture? barcodes = await widget.cameraController
                    .analyzeImage(filePath)
                    .catchError((Object err) {
                      _logger.warning('Failed to analyze image', err);
                      return null;
                    });

                // At the end of the onPressed method, after everything is done:
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  }); // Stop loading
                }

                if (barcodes == null) {
                  _logger.info('No QR code found in image');
                  showWarningFlushbar(
                    context,
                    message: 'No QR Code found in the image',
                  );
                } else {
                  widget.onDetect(barcodes);
                }
              },
    );
  }
}

class QRScanCancelButton extends StatelessWidget {
  const QRScanCancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the theme

    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          border: Border.all(color: Colors.white.withValues(alpha: .8)),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 35),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: theme.textTheme.titleMedium),
        ),
      ),
    );
  }
}
