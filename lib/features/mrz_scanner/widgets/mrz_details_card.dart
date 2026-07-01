import 'package:flutter/material.dart';
import '../models/mrz_result.dart';
import '../../../core/utils/mrz_format_utils.dart';

class MrzDetailsCard extends StatelessWidget {
  final MrzResult mrz;

  const MrzDetailsCard({super.key, required this.mrz});

  Widget _buildFieldItem(String label, String value, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.document_scanner, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'MRZ DATA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: mrz.isCompositeValid ? Colors.green.shade400 : Colors.orange.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        mrz.isCompositeValid ? Icons.check_circle : Icons.warning,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mrz.isCompositeValid ? 'VALID' : 'CHECK FAILED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildFieldItem('Document Code', MrzFormatUtils.formatDocumentCode(mrz.documentCode))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFieldItem('Issuing State', MrzFormatUtils.formatCountry(mrz.issuingState))),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFieldItem('Surname', MrzFormatUtils.formatName(mrz.surname), isFullWidth: true),
                const SizedBox(height: 12),
                _buildFieldItem('Given Names', MrzFormatUtils.formatName(mrz.givenNames), isFullWidth: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildFieldItem('Document No.', MrzFormatUtils.cleanString(mrz.documentNumber))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFieldItem('Nationality', MrzFormatUtils.formatCountry(mrz.nationality))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildFieldItem('Date of Birth', MrzFormatUtils.formatDate(mrz.dateOfBirth, isExpiry: false))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFieldItem('Sex', MrzFormatUtils.formatSex(mrz.sex))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildFieldItem('Date of Expiry', MrzFormatUtils.formatDate(mrz.dateOfExpiry, isExpiry: true))),
                    if (mrz.personalNumber.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(child: _buildFieldItem('Personal No.', MrzFormatUtils.cleanString(mrz.personalNumber))),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
