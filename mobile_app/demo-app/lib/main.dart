import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:henox/helpers/extensions/app_localization_delegate.dart';
import 'package:henox/helpers/services/localizations/language.dart';
import 'package:henox/helpers/services/navigation_services.dart';
import 'package:henox/helpers/services/storage/local_storage.dart';
import 'package:henox/helpers/theme/app_notifier.dart';
import 'package:henox/helpers/theme/app_theme.dart';
import 'package:henox/helpers/theme/theme_customizer.dart';
import 'package:henox/route/routes.dart';
import 'package:henox/route/routes_name.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  await LocalStorage.init();
  AppStyle.init();
  await ThemeCustomizer.init();
  runApp(ChangeNotifierProvider<AppNotifier>(
    create: (context) => AppNotifier(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    RoutesName route = RoutesName();

    return Consumer<AppNotifier>(
      builder: (_, notifier, ___) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeCustomizer.instance.theme,
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: route.dashboard,
          getPages: getPageRoute(),
          builder: (context, child) {
            NavigationService.registerContext(context);
            return Directionality(
                textDirection: AppTheme.textDirection,
                child: child ?? Container());
          },
          localizationsDelegates: [
            AppLocalizationsDelegate(context),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: Language.getLocales(),
        );
      },
    );
  }
}
