import 'en/app_en.dart';
import 'en/music_en.dart';
import 'en/settings_en.dart';
import 'en/statistics_en.dart';
import 'en/timer_en.dart';
import 'id/app_id.dart';
import 'id/music_id.dart';
import 'id/settings_id.dart';
import 'id/statistics_id.dart';
import 'id/timer_id.dart';

// Merge per-feature translation files into one locale registry.
const Map<String, Map<String, String>> localizedValues = {
  'en': {...appEn, ...settingsEn, ...statisticsEn, ...timerEn, ...musicEn},
  'id': {...appId, ...settingsId, ...statisticsId, ...timerId, ...musicId},
};
