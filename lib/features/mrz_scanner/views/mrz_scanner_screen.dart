import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mrz_result.dart';
import '../view_models/mrz_scanner_view_model.dart';

class MrzScannerScreen extends ConsumerStatefulWidget {
  final Function(MrzResult) onParsed;
  final VoidCallback onManualEntry;

  const MrzScannerScreen({
    super.key,
    required this.onParsed,
    required this.onManualEntry,
  });

  @override
  ConsumerState<MrzScannerScreen> createState() => _MrzScannerScreenState();
}

class _MrzScannerScreenState extends ConsumerState<MrzScannerScreen> {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    CameraDescription selectedCamera = cameras.first;
    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.back) {
        selectedCamera = camera;
        break;
      }
    }

    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    await _cameraController?.initialize();
    if (!mounted) return;

    _cameraController?.startImageStream((image) {
      ref.read(mrzScannerProvider.notifier).processCameraImage(image, selectedCamera);
    });
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for success state to return the result
    ref.listen<MrzScannerState>(mrzScannerProvider, (previous, next) {
      if (next.status == ScannerStatus.success && next.result != null) {
        _cameraController?.stopImageStream();
        widget.onParsed(next.result!);
      }
    });

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Passport MRZ')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          // Alignment guide
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Align MRZ here',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          // Fallback button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Enter Manually'),
                onPressed: () {
                  _cameraController?.stopImageStream();
                  widget.onManualEntry();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
