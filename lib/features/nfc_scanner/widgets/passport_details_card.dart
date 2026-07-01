import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';
import '../../mrz_scanner/models/mrz_result.dart';
import '../../../core/utils/mrz_format_utils.dart';

class PassportDetailsCard extends StatelessWidget {
  final MrzResult mrzResult;
  final Uint8List? faceImage;
  final EfDG1? dg1;

  const PassportDetailsCard({
    super.key,
    required this.mrzResult,
    this.faceImage,
    this.dg1,
  });

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFieldValue(String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Text(
        value.isEmpty ? '—' : value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.public, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'ePASSPORT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.nfc, color: Colors.blue.shade300, size: 24),
              ],
            ),
          ),
          // Body
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/passport_bg_pattern.png'), // Placeholder for a pattern if exists, else it just won't show
                opacity: 0.05,
                fit: BoxFit.cover,
              ),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Face Image
                Container(
                  width: 110,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: faceImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.memory(faceImage!, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Icon(Icons.person, size: 60, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 20),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('SURNAME'),
                      _buildFieldValue(mrzResult.surname),
                      const SizedBox(height: 12),
                      
                      _buildFieldLabel('GIVEN NAMES'),
                      _buildFieldValue(mrzResult.givenNames),
                      const SizedBox(height: 12),
                      
                      _buildFieldLabel('NATIONALITY'),
                      _buildFieldValue(mrzResult.nationality),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('DATE OF BIRTH'),
                                _buildFieldValue(dg1?.mrz.dateOfBirth != null
                                    ? MrzFormatUtils.formatDateToYymmdd(dg1!.mrz.dateOfBirth)
                                    : mrzResult.dateOfBirth),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('SEX'),
                                _buildFieldValue(mrzResult.sex),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('DOCUMENT NO.'),
                                _buildFieldValue(dg1?.mrz.documentNumber ?? mrzResult.documentNumber),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('DATE OF EXPIRY'),
                                _buildFieldValue(dg1?.mrz.dateOfExpiry != null
                                    ? MrzFormatUtils.formatDateToYymmdd(dg1!.mrz.dateOfExpiry)
                                    : mrzResult.dateOfExpiry),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
