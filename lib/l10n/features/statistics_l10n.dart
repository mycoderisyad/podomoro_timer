import '../app_localizations.dart';

class StatisticsL10n {
  const StatisticsL10n(this._base);

  final AppLocalizations _base;

  String get statistics => _base.statistics;
  String get deleteAllStatisticsTooltip => _base.deleteAllStatisticsTooltip;
  String get deleteAllDataTitle => _base.deleteAllDataTitle;
  String get deleteAllDataMessage => _base.deleteAllDataMessage;
  String get cancel => _base.cancel;
  String get delete => _base.delete;
  String get today => _base.today;
  String get week => _base.week;
  String get month => _base.month;
  String get year => _base.year;
  String get sessions => _base.sessions;
  String get focus => _base.focus;
  String get average => _base.average;
  String get focusMinutesChartTitle => _base.focusMinutesChartTitle;
  String get noDataYet => _base.noDataYet;
  String get localeName => _base.localeName;

  String minutesValue(Object value) => _base.minutesValue(value);
}
