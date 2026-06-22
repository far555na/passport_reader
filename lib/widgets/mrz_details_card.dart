import 'package:flutter/material.dart';
import '../models/mrz_result.dart';

class MrzDetailsCard extends StatelessWidget {
  final MrzResult mrz;

  const MrzDetailsCard({super.key, required this.mrz});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Format badge + composite status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    mrz.formatLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Icon(
                  mrz.isCompositeValid ? Icons.verified : Icons.warning,
                  color: mrz.isCompositeValid ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  mrz.isCompositeValid ? 'Valid' : 'Check failed',
                  style: TextStyle(
                    color: mrz.isCompositeValid ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Common fields
            _fieldRow('Document Code', mrz.documentCode),
            _fieldRow('Issuing State', mrz.issuingState),
            _fieldRow('Surname', mrz.surname),
            _fieldRow('Given Names', mrz.givenNames),
            _fieldRow('Document Number', mrz.documentNumber),
            _fieldRow('Nationality', mrz.nationality),
            _fieldRow('Date of Birth', mrz.dateOfBirth),
            _fieldRow('Sex', mrz.sex),
            _fieldRow('Date of Expiry', mrz.dateOfExpiry),

            // Optional fields (only show if non-empty)
            if (mrz.personalNumber.isNotEmpty)
              _fieldRow('Personal Number', mrz.personalNumber),
            if (mrz.optionalData1.isNotEmpty)
              _fieldRow('Optional Data 1', mrz.optionalData1),
            if (mrz.optionalData2.isNotEmpty)
              _fieldRow('Optional Data 2', mrz.optionalData2),
          ],
        ),
      ),
    );
  }

  Widget _fieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
