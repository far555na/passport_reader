import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';
import '../models/mrz_result.dart';

class DataMatchCard extends StatelessWidget {
  final MrzResult mrzResult;
  final EfDG1? dg1;

  const DataMatchCard({
    super.key,
    required this.mrzResult,
    this.dg1,
  });

  String _formatDateYymmdd(DateTime? date) {
    if (date == null) return "";
    final yy = (date.year % 100).toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yy$mm$dd';
  }

  Widget _buildMatchRow(String field, String ocrValue, String? nfcValue) {
    final isMatch = ocrValue == nfcValue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(field, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OCR: $ocrValue', style: const TextStyle(fontSize: 12)),
                Text('NFC: ${nfcValue ?? "N/A"}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Icon(
            isMatch ? Icons.check_circle : Icons.error,
            color: isMatch ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nfc = dg1?.mrz;

    final nfcDob = _formatDateYymmdd(nfc?.dateOfBirth);
    final nfcDoe = _formatDateYymmdd(nfc?.dateOfExpiry);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Match Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Comparing OCR camera data with verified NFC chip data.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 24),
            _buildMatchRow('Document Code', mrzResult.documentCode, nfc?.documentCode),
            const Divider(),
            _buildMatchRow('Issuing State', mrzResult.issuingState, nfc?.country),
            const Divider(),
            _buildMatchRow('Document No.', mrzResult.documentNumber, nfc?.documentNumber),
            const Divider(),
            _buildMatchRow('Surname', mrzResult.surname, nfc?.lastName),
            const Divider(),
            _buildMatchRow('Given Names', mrzResult.givenNames, nfc?.firstName),
            const Divider(),
            _buildMatchRow('Nationality', mrzResult.nationality, nfc?.nationality),
            const Divider(),
            _buildMatchRow('Sex', mrzResult.sex, nfc?.gender),
            const Divider(),
            _buildMatchRow('Date of Birth', mrzResult.dateOfBirth, nfcDob.isNotEmpty ? nfcDob : null),
            const Divider(),
            _buildMatchRow('Date of Expiry', mrzResult.dateOfExpiry, nfcDoe.isNotEmpty ? nfcDoe : null),
          ],
        ),
      ),
    );
  }
}
