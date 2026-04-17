import 'dart:math';

import 'package:flutter/material.dart';

/// Device size categories used for layout decisions.
enum DeviceType { phoneSmall, phoneNormal, phoneLarge, tablet }

/// Provides responsive, proportionally-scaled UI dimensions.
///
/// All values derive from [scaleFactor], which is the ratio of the current
/// screen width to the [_referenceWidth] (360 dp — a typical Android phone).
///
/// Usage:
/// ```dart
/// final dimens = AppDimens.of(context);
/// Padding(padding: EdgeInsets.all(dimens.paddingL));
/// ```
class AppDimens {
  AppDimens._({
    required this.scaleFactor,
    required this.deviceType,
    required this.isLandscape,
    required this.screenWidth,
    required this.screenHeight,
  });

  /// Reference width used to calculate [scaleFactor].
  static const double _referenceWidth = 360;

  /// Breakpoints (shortest side) for device type detection.
  static const double _phoneSmallMax = 340;
  static const double _phoneLargeMin = 400;
  static const double _tabletMin = 600;

  final double scaleFactor;
  final DeviceType deviceType;
  final bool isLandscape;
  final double screenWidth;
  final double screenHeight;

  /// Creates an [AppDimens] instance calibrated to the current screen size.
  ///
  /// Uses the **shortest side** to determine [DeviceType] and the logical
  /// width to drive the [scaleFactor] — so landscape mode still gets
  /// correctly-scaled values even though the width is larger.
  factory AppDimens.of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isLandscape = size.width > size.height;

    // Use the shortest side for device-type classification so rotating
    // the device doesn't suddenly promote it to "tablet".
    final shortestSide = size.shortestSide;
    final DeviceType deviceType;
    if (shortestSide >= _tabletMin) {
      deviceType = DeviceType.tablet;
    } else if (shortestSide >= _phoneLargeMin) {
      deviceType = DeviceType.phoneLarge;
    } else if (shortestSide <= _phoneSmallMax) {
      deviceType = DeviceType.phoneSmall;
    } else {
      deviceType = DeviceType.phoneNormal;
    }

    // Scale based on shortest side so landscape doesn't blow up values.
    final effectiveWidth = isLandscape ? shortestSide : size.width;
    final scaleFactor = (effectiveWidth / _referenceWidth).clamp(0.85, 1.25);

    return AppDimens._(
      scaleFactor: scaleFactor,
      deviceType: deviceType,
      isLandscape: isLandscape,
      screenWidth: size.width,
      screenHeight: size.height,
    );
  }

  // ---------------------------------------------------------------------------
  // Scaled helper
  // ---------------------------------------------------------------------------

  double _s(double value) => (value * scaleFactor).roundToDouble();

  // ---------------------------------------------------------------------------
  // Spacing / Padding tokens
  // ---------------------------------------------------------------------------

  double get spacingXXS => _s(2);
  double get spacingXS => _s(4);
  double get spacingS => _s(8);
  double get spacingM => _s(12);
  double get spacingL => _s(16);
  double get spacingXL => _s(20);
  double get spacingXXL => _s(24);
  double get spacingXXXL => _s(32);

  // Convenience EdgeInsets
  EdgeInsets get paddingAllS => EdgeInsets.all(spacingS);
  EdgeInsets get paddingAllM => EdgeInsets.all(spacingM);
  EdgeInsets get paddingAllL => EdgeInsets.all(spacingL);
  EdgeInsets get paddingAllXL => EdgeInsets.all(spacingXL);
  EdgeInsets get paddingAllXXL => EdgeInsets.all(spacingXXL);

  EdgeInsets get paddingHorizontalL =>
      EdgeInsets.symmetric(horizontal: spacingL);
  EdgeInsets get paddingHorizontalXL =>
      EdgeInsets.symmetric(horizontal: spacingXL);
  EdgeInsets get paddingHorizontalXXL =>
      EdgeInsets.symmetric(horizontal: spacingXXL);

  /// Standard page padding — horizontal XXL + vertical L.
  EdgeInsets get pagePadding =>
      EdgeInsets.symmetric(horizontal: spacingXXL, vertical: spacingL);

  /// List / scrollable content padding.
  EdgeInsets get contentPadding => EdgeInsets.all(spacingL);

  // ---------------------------------------------------------------------------
  // Border Radius tokens
  // ---------------------------------------------------------------------------

  double get radiusXS => _s(6);
  double get radiusS => _s(8);
  double get radiusM => _s(12);
  double get radiusL => _s(16);
  double get radiusXL => _s(20);
  double get radiusXXL => _s(24);
  double get radiusSheet => _s(28);

  BorderRadius get borderRadiusS => BorderRadius.circular(radiusS);
  BorderRadius get borderRadiusM => BorderRadius.circular(radiusM);
  BorderRadius get borderRadiusL => BorderRadius.circular(radiusL);
  BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
  BorderRadius get borderRadiusSheet =>
      BorderRadius.vertical(top: Radius.circular(radiusSheet));

  // ---------------------------------------------------------------------------
  // Icon sizes
  // ---------------------------------------------------------------------------

  double get iconS => _s(16);
  double get iconM => _s(20);
  double get iconL => _s(24);
  double get iconXL => _s(32);
  double get iconXXL => _s(44);
  double get iconHero => _s(56);

  // ---------------------------------------------------------------------------
  // Component sizes
  // ---------------------------------------------------------------------------

  double get buttonHeight => _s(54);
  double get buttonHeightSmall => _s(44);
  double get appBarIconSize => _s(28);
  double get switchTrackWidth => _s(48);

  /// Music player album art / icon container.
  double get musicIconContainer => _s(40);
  double get musicQueueContainer => _s(34);

  /// Queue chip height within the music player.
  double get queueChipHeight => _s(28);

  /// Track number circle in queue sheet.
  double get trackNumberSize => _s(28);

  /// Queue position badge size.
  double get queuePositionBadge => _s(20);

  /// Music card thumbnail size.
  double get musicCardThumbnail => _s(42);

  /// Queue preview chip height.
  double get queuePreviewChipHeight => _s(42);

  // ---------------------------------------------------------------------------
  // Timer-specific sizes
  // ---------------------------------------------------------------------------

  /// Timer ring diameter — adapts to available space and orientation.
  double get timerSize {
    if (isLandscape) {
      // In landscape the height is the limiting dimension.
      final available = screenHeight - _s(120); // rough toolbar + padding
      return available.clamp(_s(160), _s(280));
    }

    switch (deviceType) {
      case DeviceType.phoneSmall:
        return _s(220);
      case DeviceType.phoneNormal:
        return _s(280);
      case DeviceType.phoneLarge:
        return _s(310);
      case DeviceType.tablet:
        return _s(380);
    }
  }

  /// Main timer countdown font size.
  double get timerFontSize {
    if (isLandscape) return _s(44);

    switch (deviceType) {
      case DeviceType.phoneSmall:
        return _s(52);
      case DeviceType.phoneNormal:
        return _s(64);
      case DeviceType.phoneLarge:
        return _s(72);
      case DeviceType.tablet:
        return _s(88);
    }
  }

  /// Circular progress ring stroke width.
  double get progressStrokeWidth {
    if (isLandscape) return _s(14);

    switch (deviceType) {
      case DeviceType.phoneSmall:
        return _s(14);
      case DeviceType.phoneNormal:
        return _s(18);
      case DeviceType.phoneLarge:
        return _s(20);
      case DeviceType.tablet:
        return _s(24);
    }
  }

  // ---------------------------------------------------------------------------
  // Layout constraints
  // ---------------------------------------------------------------------------

  /// Maximum content width for tablet to prevent overly stretched layouts.
  double get maxContentWidth {
    switch (deviceType) {
      case DeviceType.tablet:
        return 600;
      default:
        return double.infinity;
    }
  }

  /// Whether the portrait layout should use compact (scrollable) mode.
  bool get isCompactHeight => !isLandscape && screenHeight < 760;

  // ---------------------------------------------------------------------------
  // Chart dimensions
  // ---------------------------------------------------------------------------

  double get chartHeight => _s(200);

  double get chartBarWidth {
    // This should be adapted based on the selected period by the caller,
    // but we provide a sensible base width that callers can multiply.
    return _s(12);
  }

  // ---------------------------------------------------------------------------
  // Statistics mini-card
  // ---------------------------------------------------------------------------

  double get miniCardPadding => _s(14);

  // ---------------------------------------------------------------------------
  // Convenience helpers
  // ---------------------------------------------------------------------------

  /// Returns the smaller of two values scaled.
  double minScaled(double a, double b) => min(_s(a), _s(b));
}
