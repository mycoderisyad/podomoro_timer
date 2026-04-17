import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

/// Responsive typography system that scales with the device.
class AppTypography {
  final AppDimens _dimens;

  AppTypography._(this._dimens);

  /// Creates typography scaled to the current screen.
  factory AppTypography.of(BuildContext context) {
    return AppTypography._(AppDimens.of(context));
  }

  // ---------------------------------------------------------------------------
  // Base scale helper
  // ---------------------------------------------------------------------------

  double _s(double fontSize) => fontSize * _dimens.scaleFactor;

  // ---------------------------------------------------------------------------
  // Scaled Font Sizes
  // ---------------------------------------------------------------------------

  double get sizeXXS => _s(10);
  double get sizeXS => _s(11);
  double get sizeS => _s(12);
  double get sizeM => _s(13);
  double get sizeL => _s(14);
  double get sizeML => _s(15);
  double get sizeXL => _s(16);
  double get sizeXXL => _s(18);
  double get sizeXXXL => _s(20);

  // ---------------------------------------------------------------------------
  // Text Styles
  // ---------------------------------------------------------------------------

  /// Page titles, major headers. (Base size: 20)
  TextStyle get titleLarge => TextStyle(
    fontSize: sizeXXXL,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Section titles, card titles. (Base size: 18)
  TextStyle get titleMedium => TextStyle(
    fontSize: sizeXXL,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Subtitles, list item titles, form field labels. (Base size: 15)
  TextStyle get titleSmall => TextStyle(
    fontSize: sizeML,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Primary body text. (Base size: 14)
  TextStyle get bodyLarge => TextStyle(
    fontSize: sizeL,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Secondary body text, descriptions. (Base size: 13)
  TextStyle get bodyMedium => TextStyle(
    fontSize: sizeM,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  /// Small descriptions, timestamps, minor details. (Base size: 12)
  TextStyle get bodySmall => TextStyle(
    fontSize: sizeS,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  /// Tiny captions, micro-copy, badges. (Base size: 11)
  TextStyle get labelSmall => TextStyle(
    fontSize: sizeXS,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// Large buttons. (Base size: 15-16)
  TextStyle get buttonLarge =>
      TextStyle(fontSize: sizeXL, fontWeight: FontWeight.w600);

  /// Standard buttons. (Base size: 14)
  TextStyle get buttonMedium =>
      TextStyle(fontSize: sizeL, fontWeight: FontWeight.w600);
}
