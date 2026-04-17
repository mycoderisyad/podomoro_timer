import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_typography.dart';
import '../l10n/l10n.dart';

class DurationPickerSheet extends StatefulWidget {
  final String title;
  final List<int> options;
  final int currentValue;
  final ValueChanged<int> onSelected;

  const DurationPickerSheet({
    super.key,
    required this.title,
    required this.options,
    required this.currentValue,
    required this.onSelected,
  });

  @override
  State<DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<DurationPickerSheet> {
  bool _isCustomMode = false;
  final TextEditingController _customMinutesController =
      TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Check if current value is not in preset options
    if (!widget.options.contains(widget.currentValue)) {
      _isCustomMode = true;
      _customMinutesController.text = (widget.currentValue ~/ 60).toString();
    }
  }

  @override
  void dispose() {
    _customMinutesController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _applyCustomDuration() {
    final l10n = context.timerL10n;
    final minutes = int.tryParse(_customMinutesController.text);
    if (minutes != null && minutes > 0 && minutes <= 180) {
      widget.onSelected(minutes * 60);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidDurationMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.timerL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: dimens.spacingXXL,
        right: dimens.spacingXXL,
        top: dimens.spacingXXL,
        bottom: MediaQuery.viewInsetsOf(context).bottom + dimens.spacingXXL,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title, style: typography.titleLarge),
                  // Toggle between preset and custom
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isCustomMode = !_isCustomMode;
                        if (_isCustomMode) {
                          _customMinutesController.text =
                              (widget.currentValue ~/ 60).toString();
                        }
                      });
                    },
                    icon: Icon(
                      _isCustomMode
                          ? Icons.grid_view_rounded
                          : Icons.edit_rounded,
                      size: dimens.iconS,
                    ),
                    label: Text(
                      _isCustomMode ? l10n.preset : l10n.custom,
                      style: typography.buttonMedium,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: dimens.spacingXL),
              if (_isCustomMode) ...[
                // Custom duration input
                Container(
                  padding: dimens.paddingAllL,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: dimens.borderRadiusM,
                    border: Border.all(color: AppColors.secondary, width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customMinutesController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              decoration: InputDecoration(
                                labelText: l10n.minutes,
                                hintText: l10n.enterMinutes,
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: dimens.spacingL,
                                  vertical: dimens.spacingM,
                                ),
                              ),
                              style: typography.titleMedium,
                              onSubmitted: (_) => _applyCustomDuration(),
                            ),
                          ),
                          SizedBox(width: dimens.spacingM),
                          ElevatedButton(
                            onPressed: _applyCustomDuration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: dimens.spacingXXL,
                                vertical: dimens.spacingL,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: dimens.borderRadiusM,
                              ),
                            ),
                            child: Text(
                              l10n.apply,
                              style: typography.buttonMedium,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: dimens.spacingS),
                      Text(l10n.durationHint, style: typography.bodySmall),
                    ],
                  ),
                ),
              ] else ...[
                // Preset options
                Wrap(
                  spacing: dimens.spacingM,
                  runSpacing: dimens.spacingM,
                  children: widget.options.map((duration) {
                    final isSelected = widget.currentValue == duration;
                    final minutes = duration ~/ 60;
                    return GestureDetector(
                      onTap: () => widget.onSelected(duration),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: dimens.spacingXL,
                          vertical: dimens.spacingL,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.white,
                          borderRadius: dimens.borderRadiusM,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.secondary,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          l10n.minutesValue(minutes),
                          style: typography.titleSmall.copyWith(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: dimens.spacingL),
            ],
          ),
        ),
      ),
    );
  }
}
