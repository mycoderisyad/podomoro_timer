import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'features/app_l10n.dart';
import 'features/music_l10n.dart';
import 'features/settings_l10n.dart';
import 'features/statistics_l10n.dart';
import 'features/timer_l10n.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  AppL10n get appL10n => AppL10n(l10n);
  MusicL10n get musicL10n => MusicL10n(l10n);
  SettingsL10n get settingsL10n => SettingsL10n(l10n);
  StatisticsL10n get statisticsL10n => StatisticsL10n(l10n);
  TimerL10n get timerL10n => TimerL10n(l10n);
}
