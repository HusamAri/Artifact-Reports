import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ArtifactReportsApp extends StatelessWidget {
  const ArtifactReportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artifact Reports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _PlaceholderHome(),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Artifact Reports — M1 skeleton'),
      ),
    );
  }
}
