import 'package:flutter/material.dart';

// ============================================================================
// DATA MODELS
// ============================================================================

enum GlucoseLevelStatus { low, normal, high }

class MeasurementModel {
  final String id;
  final String dateLabel; // Ex: 'Hoje', 'Ontem', '26/08/26'
  final String time; 
  final int glucoseValue;
  final String contextTag; // Ex: 'Pós-Refeição'
  final GlucoseLevelStatus status;

  const MeasurementModel({
    required this.id,
    required this.dateLabel,
    required this.time,
    required this.glucoseValue,
    required this.contextTag,
    required this.status,
  });

  Color get statusColor {
    switch (status) {
      case GlucoseLevelStatus.low:
        return const Color(0xFFF44336); // Vermelho (Hipoglicemia)
      case GlucoseLevelStatus.normal:
        return const Color(0xFF4CAF50); // Verde (Normal)
      case GlucoseLevelStatus.high:
        return const Color(0xFFFF9800); // Laranja (Hiperglicemia)
    }
  }
}

// ============================================================================
// MAIN SCREEN (STATEFUL)
// ============================================================================

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // Inicialização com os dados de exemplo, gerenciados em estado local
  // para simular a reatividade da remoção dos dados.
  List<MeasurementModel> _measurements = [
    const MeasurementModel(
      id: '1',
      dateLabel: 'Hoje',
      time: '09:41',
      glucoseValue: 62,
      contextTag: 'Pós-Refeição',
      status: GlucoseLevelStatus.low,
    ),
    const MeasurementModel(
      id: '2',
      dateLabel: 'Ontem',
      time: '19:41',
      glucoseValue: 123,
      contextTag: 'Pós-Refeição',
      status: GlucoseLevelStatus.normal,
    ),
    const MeasurementModel(
      id: '3',
      dateLabel: '26/08/26',
      time: '09:41',
      glucoseValue: 187,
      contextTag: 'Pós-Refeição',
      status: GlucoseLevelStatus.high,
    ),
    const MeasurementModel(
      id: '4',
      dateLabel: '25/08/26',
      time: '09:41',
      glucoseValue: 68,
      contextTag: 'Pós-Refeição',
      status: GlucoseLevelStatus.low,
    ),
  ];

  /// Apaga os dados após confirmação
  void _clearAllData() {
    setState(() {
      _measurements.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todos os dados foram excluídos com sucesso!'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  /// Diálogo para confirmação do processo de exclusão
  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Aviso Crítico'),
            ],
          ),
          content: const Text(
            'Tem certeza de que deseja excluir permanentemente todo o seu histórico de medições? Esta ação não pode ser desfeita.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // fecha modal
                _clearAllData(); // executa exclusão
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Sim, Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F1FD),

      // AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFF0060C0),
        elevation: 3,
        shadowColor: Colors.black45,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () =>
              Navigator.of(context).pop(), // Retorna para a tela de Histórico
        ),
        title: const Text(
          'Linha do Tempo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Corpo da tela (Estrutura principal)
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF003D80),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      // Cabeçalho Interno
                      const _TimelineHeader(),

                      // Lista de Itens Rolável
                      Expanded(
                        child: _measurements.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhum registro encontrado.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                itemCount: _measurements.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _MeasurementCard(
                                    model: _measurements[index],
                                  );
                                },
                              ),
                      ),

                      // Botão Destrutivo de Exclusão
                      if (_measurements.isNotEmpty)
                        _DeleteDataButton(
                          onPressed: _showDeleteConfirmationDialog,
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MODULARIZED SUB-WIDGETS
// ============================================================================

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Últimas Medições',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Integração futura com filtro de histórico
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0060C0),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Filtrar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final MeasurementModel model;

  const _MeasurementCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.dateLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                model.time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 12),

              Text(
                '${model.glucoseValue} mg/dL',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(width: 8), // Espaçamento mínimo de segurança
              // O Expanded empurra os itens para a direita, mas respeita o limite da tela
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: model.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // O Flexible + ellipsis garante que se a tela for muito fina,
                    // o texto "Pós-Refeição" vira "Pós-Ref..." em vez de causar erro.
                    Flexible(
                      child: Text(
                        model.contextTag,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeleteDataButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DeleteDataButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.delete_outline, size: 24),
          label: const Text(
            'Excluir Meus Dados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0060C0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
