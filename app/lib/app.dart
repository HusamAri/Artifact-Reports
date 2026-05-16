import 'package:flutter/material.dart';

class ArtifactReportsApp extends StatelessWidget {
  const ArtifactReportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artifact Reports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: Center(
          child: Text('Artifact Reports — M1 skeleton'),
        ),
      ),
    );
  }
}
