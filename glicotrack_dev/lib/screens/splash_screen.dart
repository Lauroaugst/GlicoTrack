import 'package:material_ui/material_ui.dart';

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

    // Bootstrap controls authentication and lifetime; no artificial startup delay.
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
