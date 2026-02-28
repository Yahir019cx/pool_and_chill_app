import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:pool_and_chill_app/features/properties/Screens/property_detail_screen.dart';

import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/app/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  await Stripe.instance.applySettings();

  final apiClient = ApiClient(
    baseUrl: dotenv.env['API_BASE_URL']!,
  );

  final authProvider = AuthProvider(apiClient);
  apiClient.attachAuthProvider(authProvider);

  runApp(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(apiClient),
      ],
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    final appLinks = AppLinks();

    // Cold start: app abierta desde link externo
    final initial = await appLinks.getInitialLink();
    if (initial != null) _handleLink(initial);

    // Foreground: app ya abierta y llega un link
    _linkSub = appLinks.uriLinkStream.listen(_handleLink);
  }

  void _handleLink(Uri uri) {
    String? id;

    // Universal/App Link: https://poolandchill.com.mx/property/{id}
    if (uri.scheme == 'https' &&
        uri.host == 'poolandchill.com.mx' &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'property') {
      id = uri.pathSegments[1];
    }
    // Custom scheme fallback: poolandchill://property/{id}
    // (Stripe usa poolandchill://stripe/... y lo maneja StripeConnectScreen)
    else if (uri.scheme == 'poolandchill' && uri.host == 'property') {
      id = uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    }

    if (id == null || id.isEmpty) return;

    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(propertyId: id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Pool & Chill',
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(),
      ),
      locale: const Locale('es', 'MX'),
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthGate(),
    );
  }
}
