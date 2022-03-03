import 'dart:async';

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:TimeTrack/blocs/locale/locale_bloc.dart';
import 'package:TimeTrack/blocs/notifications/notifications_bloc.dart';
import 'package:TimeTrack/blocs/projects/bloc.dart';
import 'package:TimeTrack/blocs/settings/settings_bloc.dart';
import 'package:TimeTrack/blocs/settings/settings_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:TimeTrack/blocs/settings/settings_state.dart';
import 'package:TimeTrack/blocs/theme/theme_bloc.dart';
import 'package:TimeTrack/blocs/timers/bloc.dart';
import 'package:TimeTrack/data_providers/data/data_provider.dart';
import 'package:TimeTrack/data_providers/notifications/notifications_provider.dart';
import 'package:TimeTrack/data_providers/settings/settings_provider.dart';
import 'package:TimeTrack/fontlicenses.dart';
import 'package:TimeTrack/l10n.dart';
import 'package:TimeTrack/screens/dashboard/DashboardScreen.dart';
import 'package:TimeTrack/themes.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'package:TimeTrack/data_providers/data/database_provider.dart';
import 'package:TimeTrack/data_providers/settings/shared_prefs_settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SettingsProvider settings = await SharedPrefsSettingsProvider.load();


  String databasesPath = await getDatabasesPath();
  var path = p.join(databasesPath, 'TimeTrack.db');
  await Directory(databasesPath).create(recursive: true);

  final DataProvider data = await DatabaseProvider.open(path);
  final NotificationsProvider notifications =
      await NotificationsProvider.load();
  await runMain(settings, data, notifications);
}


Future<void> runMain(SettingsProvider settings, DataProvider data,
    NotificationsProvider notifications) async {

  LicenseRegistry.addLicense(getFontLicenses);

  assert(settings != null);

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<ThemeBloc>(
        create: (_) => ThemeBloc(settings),
      ),
      BlocProvider<LocaleBloc>(
        create: (_) => LocaleBloc(settings),
      ),
      BlocProvider<SettingsBloc>(
        create: (_) => SettingsBloc(settings, data),
      ),
      BlocProvider<TimersBloc>(
        create: (_) => TimersBloc(data, settings),
      ),
      BlocProvider<ProjectsBloc>(
        create: (_) => ProjectsBloc(data),
      ),
      BlocProvider<NotificationsBloc>(
        create: (_) => NotificationsBloc(notifications),
      ),
    ],
    child: TimeTrackApp(settings: settings),
  ));
}

class TimeTrackApp extends StatefulWidget {
  final SettingsProvider settings;
  const TimeTrackApp({Key key, @required this.settings})
      : assert(settings != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _TimeTrackAppState();
}

class _TimeTrackAppState extends State<TimeTrackApp>
    with WidgetsBindingObserver {
  Timer _updateTimersTimer;
  Brightness brightness;

  @override
  void initState() {
    _updateTimersTimer = Timer.periodic(Duration(seconds: 1),
        (_) => BlocProvider.of<TimersBloc>(context).add(UpdateNow()));
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    brightness = WidgetsBinding.instance.window.platformBrightness;

    SettingsBloc settingsBloc = BlocProvider.of<SettingsBloc>(context);
    TimersBloc timersBloc = BlocProvider.of<TimersBloc>(context);
    settingsBloc.listen((settingsState) => _updateNotificationBadge(
        settingsState, timersBloc.state.countRunningTimers()));
    timersBloc.listen((timersState) => _updateNotificationBadge(
        settingsBloc.state, timersState.countRunningTimers()));


    settingsBloc.add(LoadSettingsFromRepository());
    timersBloc.add(LoadTimers());
    BlocProvider.of<ProjectsBloc>(context).add(LoadProjects());
    BlocProvider.of<ThemeBloc>(context).add(LoadThemeEvent());
    BlocProvider.of<LocaleBloc>(context).add(LoadLocaleEvent());
  }

  void _updateNotificationBadge(SettingsState settingsState, int count) async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (!settingsState.hasAskedNotificationPermissions &&
          !settingsState.showBadgeCounts) {
        return;
      } else if (settingsState.showBadgeCounts) {
        if (count > 0) {
          FlutterAppBadger.updateBadgeCount(count);
        } else {
          FlutterAppBadger.removeBadge();
        }
      } else {
        FlutterAppBadger.removeBadge();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("application lifecycle changed to: " + state.toString());
    if (state == AppLifecycleState.paused) {
      SettingsState settings = BlocProvider.of<SettingsBloc>(context).state;
      TimersState timers = BlocProvider.of<TimersBloc>(context).state;

      LocaleState localeState = BlocProvider.of<LocaleBloc>(context).state;
      Locale locale = localeState.locale ?? Locale("en");
      L10N l10n = await L10N.load(locale);

      if (settings.showRunningTimersAsNotifications &&
          timers.countRunningTimers() > 0) {
        print("showing notification");
        BlocProvider.of<NotificationsBloc>(context).add(ShowNotification(
            title: l10n.tr.runningTimersNotificationTitle,
            body: l10n.tr.runningTimersNotificationBody));
      } else {
        print("not showing notification");
      }
    } else if (state == AppLifecycleState.resumed) {
      BlocProvider.of<NotificationsBloc>(context).add(RemoveNotifications());
    }
  }

  @override
  void dispose() {
    _updateTimersTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    print(WidgetsBinding.instance.window.platformBrightness.toString());
    setState(
        () => brightness = WidgetsBinding.instance.window.platformBrightness);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SettingsProvider>.value(value: widget.settings),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (BuildContext context, ThemeState themeState) =>
                BlocBuilder<LocaleBloc, LocaleState>(
                  builder: (BuildContext context, LocaleState localeState) =>
                      MaterialApp(
                    title: 'Time Track',
                    home: DashboardScreen(),
                    theme: themeState.themeData ??
                        (brightness == Brightness.dark
                            ? darkTheme
                            : lightTheme),
                    localizationsDelegates: [
                      L10N.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    locale: localeState.locale,
                    supportedLocales: [
                      const Locale('en'),
                      const Locale('fr'),
                      const Locale('de'),
                      const Locale('es'),
                      const Locale('hi'),
                      const Locale('id'),
                      const Locale('ja'),
                      const Locale('ko'),
                      const Locale('pt'),
                      const Locale('ru'),
                      const Locale('zh', 'CN'),
                      const Locale('zh', 'TW'),
                      const Locale('ar'),
                      const Locale('it'),
                    ],
                  ),
                )));
  }
}
