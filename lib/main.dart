import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:uber_user/splashScreen/splash_screen.dart';
import 'global/global.dart';
import 'infoHandler/app_info_handler.dart';
import 'l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_live_qV2DodGhWrZjQkLAfIFZgVua00W3sjPldP'; //
  Stripe.merchantIdentifier = 'any string works';
  Stripe.instance.applySettings();
  await Firebase.initializeApp();
  Stripe.publishableKey = stripePublishKey;
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) {
        return AppInfoHandler();
      },
      child: MyApp(
        child: Consumer<AppInfoHandler>(
          builder: (context, appState, child) => MaterialApp(
            locale: Provider.of<AppInfoHandler>(context).locale,
            supportedLocales: L10n.all,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            title: 'Drivers App',
            theme: ThemeData(
              primarySwatch: Colors.orange,
            ),
            home: const MySplashScreen(),
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget? child;

  MyApp({this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
