import 'package:flutter/material.dart';
import 'package:glicotrack_dev/screens/splash_screen.dart'; // Importe a nova tela

void main() {
  runApp(const GlicoTrackApp());
}

class GlicoTrackApp extends StatelessWidget {
  const GlicoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlicoTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE3F1FD),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0060C0)),
        fontFamily: 'Roboto', // Ou a fonte que estiver utilizando
      ),
      // O aplicativo agora começa pela SplashScreen
      home: const SplashScreen(),
    );
  }
}
