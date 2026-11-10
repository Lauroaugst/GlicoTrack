import 'package:flutter/material.dart';

import 'timeline_screen.dart'; // Import da tela da Linha do Tempo
import '../services/pdf_service.dart'; // Import do gerador de PDF

// ============================================================================
// DATA MODELS & MOCKS
// ============================================================================

class GlucoseReading {
  final String day;
  final double value;
  final Color color;

  const GlucoseReading({
    required this.day,
    required this.value,
    required this.color,
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

abstract class HistoryMockData {
  /// Gera os dados simulados baseados no período selecionado
  static WeeklySummaryModel generateDataForRange(DateTimeRange range) {
    // Formata as datas de forma simples (DD/MM - DD/MM)
    final String formattedStart =
        '${range.start.day.toString().padLeft(2, '0')}/${range.start.month.toString().padLeft(2, '0')}';
    final String formattedEnd =
        '${range.end.day.toString().padLeft(2, '0')}/${range.end.month.toString().padLeft(2, '0')}';

    return WeeklySummaryModel(
      dateRange: '$formattedStart até $formattedEnd',
      average: 122.5,
      min: 60.0,
      max: 195.0,
      readings: const [
        GlucoseReading(
          day: 'SEG',
          value: 60.0,
          color: Color(0xFFF44336),
        ), // Hipoglicemia
        GlucoseReading(
          day: 'TER',
          value: 195.0,
          color: Color(0xFFFF9800),
        ), // Hiperglicemia
        GlucoseReading(
          day: 'QUA',
          value: 125.0,
          color: Color(0xFF4CAF50),
        ), // Alvo
        GlucoseReading(
          day: 'QUI',
          value: 110.0,
          color: Color(0xFF4CAF50),
        ), // Alvo
      ],
    );
  }
}

// ============================================================================
// MAIN SCREEN (STATEFUL)
// ============================================================================

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
    // Carrega o mock com base nas datas selecionadas
    final currentSummary = HistoryMockData.generateDataForRange(
      _selectedDateRange,
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

  const _WeeklyChartCard({required this.summary, required this.onDateRangeTap});

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
          _GlucoseCustomChart(readings: summary.readings),
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
  const _GlucoseCustomChart({required this.readings});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Gráfico visual de linha exibindo as tendências de glicemia no período.',
      child: CustomPaint(
        size: const Size(double.infinity, 240),
        painter: GlucoseMedicalChartPainter(readings: readings),
      ),
    );
  }
}

class GlucoseMedicalChartPainter extends CustomPainter {
  final List<GlucoseReading> readings;

  final double limitHypo = 70.0;
  final double limitHyper = 180.0;
  final double chartMaxY = 300.0;
  final double chartMinY = 20.0;

  GlucoseMedicalChartPainter({required this.readings});

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

    // Eixo X
    final days = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];
    final double stepX = graphWidth / (days.length - 1);

    for (int i = 0; i < days.length; i++) {
      final xPos = leftOffset + (i * stepX);
      canvas.drawLine(Offset(xPos, 0), Offset(xPos, graphHeight), linePaint);

      final textPainter = TextPainter(
        text: TextSpan(text: days[i], style: textStyleX),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(xPos - (textPainter.width / 2), graphHeight + 8),
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

    for (var reading in readings) {
      final dayIndex = days.indexOf(reading.day);
      if (dayIndex == -1) continue;
      points.add(Offset(leftOffset + (dayIndex * stepX), getY(reading.value)));
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
          ..color = readings[i].color
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
