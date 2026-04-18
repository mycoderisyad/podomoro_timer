import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_typography.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.of(context).titleLarge);
  }
}
