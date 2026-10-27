import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import 'project_summary_body.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Summary')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ProjectSummaryBody(user: user),
      ),
    );
  }
}
