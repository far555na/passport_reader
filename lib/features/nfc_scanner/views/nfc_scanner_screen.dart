import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/nfc_scanner_view_model.dart';
import '../../mrz_scanner/view_models/mrz_state_view_model.dart';
import '../widgets/passport_details_card.dart';
import '../../face_match/views/face_match_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/mrz_format_utils.dart';

class NfcScannerScreen extends ConsumerStatefulWidget {
  const NfcScannerScreen({super.key});

  @override
  ConsumerState<NfcScannerScreen> createState() => _NfcScannerScreenState();
}

class _NfcScannerScreenState extends ConsumerState<NfcScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mrzResult = ref.read(mrzProvider);
      if (mrzResult != null) {
        ref.read(nfcScannerViewModelProvider.notifier).startScan(mrzResult);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No MRZ data available')),
        );
        Navigator.pop(context);
      }
    });
  }

  Widget _buildChecklistItem(String title, bool isVerified, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.cancel,
            color: isVerified ? AppTheme.successColor : AppTheme.errorColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityChecklists(dynamic nfcState, dynamic mrzResult) {
    // 1. DG Compare (Camera MRZ vs NFC DG1 MRZ)
    final dg1Mrz = nfcState.dg1?.mrz;
    final bool docNoMatch = dg1Mrz != null && MrzFormatUtils.cleanString(dg1Mrz.documentNumber) == MrzFormatUtils.cleanString(mrzResult.documentNumber);
    final bool dobMatch = dg1Mrz != null && MrzFormatUtils.formatDateToYymmdd(dg1Mrz.dateOfBirth) == mrzResult.dateOfBirth;
    final bool doeMatch = dg1Mrz != null && MrzFormatUtils.formatDateToYymmdd(dg1Mrz.dateOfExpiry) == mrzResult.dateOfExpiry;
    final bool allDgMatch = docNoMatch && dobMatch && doeMatch;

    // 2. 3-step PA Verification
    final paResult = nfcState.paResult;
    final bool isDataIntegrityVerified = paResult?.isDataIntegrityVerified ?? false;
    final bool isSignatureVerified = paResult?.isSignatureVerified ?? false;
    final bool isCscaVerified = paResult?.isCscaVerified ?? false;
    final bool isFullyVerified = paResult?.isFullyVerified ?? false;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: const Text(
          'Security Details & Verification',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
        subtitle: Text(
          (allDgMatch && isFullyVerified) ? 'All security checks passed' : 'Some checks failed or pending',
          style: TextStyle(
            color: (allDgMatch && isFullyVerified) ? AppTheme.successColor : AppTheme.errorColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: Icon(
          (allDgMatch && isFullyVerified) ? Icons.verified_user : Icons.gpp_maybe,
          color: (allDgMatch && isFullyVerified) ? AppTheme.successColor : AppTheme.warningColor,
          size: 32,
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const Divider(),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Data Group (DG) Match', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          _buildChecklistItem('Document Number Match', docNoMatch, subtitle: 'Optical MRZ matches NFC Data Group 1'),
          _buildChecklistItem('Date of Birth Match', dobMatch, subtitle: 'Optical MRZ matches NFC Data Group 1'),
          _buildChecklistItem('Date of Expiry Match', doeMatch, subtitle: 'Optical MRZ matches NFC Data Group 1'),
          
          const SizedBox(height: 16),
          const Divider(),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Passive Authentication (PA)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          _buildChecklistItem('Data Integrity Verified', isDataIntegrityVerified, subtitle: 'Data Group hashes match Document Security Object (SOD)'),
          _buildChecklistItem('Signature Verified', isSignatureVerified, subtitle: 'Document Signer Certificate (DSC) signature over SOD is valid'),
          _buildChecklistItem('CSCA Verified', isCscaVerified, subtitle: 'DSC is trusted by Country Signing Certificate Authority (CSCA)'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nfcState = ref.watch(nfcScannerViewModelProvider);
    final mrzResult = ref.read(mrzProvider);

    if (mrzResult == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Error: MRZ Data missing')),
      );
    }

    if (!nfcState.isScanning && nfcState.progress == 1.0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verified Identity')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PassportDetailsCard(
                mrzResult: mrzResult,
                faceImage: nfcState.faceImage,
                dg1: nfcState.dg1,
              ),
              const SizedBox(height: 24),
              
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: _buildSecurityChecklists(nfcState, mrzResult),
              ),

              const SizedBox(height: 32),
              if (nfcState.faceImage != null)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FaceMatchScreen(
                          dg2Image: nfcState.faceImage!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.face),
                  label: const Text('Proceed to Face Match'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Return to Home', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reading NFC Chip')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (nfcState.isScanning)
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: nfcState.progress > 0 ? nfcState.progress : null,
                        strokeWidth: 6,
                        color: AppTheme.accentColor,
                        backgroundColor: AppTheme.accentColor.withValues(alpha: 0.2),
                      ),
                    ),
                  Icon(
                    Icons.contactless,
                    size: 80,
                    color: nfcState.isScanning ? AppTheme.primaryColor : Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                nfcState.statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.primaryColor),
              ),
              if (nfcState.hasError) ...[
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(nfcScannerViewModelProvider.notifier).startScan(mrzResult);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Scan'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
