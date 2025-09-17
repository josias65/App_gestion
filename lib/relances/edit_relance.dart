import 'package:flutter/material.dart';
import 'add_relance.dart';

class EditRelanceScreen extends StatelessWidget {
  final Map<String, dynamic> relance;

  const EditRelanceScreen({
    super.key,
    required this.relance,
    required Map<String, dynamic> relanceToEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AddRelanceScreen(relanceToEdit: relance);
  }
}
