import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';
import '../features/mrz_scanner/models/mrz_result.dart';

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

  String _formatDateYymmdd(DateTime? date) {
    if (date == null) return "";
    final yy = (date.year % 100).toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yy$mm$dd';
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildFieldValue(String value) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.public, color: Colors.blue, size: 32),
                Text(
                  'ePASSPORT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Face Image
                Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: faceImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(faceImage!, fit: BoxFit.cover),
                        )
                      : const Center(child: Icon(Icons.person, size: 64, color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('SURNAME'),
                      _buildFieldValue(mrzResult.surname),
                      const SizedBox(height: 8),
                      _buildFieldLabel('GIVEN NAMES'),
                      _buildFieldValue(mrzResult.givenNames),
                      const SizedBox(height: 8),
                      _buildFieldLabel('NATIONALITY'),
                      _buildFieldValue(mrzResult.nationality),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('DATE OF BIRTH'),
                                _buildFieldValue(dg1?.mrz.dateOfBirth != null ? _formatDateYymmdd(dg1!.mrz.dateOfBirth) : mrzResult.dateOfBirth),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('DOCUMENT NO.'),
                                _buildFieldValue(dg1?.mrz.documentNumber ?? mrzResult.documentNumber),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('DATE OF EXPIRY'),
                                _buildFieldValue(dg1?.mrz.dateOfExpiry != null ? _formatDateYymmdd(dg1!.mrz.dateOfExpiry) : mrzResult.dateOfExpiry),
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
          ],
        ),
      ),
    );
  }
}
