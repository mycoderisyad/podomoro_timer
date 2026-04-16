import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'pages/timer_page.dart';
import 'models/app_settings.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  await initializeDateFormatting('id');
  final initialSettings = await SettingsService.loadSettings();
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
