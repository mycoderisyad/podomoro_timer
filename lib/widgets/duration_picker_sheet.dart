import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
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
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
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
                    size: 18,
                  ),
                  label: Text(_isCustomMode ? l10n.preset : l10n.custom),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isCustomMode) ...[
              // Custom duration input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            onSubmitted: (_) => _applyCustomDuration(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _applyCustomDuration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.apply,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.durationHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Preset options
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.options.map((duration) {
                  final isSelected = widget.currentValue == duration;
                  final minutes = duration ~/ 60;
                  return GestureDetector(
                    onTap: () => widget.onSelected(duration),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.secondary,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        l10n.minutesValue(minutes),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
