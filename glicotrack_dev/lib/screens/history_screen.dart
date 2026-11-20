import 'package:flutter/material.dart';

import 'dart:async';
import 'package:glicotrack_dev/data/local_database.dart';
import 'package:glicotrack_dev/domain/models.dart';
import 'timeline_screen.dart'; // Import da tela da Linha do Tempo
import '../services/pdf_service.dart'; // Import do gerador de PDF

// ============================================================================
// DATA MODELS & MOCKS
// ============================================================================

class GlucoseReading {
  final String day;
  final double value;
  final Color color;
  final DateTime measuredAt;

  const GlucoseReading({
    required this.day,
    required this.value,
    required this.color,
    required this.measuredAt,
  });
}

class WeeklySummaryModel {
  final String dateRange;
  final double average;
  final double min;
  final double max;
  final List<GlucoseReading> readings;

  const WeeklySummaryModel({
    required this.dateRange,
    required this.average,
    required this.min,
    required this.max,
    required this.readings,
  });
}

// ============================================================================
// MAIN SCREEN (STATEFUL)
// ============================================================================

class HistoryScreen extends StatefulWidget {
  final LocalDatabase localDatabase;

  const HistoryScreen({
    super.key,
    required this.localDatabase,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HealthRecord> _records = [];
  bool _isLoading = true;
  String? _loadError;
  StreamSubscription<void>? _databaseSubscription;
  Future<void> _loadRecords() async {
  setState(() {
    _isLoading = true;
    _loadError = null;
    

    
  });

  try {
    final documents = await widget.localDatabase.all(kind: 'record');

    final records = documents
        .where((doc) => !doc.deleted)
        .map(
          (doc) => HealthRecord.fromJson(
            doc.id,
            doc.uid,
            doc.payload,
          ),
        )
        .toList();

    records.sort(
      (a, b) => b.measuredAt.compareTo(a.measuredAt),
    );

    if (!mounted) return;

    setState(() {
      _records = records;
      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _loadError = 'Não foi possível carregar os registros.';
      _isLoading = false;
    });
  }
}
  // Define o período inicial como a última semana até hoje
  late DateTimeRange _selectedDateRange;

 @override
void initState() {
  super.initState();

  final now = DateTime.now();

  _selectedDateRange = DateTimeRange(
    start: now.subtract(const Duration(days: 6)),
    end: now,
  );

  _databaseSubscription = widget.localDatabase.changes.listen((_) {
    _loadRecords();
  });

  _loadRecords();
}

@override
void dispose() {
  _databaseSubscription?.cancel();
  super.dispose();
}

  /// Exibe o seletor nativo de intervalo de datas (Material 3) com alto contraste
  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ), // Permite futuro próximo
      helpText: 'Selecione o período de análise',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0060C0), // Cabeçalho do calendário
              onPrimary: Colors.white, // Texto no cabeçalho
              onSurface: Colors.black87, // Texto dos dias
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  final recordsInRange = _records.where((record) {
    final date = record.measuredAt.toLocal();

    final start = DateTime(
      _selectedDateRange.start.year,
      _selectedDateRange.start.month,
      _selectedDateRange.start.day,
    );

    final end = DateTime(
      _selectedDateRange.end.year,
      _selectedDateRange.end.month,
      _selectedDateRange.end.day,
      23, 59, 59, 999,
    );

    return !date.isBefore(start) && !date.isAfter(end);
  }).toList();

  final values = recordsInRange
      .map((record) => record.glucose.toDouble())
      .toList();

  final average = values.isEmpty
      ? 0.0
      : values.reduce((a, b) => a + b) / values.length;

  final minimum = values.isEmpty
      ? 0.0
      : values.reduce((a, b) => a < b ? a : b);

  final maximum = values.isEmpty
      ? 0.0
      : values.reduce((a, b) => a > b ? a : b);

  final start = _selectedDateRange.start;
  final end = _selectedDateRange.end;

  final dateRange =
      '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')} até '
      '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}';

  final currentSummary = WeeklySummaryModel(
    dateRange: dateRange,
    average: average,
    min: minimum,
    max: maximum,
    readings: recordsInRange.map((record) {
      final date = record.measuredAt.toLocal();

      const weekdays = [
        'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM',
      ];

      final glucose = record.glucose.toDouble();

      return GlucoseReading(
  day: weekdays[date.weekday - 1],
  value: glucose,
  measuredAt: date,
  color: glucose < 70
      ? const Color(0xFFF44336)
      : glucose > 180
          ? const Color(0xFFFF9800)
          : const Color(0xFF4CAF50),
);
    }).toList(),
  );

    return Scaffold(
      backgroundColor: const Color(0xFFE3F1FD),
      extendBody: true,

      // AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFF0060C0),
        elevation: 3,
        shadowColor: Colors.black45,
        centerTitle: true,
        title: const Text(
          'Histórico e Análise',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Corpo Rolável
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 24.0,
          bottom: 120.0, // Espaço para a Bottom NavBar
        ),
        child: Column(
          children: [
            // Card do Gráfico (Agora com o Seletor de Data)
           _WeeklyChartCard(
            summary: currentSummary,
                onDateRangeTap: _pickDateRange,
                  dateRange: _selectedDateRange,
                ),
            const SizedBox(height: 16),

            // Card de Resumo Numérico
            _SummaryCard(summary: currentSummary),
            const SizedBox(height: 24),

            // Botões de Ação (Repassando o summary com a data certa)
            _ActionButtonsRow(summary: currentSummary),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODULARIZED REUSABLE WIDGETS (STATELESS)
// ============================================================================

/// Card branco contendo o gráfico e o seletor de data
class _WeeklyChartCard extends StatelessWidget {
  final WeeklySummaryModel summary;
  final VoidCallback onDateRangeTap;
  final DateTimeRange dateRange;

  const _WeeklyChartCard({
    required this.summary,
    required this.onDateRangeTap,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1.5),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoading)
  const Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: CircularProgressIndicator(),
  ),

if (_loadError != null)
  Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      _loadError!,
      style: const TextStyle(color: Colors.red),
    ),
  ),

if (!_isLoading && _loadError == null && recordsInRange.isEmpty)
  const Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Text(
      'Nenhum registro encontrado para o período selecionado.',
      textAlign: TextAlign.center,
    ),
  ),
          // Título
          const Text(
            'Desempenho Glicêmico',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Botão Acessível de Filtro de Data
          _DateRangeSelectorButton(
            dateRange: summary.dateRange,
            onTap: onDateRangeTap,
          ),
          const SizedBox(height: 24),

          // Gráfico de Alta Performance (CustomPainter com Zonas Alvo)
         _GlucoseCustomChart(
  readings: summary.readings,
  dateRange: dateRange,
),
        ],
      ),
    );
  }
}

/// Botão de escolha de data seguindo as métricas do WCAG (56x56 e Semantics)
class _DateRangeSelectorButton extends StatelessWidget {
  final String dateRange;
  final VoidCallback onTap;

  const _DateRangeSelectorButton({
    required this.dateRange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Período atual: $dateRange. Toque para selecionar novas datas.',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 64,
          ), // Área de toque estendida
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F1FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF0060C0),
              width: 1.5,
            ), // Alto contraste
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.date_range_rounded,
                color: Color(0xFF0060C0),
                size: 28,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  dateRange,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0060C0),
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

/// Gráfico de Altíssima Performance (CustomPainter) com Zonas Médicas
class _GlucoseCustomChart extends StatelessWidget {
  final List<GlucoseReading> readings;
  final DateTimeRange dateRange;

  const _GlucoseCustomChart({
    required this.readings,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Gráfico visual de linha exibindo as tendências de glicemia no período.',
      child: CustomPaint(
        size: const Size(double.infinity, 240),
        painter: GlucoseMedicalChartPainter(
          readings: readings,
          dateRange: dateRange,
        ),
      ),
    );
  }
}

class GlucoseMedicalChartPainter extends CustomPainter {
  final List<GlucoseReading> readings;
  final DateTimeRange dateRange;

  final double limitHypo = 70.0;
  final double limitHyper = 180.0;
  final double chartMaxY = 300.0;
  final double chartMinY = 20.0;

  GlucoseMedicalChartPainter({
  required this.readings,
  required this.dateRange,
});

  @override
  void paint(Canvas canvas, Size size) {
    final double graphWidth = size.width - 40;
    final double graphHeight = size.height - 30;
    const double leftOffset = 40.0;

    double getY(double value) {
      final clampedValue = value.clamp(chartMinY, chartMaxY);
      final range = chartMaxY - chartMinY;
      final percent = (clampedValue - chartMinY) / range;
      return graphHeight - (percent * graphHeight);
    }

    // Zonas de Risco
    canvas.drawRect(
      Rect.fromLTRB(leftOffset, getY(limitHypo), size.width, getY(chartMinY)),
      Paint()..color = const Color(0xFFF44336).withValues(alpha: 0.15),
    );
    canvas.drawRect(
      Rect.fromLTRB(leftOffset, getY(limitHyper), size.width, getY(limitHypo)),
      Paint()..color = const Color(0xFF4CAF50).withValues(alpha: 0.15),
    );
    canvas.drawRect(
      Rect.fromLTRB(leftOffset, getY(chartMaxY), size.width, getY(limitHyper)),
      Paint()..color = const Color(0xFFFF9800).withValues(alpha: 0.15),
    );

    final linePaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;
    final textStyleY = const TextStyle(
      color: Colors.black87,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    final textStyleX = const TextStyle(
      color: Colors.black87,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    // Eixo Y
    for (var y in [chartMaxY, 180.0, 70.0, chartMinY]) {
      final yPos = getY(y);
      canvas.drawLine(
        Offset(leftOffset, yPos),
        Offset(size.width, yPos),
        linePaint,
      );

      final textPainter = TextPainter(
        text: TextSpan(text: y.toInt().toString(), style: textStyleY),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          leftOffset - textPainter.width - 8,
          yPos - (textPainter.height / 2),
        ),
      );
    }
    final startDate = DateTime(
  dateRange.start.year,
  dateRange.start.month,
  dateRange.start.day,
);

final endDate = DateTime(
  dateRange.end.year,
  dateRange.end.month,
  dateRange.end.day,
).add(const Duration(days: 1));

final totalMilliseconds =
    endDate.difference(startDate).inMilliseconds;

double getX(DateTime measuredAt) {
  final elapsedMilliseconds =
      measuredAt.toLocal().difference(startDate).inMilliseconds;

  final percent = elapsedMilliseconds / totalMilliseconds;

  return leftOffset + percent.clamp(0.0, 1.0) * graphWidth;
}
    // Eixo X
    // Eixo X - datas do período selecionado
const int divisions = 6;

for (int i = 0; i <= divisions; i++) {
  final fraction = i / divisions;

  final xPos = leftOffset + fraction * graphWidth;

  final timestamp = startDate.add(
    Duration(
      milliseconds: (totalMilliseconds * fraction).round(),
    ),
  );

  final label =
      '${timestamp.day.toString().padLeft(2, '0')}/'
      '${timestamp.month.toString().padLeft(2, '0')}';

  canvas.drawLine(
    Offset(xPos, 0),
    Offset(xPos, graphHeight),
    linePaint,
  );

  final textPainter = TextPainter(
    text: TextSpan(
      text: label,
      style: textStyleX,
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  textPainter.paint(
    canvas,
    Offset(
      xPos - textPainter.width / 2,
      graphHeight + 8,
    ),
  );
}


    // Linha de Conexão
    if (readings.isEmpty) return;

    final dataPaint = Paint()
      ..color = const Color(0xFF0060C0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    final List<Offset> points = [];

    final sortedReadings = List<GlucoseReading>.from(readings)
  ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

for (final reading in sortedReadings) {
  final x = getX(reading.measuredAt);
  final y = getY(reading.value);

  points.add(Offset(x, y));
}

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, dataPaint);
    }

    // Pontos
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        7.0,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        points[i],
        5.0,
        Paint()
          ..color = sortedReadings[i].color
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Card contendo o resumo numérico (Média, Mínima, Máxima)
class _SummaryCard extends StatelessWidget {
  final WeeklySummaryModel summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1.5),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo do Período',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Média',
            value: '${summary.average.toInt()} mg/dL',
          ),
          const Divider(height: 24, color: Colors.black12),
          _SummaryRow(label: 'Mínima', value: '${summary.min.toInt()} mg/dL'),
          const Divider(height: 24, color: Colors.black12),
          _SummaryRow(label: 'Máxima', value: '${summary.max.toInt()} mg/dL'),
        ],
      ),
    );
  }
}

/// Linha individual do card de resumo
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// Row contendo os botões (agora recebendo o contexto das datas)
class _ActionButtonsRow extends StatelessWidget {
  final WeeklySummaryModel summary;

  const _ActionButtonsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Gerar Relatório\nPDF',
            icon: Icons.picture_as_pdf_rounded,
            onTap: () async {
              // Passa os dados dinâmicos do período para o gerador
              await PdfService.generateMedicalReport(summary);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Ver Linha do\nTempo',
            icon: Icons.list_alt_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TimelineScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Botão customizado ajustado para Acessibilidade AAA
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Botão de ação: $label',
      button: true,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 80,
        ), // Altura muito confortável
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4889DC),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
