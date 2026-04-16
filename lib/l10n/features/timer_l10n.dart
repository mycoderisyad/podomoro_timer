import '../app_localizations.dart';

class TimerL10n {
  const TimerL10n(this._base);

  final AppLocalizations _base;

  String get focus => _base.focus;
  String get breakLabel => _base.breakLabel;
  String get focusSessionCompleteMessage => _base.focusSessionCompleteMessage;
  String get breakEndedMessage => _base.breakEndedMessage;
  String get focusDuration => _base.focusDuration;
  String get breakDuration => _base.breakDuration;
  String get invalidDurationMessage => _base.invalidDurationMessage;
  String get preset => _base.preset;
  String get custom => _base.custom;
  String get minutes => _base.minutes;
  String get enterMinutes => _base.enterMinutes;
  String get apply => _base.apply;
  String get durationHint => _base.durationHint;
  String get start => _base.start;
  String get pause => _base.pause;
  String get reset => _base.reset;
  String get statisticsTooltip => _base.statisticsTooltip;
  String get settingsTooltip => _base.settingsTooltip;

  String switchToMode(String mode) => _base.switchToMode(mode);
  String sessionCount(int count) => _base.sessionCount(count);
  String minutesValue(Object value) => _base.minutesValue(value);
  String transitionStatusLabel(String mode, int seconds) =>
      _base.transitionStatusLabel(mode, seconds);
  String headingToModeLabel(String mode) => _base.headingToModeLabel(mode);
}
