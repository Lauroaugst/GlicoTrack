import 'package:flutter/material.dart';

import 'main_screen.dart';

// ============================================================================
// MAIN SCREEN (STATEFUL - COM ANIMAÇÕES IMPLÍCITAS)
// ============================================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Controle de estado para disparar a animação visual
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _startLoadingAndAnimation();
  }

  Future<void> _startLoadingAndAnimation() async {
    // 1. Dispara a animação (Fade In + Scale Up) logo após o primeiro frame renderizar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });

    // 2. Aguarda o tempo de exibição da marca (2.5s)
    await Future.delayed(const Duration(milliseconds: 2500));

    // 3. Transição suave (Fade) para a MainScreen ao invés de um corte seco
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Animação M3 suave de transição entre telas
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Acessibilidade Crítica: Verifica se o usuário ativou a redução de movimento no celular
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    // Define durações: Zero se acessibilidade exigir, 1200ms por padrão
    final Duration animationDuration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 1200);

    return Scaffold(
      backgroundColor: const Color(0xFF0060C0),
      body: Center(
        child: Semantics(
          label: 'Tela de carregamento do aplicativo GlicoTrack. Aguarde um momento.',
          child: AnimatedOpacity(
            duration: animationDuration,
            curve: Curves.easeOutCubic,
            opacity: _isVisible ? 1.0 : 0.0,
            child: AnimatedScale(
              duration: animationDuration,
              curve: Curves.easeOutCubic,
              scale: _isVisible
                  ? 1.0
                  : 0.85, // Inicia 15% menor e cresce suavemente
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    color: Colors.white,
                    size: 72,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'GlicoTrack',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
