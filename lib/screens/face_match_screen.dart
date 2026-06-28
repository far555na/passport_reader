import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/face_match_provider.dart';
import '../providers/nfc_provider.dart';

class FaceMatchScreen extends ConsumerStatefulWidget {
  const FaceMatchScreen({super.key});

  @override
  ConsumerState<FaceMatchScreen> createState() => _FaceMatchScreenState();
}

class _FaceMatchScreenState extends ConsumerState<FaceMatchScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      // Find front camera
      final frontCamera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndMatch() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile selfieFile = await _cameraController!.takePicture();
      final dg2Image = ref.read(nfcProvider).faceImage;
      
      if (dg2Image == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No passport image available to compare.')),
        );
        return;
      }

      await ref.read(faceMatchProvider.notifier).compareFaces(dg2Image, selfieFile.path);

    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(faceMatchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Face Verification')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _isCameraInitialized
                ? CameraPreview(_cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (matchState.isLoading)
                    const CircularProgressIndicator()
                  else if (matchState.error != null)
                    Text(
                      'Error: ${matchState.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    )
                  else if (matchState.isMatch != null)
                    Column(
                      children: [
                        Icon(
                          matchState.isMatch! ? Icons.check_circle : Icons.cancel,
                          color: matchState.isMatch! ? Colors.green : Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          matchState.isMatch! ? 'Match Successful!' : 'Face Mismatch',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Distance Score: ${matchState.score?.toStringAsFixed(3)}'),
                      ],
                    )
                  else
                    const Text('Take a selfie to verify your identity', style: TextStyle(fontSize: 16)),
                  
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: matchState.isLoading ? null : _captureAndMatch,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Selfie & Match'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
