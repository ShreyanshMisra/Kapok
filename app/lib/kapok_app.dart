import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class KapokApp extends StatelessWidget {
  const KapokApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("✅ KapokApp build() called");
    return MaterialApp(
      title: 'Kapok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: const Scaffold(
        body: Center(child: Text('Kapok initialized successfully')),
      ),
    );
  }
}