import 'package:flutter/material.dart';
import 'add_relance.dart';

class EditRelanceScreen extends StatelessWidget {
  final Map<String, dynamic> relance;

  const EditRelanceScreen({super.key, required this.relance});

  @override
  Widget build(BuildContext context) {
    return AddRelanceScreen(relanceToEdit: relance);
  }
}
