import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';
import '../models/passive_auth_verification_result.dart';

class ChipTechnicalDetailsCard extends StatelessWidget {
  final EfDG2? dg2;
  final PassiveAuthVerificationResult? paResult;

  const ChipTechnicalDetailsCard({
    super.key,
    this.dg2,
    this.paResult,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chip Technical Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.face, color: Colors.blue),
              title: const Text('DG2 (Biometrics)'),
              subtitle: dg2 != null
                  ? Text('Image: ${dg2!.imageWidth}x${dg2!.imageHeight}\nGender: ${dg2!.gender}, Eye Color: ${dg2!.eyeColor}')
                  : const Text('Not available'),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                paResult?.isDataIntegrityVerified == true ? Icons.verified_user : Icons.warning,
                color: paResult?.isDataIntegrityVerified == true ? Colors.green : Colors.orange,
              ),
              title: const Text('Passive Authentication'),
              subtitle: paResult != null
                  ? Text('Data Integrity: ${paResult!.isDataIntegrityVerified ? "Verified (Hashes Match)" : "Unverified/Tampered"}\nSignature: ${paResult!.isSignatureVerified ? "Verified" : "Unverified (X.509 stub)"}')
                  : const Text('Not available'),
            ),
          ],
        ),
      ),
    );
  }
}
