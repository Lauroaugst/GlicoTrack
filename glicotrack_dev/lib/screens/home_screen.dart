import 'package:flutter/material.dart';

// ============================================================================
// DATA MODELS & MOCKS
// ============================================================================

class MealSummaryModel {
  final String id;
  final String mealName;
  final IconData icon;
  final String? value; // null representa "--"
  final String status;

  const MealSummaryModel({
    required this.id,
    required this.mealName,
    required this.icon,
    this.value,
    required this.status,
  });
}

class ActionMenuModel {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ActionMenuModel({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

abstract class HomeMockData {
  static const List<MealSummaryModel> todaySummary = [
    MealSummaryModel(
      id: 'breakfast',
      mealName: 'Café da manhã',
      icon: Icons.wb_twilight_rounded,
      value: null,
      status: 'Pendente',
    ),
    MealSummaryModel(
      id: 'lunch',
      mealName: 'Almoço',
      icon: Icons.wb_sunny_outlined,
      value: null,
      status: 'Pendente',
    ),
    MealSummaryModel(
      id: 'dinner',
      mealName: 'Jantar',
      icon: Icons.nightlight_outlined,
      value: null,
      status: 'Pendente',
    ),
  ];
}

// ============================================================================
// MAIN SCREEN (STATEFUL)
// ============================================================================

class HomeScreen extends StatefulWidget {
  // Callback para avisar a MainScreen que queremos mudar de aba
  final ValueChanged<int>? onTabChange;

  const HomeScreen({super.key, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F1FD),

      // AppBar Superior
      appBar: AppBar(
        backgroundColor: const Color(0xFF0060C0),
        elevation: 3,
        shadowColor: Colors.black45,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop_outlined, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'GlicoTrack',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),

      // Corpo da Tela
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seção 1: Resumo do Dia
              _SectionContainer(
                title: 'Resumo do dia',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: _buildSummaryList(HomeMockData.todaySummary),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Seção 2: Controle Diário (Ações)
              _SectionContainer(
                title: 'Controle diário',
                child: Column(
                  children: [
                    _ActionCard(
                      title: 'Registrar Controle',
                      subtitle: 'Adicionar nova leitura de glicose',
                      onTap: () {
                        // Navega para a aba de Registro (Índice 1 da barra inferior)
                        if (widget.onTabChange != null) {
                          widget.onTabChange!(1);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      title: 'Histórico',
                      subtitle: 'Ver registros e análises',
                      onTap: () {
                        // Navega para a aba de Histórico (Índice 3 da barra inferior)
                        if (widget.onTabChange != null) {
                          widget.onTabChange!(3);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSummaryList(List<MealSummaryModel> items) {
    List<Widget> widgets = [];
    for (int i = 0; i < items.length; i++) {
      widgets.add(_SummaryTile(model: items[i]));
      if (i < items.length - 1) {
        widgets.add(const Divider(height: 1, color: Colors.black12));
      }
    }
    return widgets;
  }
}

// ============================================================================
// MODULARIZED REUSABLE WIDGETS (STATELESS)
// ============================================================================

class _SectionContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF003D80),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final MealSummaryModel model;

  const _SummaryTile({required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Column(
            children: [
              Icon(model.icon, size: 32, color: const Color(0xFF1A1A1A)),
              const SizedBox(height: 4),
              Text(
                model.status,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              model.mealName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Text(
            model.value ?? '--',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF4889DC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF4889DC),
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
