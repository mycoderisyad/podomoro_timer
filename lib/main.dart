import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:podomoro_timer/core/theme/app_theme.dart';
import 'package:podomoro_timer/features/timer/presentation/pages/timer_page.dart';
import 'package:podomoro_timer/l10n/app_localizations.dart';
import 'package:podomoro_timer/l10n/l10n.dart';
import 'package:podomoro_timer/shared/settings/app_settings.dart';
import 'package:podomoro_timer/shared/settings/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  await initializeDateFormatting('id');
  final settingsRepository = const SharedPreferencesSettingsRepository();
  final initialSettings = await settingsRepository.loadSettings();
  runApp(MainApp(initialSettings: initialSettings));
}

class MainApp extends StatefulWidget {
  final AppSettings initialSettings;

  const MainApp({super.key, required this.initialSettings});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  void _handleSettingsChanged(AppSettings settings) {
    setState(() => _settings = settings);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.appL10n.appTitle(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: Locale(_settings.languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: TimerPage(
        initialSettings: _settings,
        onSettingsChanged: _handleSettingsChanged,
      ),
    );
  }
}
