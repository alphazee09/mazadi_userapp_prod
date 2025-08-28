// ignore_for_file: no_wildcard_variable_uses

import 'dart:async';
import 'dart:io';

import 'package:mazadi/core/getx.dart';
import 'package:mazadi/core/models/settings.dart';
import 'package:mazadi/core/navigator.dart';
import 'package:mazadi/firebase_options.dart';
import 'package:mazadi/theme/dark.dart';
import 'package:mazadi/theme/light.dart';
import 'package:mazadi/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:upgrader/upgrader.dart';
import 'core/controllers/ads.dart';
import 'core/services/revenue-cat/config.dart';

import 'authetication_guard.dart';
import 'core/controllers/main.dart';
import 'core/controllers/secured.dart';
import 'core/controllers/theme.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    final Zone currentZone = Zone.current;
    if (currentZone['handleError'] != null) {
      final Function errorHandler = currentZone['handleError'];
      errorHandler(details.exception, details.stack);
    }
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await MobileAds.instance.initialize();

      await Firebase.initializeApp(
        name: 'mazadi',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
      await FlutterConfig.loadEnvVariables();
      await EasyLocalization.ensureInitialized();

      setupGetxData();
      await initialization();

      var supportedLocales = Constants.LANGUAGES
          .map((e) => Locale(e['code'] as String))
          .toList(growable: false);

      runApp(
        EasyLocalization(
          supportedLocales: supportedLocales,
          path: 'lib/lang',
          fallbackLocale: const Locale('en'),
          child: const MyApp(),
        ),
      );
    },
    (error, stack) async {
      print('runZonedGuarded: Caught error in my root zone: $error - $stack');
    },
    zoneSpecification: ZoneSpecification(
      // Intercept all print calls
      print: (self, parent, zone, line) async {
        // Include a timestamp and the name of the App
        final messageToLog = "[${DateTime.now()}] mazadi $line";
        // Also print the message in the "Debug Console"
        // but it's ony an info message and contains no
        // privacy prohibited stuff
        parent.print(zone, messageToLog);
      },
    ),
  );
}

Future<void> _configurePaymentsSDK() async {
  await Purchases.setLogLevel(LogLevel.debug);

  PurchasesConfiguration configuration;
  if (StoreConfig.isForAmazonAppstore()) {
    configuration = AmazonConfiguration(StoreConfig.instance.apiKey);
  } else {
    configuration = PurchasesConfiguration(StoreConfig.instance.apiKey);
  }

  await Purchases.configure(configuration);
  await Purchases.enableAdServicesAttributionTokenCollection();
}

Future initialization() async {
  final mainController = Get.find<MainController>();
  final adsController = Get.find<AdsController>();
  final serverIsRunning = await mainController.checkIfServerIsRunning();
  if (!serverIsRunning) {
    FlutterNativeSplash.remove();
    return;
  }

  try {
    final securedController = Get.find<SecuredController>();
    await securedController.init();

    var accountLoaded = await mainController.loadAccount();
    if (accountLoaded) {
      var settings = await mainController.initializeAppRequiredData();
      await configurePayment(settings);

      adsController.initCredentials(settings);
      adsController.preloadBannerAds(count: 5);
      adsController.preloadInterstitialAds(count: 3);
      adsController.preloadRewardedAds(count: 3);
    }
    FlutterNativeSplash.remove();
  } catch (error) {
    print('Error initializing app: $error');
    FlutterNativeSplash.remove();
  }
}

Future<void> configurePayment(mazadiSettings settings) async {
  var iosKey = settings.revenueCatIOSKey;
  var androidKey = settings.revenueCatAndroidKey;

  if (Platform.isIOS || Platform.isMacOS) {
    if (iosKey != null && iosKey.isNotEmpty) {
      StoreConfig(
        store: Store.appStore,
        apiKey: iosKey,
      );
    } else {
      print('RevenueCat iOS API key is missing');
    }
  } else if (Platform.isAndroid) {
    if (androidKey != null && androidKey.isNotEmpty) {
      StoreConfig(
        store: Store.playStore,
        apiKey: androidKey,
      );
    } else {
      print('RevenueCat Google API key is missing');
    }
  }

  try {
    if ((iosKey != null &&
            iosKey.isNotEmpty &&
            (Platform.isIOS || Platform.isMacOS)) ||
        (androidKey != null && androidKey.isNotEmpty && Platform.isAndroid)) {
      await _configurePaymentsSDK();
    }
  } catch (error) {
    print('Error configuring payments SDK: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = Get.find<NavigatorService>();
    final navigatorKey = GlobalKey<NavigatorState>();
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'mazadi',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      builder: (context, _) {
        var child = _!;
        child = Toast(navigatorKey: navigatorKey, child: child);
        return child;
      },
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        EasyLocalization.of(context)!.delegate,
      ],
      supportedLocales: EasyLocalization.of(context)!.supportedLocales,
      locale: EasyLocalization.of(context)!.locale,
      themeMode: ThemeMode.system,
      navigatorKey: navigationService.navigatorKey,
      onInit: () {
        themeController.init();
      },
      home: UpgradeAlert(
        upgrader: Upgrader(
          durationUntilAlertAgain: const Duration(hours: 3),
          minAppVersion: '1.0.0',
        ),
        child: AuthenticationGuard(),
      ),
    );
  }
}
