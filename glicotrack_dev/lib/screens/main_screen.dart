import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'register_screen.dart';
import 'history_screen.dart';
import 'profile_hub_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Método que gera a lista de telas, permitindo passar o callback para a HomeScreen
  List<Widget> _getScreens() {
    return [
      HomeScreen(
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const RegisterScreen(),
      const ProfileHubScreen(),
      const HistoryScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F1FD),
      extendBody: true,

      // Substituímos o IndexedStack padrão pelo nosso customizado com animação
      body: _FadeIndexedStack(index: _currentIndex, children: _getScreens()),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: _SharedBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET CUSTOMIZADO: FADE INDEXED STACK
// ============================================================================

/// Widget que preserva o estado das telas em memória (como o IndexedStack)
/// mas aplica uma animação suave de Fade-Through (Opacidade) na troca de abas.
class _FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const _FadeIndexedStack({required this.index, required this.children});

  @override
  State<_FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<_FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ), // Duração recomendada pelo M3
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Toda vez que o índice da aba muda, recomeçamos a animação do zero
    if (widget.index != oldWidget.index) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Regra WCAG AAA: Verifica se o dispositivo exige redução de movimento
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    if (disableAnimations) {
      // Se animações estiverem desativadas no SO, retorna a troca instantânea
      return IndexedStack(index: widget.index, children: widget.children);
    }

    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeIn).animate(_controller),
      child: IndexedStack(index: widget.index, children: widget.children),
    );
  }
}

// ============================================================================
// BARRA DE NAVEGAÇÃO INFERIOR
// ============================================================================

class _SharedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SharedBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const List<IconData> icons = [
      Icons.home_rounded,
      Icons.water_drop_outlined,
      Icons.account_circle_outlined,
      Icons.history_rounded,
    ];

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          final isSelected = currentIndex == index;
          return Semantics(
            label: 'Ir para a aba ${index + 1}',
            button: true,
            selected: isSelected,
            child: IconButton(
              onPressed: () => onTap(index),
              iconSize: 38,
              icon: Icon(
                icons[index],
                color: isSelected ? const Color(0xFF0060C0) : Colors.black,
              ),
            ),
          );
        }),
      ),
    );
  }
}
