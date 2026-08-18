import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'l10n/generated/app_localizations.dart';
import 'firebase_options.dart';
import 'screens/splash_door_screen.dart';
import 'state/nav_controller.dart';
import 'state/wardrobe_provider.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GarderobaApp());
}

class GarderobaApp extends StatelessWidget {
  const GarderobaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WardrobeProvider()),
        ChangeNotifierProvider(create: (_) => NavTabController()),
      ],
      child: MaterialApp(
        title: 'Szafnik',
        debugShowCheckedModeBanner: false,
        // Na razie appka działa tylko po polsku (locale ustawiony na sztywno) -
        // infrastruktura tłumaczeń jest już gotowa, przełącznik języka i
        // migracja pozostałych tekstów w appce to osobny, kolejny krok.
        locale: const Locale('pl'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            surface: AppColors.paper,
          ),
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: const SplashDoorScreen(),
      ),
    );
  }
}
