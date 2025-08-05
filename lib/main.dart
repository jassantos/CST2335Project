// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'customer/AppLocalizations.dart';
import 'airplane/airplane_list_page.dart';
import 'customer/customer_list_page.dart';
import 'flight/flight_list_page.dart';      // <- the new flight screen you pasted earlier
import 'reservation/reservation_page.dart';

void main() => runApp(const MyApp());

/* ──────────────────────────────────────────────────────────
   MyApp – now STATEFUL so it can rebuild when language flips
   ────────────────────────────────────────────────────────── */
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  /// Any page can call:  MyApp.setLocale(context, const Locale('es'));
  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');        // default language

  void setLocale(Locale locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CST2335 Final Group Project',

      /* NEW ↓↓↓ */
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,            // JSON → strings
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      /* ↑↑↑ */

      initialRoute: '/',
      routes: {
        '/':                    (_) => const MyHomePage(title: 'CST2335 Final Group Project'),
        '/customer_list_page':  (_) => const LocalizedApp(),   // existing screen
        '/airplane_list_page':  (_) => const AirplaneList(),   // existing screen
        '/flight_list_page':    (_) => const FlightListPage(), // NEW (matches the code you pasted)
        '/reservation_page':    (_) => const Reservation(),    // existing screen
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

/* ───────────────  Existing hub screen – untouched  ─────────────── */
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Instructions'),
                content: const Text('Select one of the modules to manage different aspects of the system.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _bigButton(context, 'Customer',     '/customer_list_page'),
            _bigButton(context, 'Airplane',     '/airplane_list_page'),
            _bigButton(context, 'Flight',       '/flight_list_page'),
            _bigButton(context, 'Reservation',  '/reservation_page'),
          ],
        ),
      ),
    );
  }

  Widget _bigButton(BuildContext ctx, String text, String route) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(ctx, route),
        child: Text(text),
      ),
    ),
  );
}
