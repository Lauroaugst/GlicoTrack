import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../domain/models.dart';
import '../presentation/app_store.dart';
import '../presentation/glucose_style.dart';
import 'register_screen.dart';

// ============================================================================
// DATA MODELS
// ============================================================================

enum GlucoseLevelStatus { low, belowTarget, normal, high }

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
      case GlucoseLevelStatus.belowTarget:
        return const Color(0xFF8D6E00);
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
  const TimelineScreen({super.key, this.start, this.end});
  final DateTime? start;
  final DateTime? end;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  DateTime? _start;
  DateTime? _end;
  MeasurementCategory? _category;
  @override
  void initState() {
    super.initState();
    _start = widget.start;
    _end = widget.end;
  }

  Future<void> _clearAllData() async {
    try {
      await context.read<AppStore>().clearRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Histórico excluído neste aparelho. A exclusão será sincronizada.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) showAppError(context, error);
    }
  }

  Future<void> _filter() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todas as categorias'),
              onTap: () {
                setState(() => _category = null);
                Navigator.pop(sheetContext);
              },
            ),
            ...MeasurementCategory.values.map(
              (c) => ListTile(
                title: Text(c.label),
                onTap: () {
                  setState(() => _category = c);
                  Navigator.pop(sheetContext);
                },
              ),
            ),
            ListTile(
              title: const Text('Todo o histórico'),
              onTap: () {
                setState(() {
                  _start = null;
                  _end = null;
                });
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              title: const Text('Escolher período'),
              onTap: () async {
                Navigator.pop(sheetContext);
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null && mounted) {
                  setState(() {
                    _start = picked.start;
                    _end = DateTime(
                      picked.end.year,
                      picked.end.month,
                      picked.end.day + 1,
                    );
                  });
                }
              },
            ),
          ],
        ),
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
    final store = context.watch<AppStore>();
    final records = store.select(start: _start, end: _end, category: _category);
    final measurements = records
        .map(
          (r) => MeasurementModel(
            id: r.id,
            dateLabel: dateLabel(r.measuredAt),
            time: timeLabel(r.measuredAt),
            glucoseValue: r.glucose,
            contextTag: r.category.label,
            status: switch (store.settings.classify(r.glucose)) {
              GlucoseStatus.hypo => GlucoseLevelStatus.low,
              GlucoseStatus.belowTarget => GlucoseLevelStatus.belowTarget,
              GlucoseStatus.inRange => GlucoseLevelStatus.normal,
              GlucoseStatus.hyper => GlucoseLevelStatus.high,
            },
          ),
        )
        .toList();
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
                      _TimelineHeader(onFilter: _filter),
                      if (store.loadError != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            store.loadError!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                      // Lista de Itens Rolável
                      Expanded(
                        child: measurements.isEmpty
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
                                itemCount: measurements.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final record = records[index];
                                  return Column(
                                    key: ValueKey(record.id),
                                    children: [
                                      _MeasurementCard(
                                        model: measurements[index],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.only(
                                          top: 12,
                                          left: 12,
                                          right: 12,
                                          bottom: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Refeição: ${mealLabel(record.meal)}',
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${store.settings.classify(record.glucose).label} • Insulina: ${record.insulin ?? '--'} U • Carboidratos: ${record.carbs ?? '--'} g',
                                              textAlign: TextAlign.center,
                                            ),
                                            if (record.notes.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: Text(record.notes),
                                              ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  tooltip: 'Editar registro',
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.of(
                                                        context,
                                                      ).push(
                                                        MaterialPageRoute<void>(
                                                          builder: (_) =>
                                                              RegisterScreen(
                                                                record: record,
                                                              ),
                                                        ),
                                                      ),
                                                ),
                                                IconButton(
                                                  tooltip: 'Excluir registro',
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                  ),
                                                  onPressed: () async {
                                                    final confirmed = await showDialog<bool>(
                                                      context: context,
                                                      builder:
                                                          (
                                                            dialogContext,
                                                          ) => AlertDialog(
                                                            title: const Text(
                                                              'Excluir este registro?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                      dialogContext,
                                                                      false,
                                                                    ),
                                                                child:
                                                                    const Text(
                                                                      'Cancelar',
                                                                    ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                      dialogContext,
                                                                      true,
                                                                    ),
                                                                child:
                                                                    const Text(
                                                                      'Excluir',
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                    );
                                                    if (confirmed != true ||
                                                        !context.mounted) {
                                                      return;
                                                    }
                                                    try {
                                                      await store.deleteRecord(
                                                        record.id,
                                                      );
                                                    } catch (error) {
                                                      if (context.mounted) {
                                                        showAppError(
                                                          context,
                                                          error,
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),

                      // Botão Destrutivo de Exclusão
                      if (measurements.isNotEmpty)
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
  const _TimelineHeader({required this.onFilter});
  final VoidCallback onFilter;

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
            onPressed: onFilter,
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
