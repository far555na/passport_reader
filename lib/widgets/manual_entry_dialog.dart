import 'package:flutter/material.dart';
import '../models/mrz_result.dart';

class ManualEntryDialog extends StatefulWidget {
  final Function(MrzResult) onSubmit;

  const ManualEntryDialog({super.key, required this.onSubmit});

  @override
  State<ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<ManualEntryDialog> {
  final _docNumController = TextEditingController();
  final _dobController = TextEditingController();
  final _doeController = TextEditingController();

  @override
  void dispose() {
    _docNumController.dispose();
    _dobController.dispose();
    _doeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manual Entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _docNumController, decoration: const InputDecoration(labelText: 'Document Number')),
          TextField(controller: _dobController, decoration: const InputDecoration(labelText: 'Date of Birth (YYMMDD)')),
          TextField(controller: _doeController, decoration: const InputDecoration(labelText: 'Date of Expiry (YYMMDD)')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final mrzData = MrzResult(
              format: MrzFormat.td3,
              documentCode: 'P',
              issuingState: '',
              surname: '',
              givenNames: '',
              documentNumber: _docNumController.text,
              nationality: '',
              dateOfBirth: _dobController.text,
              sex: '',
              dateOfExpiry: _doeController.text,
              isCompositeValid: false,
              rawLines: [],
            );
            Navigator.pop(context);
            widget.onSubmit(mrzData);
          },
          child: const Text('Submit'),
        )
      ],
    );
  }
}
