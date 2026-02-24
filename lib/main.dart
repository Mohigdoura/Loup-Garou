import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/features/Game/day/day_page.dart';
import 'package:loup_garou/features/Game/game.dart';
import 'package:loup_garou/features/Game/give_to_narrator_page.dart';
import 'package:loup_garou/features/Game/night/night_page.dart';
import 'package:loup_garou/features/landing/main_menu.dart';
import 'package:loup_garou/features/setup/names_selection_page.dart';
import 'package:loup_garou/features/setup/picker_page.dart'; // Ensure correct path
import 'package:loup_garou/features/setup/role_selection_page.dart'; // Ensure correct path
import 'package:loup_garou/features/shop/shop_page.dart';
import 'package:loup_garou/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper for Slide Transition
CustomTransitionPage buildSlideTransition<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: child,
      );
    },
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  initialLocation: '/',
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainMenu()),
    GoRoute(
      path: '/role-selection',
      pageBuilder: (context, state) => buildSlideTransition(
        key: state.pageKey,
        child: const RoleSelectionPage(),
      ),
    ),
    GoRoute(
      path: '/name-selection',
      pageBuilder: (context, state) => buildSlideTransition(
        key: state.pageKey,
        child: const NamesSelectionPage(),
      ),
    ),
    GoRoute(
      path: '/game',
      pageBuilder: (context, state) =>
          buildSlideTransition(key: state.pageKey, child: const Game()),
    ),
    GoRoute(
      path: '/day',
      pageBuilder: (context, state) =>
          buildSlideTransition(key: state.pageKey, child: const DayPage()),
    ),
    GoRoute(
      path: '/night',
      pageBuilder: (context, state) =>
          buildSlideTransition(key: state.pageKey, child: const NightPage()),
    ),
    GoRoute(
      path: '/give-narrator',
      pageBuilder: (context, state) => buildSlideTransition(
        key: state.pageKey,
        child: const GiveToNarratorPage(),
      ),
    ),
    GoRoute(
      path: '/shop',
      pageBuilder: (context, state) =>
          buildSlideTransition(key: state.pageKey, child: const ShopPage()),
    ),
    GoRoute(
      path: '/picker',
      pageBuilder: (context, state) =>
          buildSlideTransition(key: state.pageKey, child: const PickerPage()),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  await dotenv.load(fileName: '.env');

  try {
    MobileAds.instance.initialize();
    log('initialized Google Mobile Ads successfully');
  } on Exception catch (e) {
    log('Failed to initialize Google Mobile Ads: $e');
  }

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Loup Garou',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
    );
  }
}
