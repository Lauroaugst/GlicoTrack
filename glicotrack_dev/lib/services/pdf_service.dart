import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:flutter/services.dart';

import '../presentation/history_summary.dart';
import '../presentation/glucose_style.dart';

class PdfService {
  static Future<pw.ThemeData>? _fonts;
  static Future<pw.ThemeData> _loadFonts() async => pw.ThemeData.withFont(
    base: pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    ),
    bold: pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf')),
  );

  /// Gera o relatório médico e abre a interface nativa para salvar/compartilhar
  static Future<void> generateMedicalReport(WeeklySummaryModel summary) async {
    await Printing.sharePdf(
      bytes: await buildReport(summary),
      filename: 'GlicoTrack.pdf',
    );
  }

  static Future<Uint8List> buildReport(WeeklySummaryModel summary) async {
    final pdf = pw.Document(theme: await (_fonts ??= _loadFonts()));

    final dataset = pw.LineDataSet(
      color: PdfColors.blue800,
      data: summary.readings
          .map((r) => pw.PointChartValue(r.x, r.value))
          .toList(),
    );

    // Constrói as páginas do PDF (MultiPage cria novas páginas automaticamente se o conteúdo vazar)
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        maxPages: 10000,
        margin: const pw.EdgeInsets.all(40), // Margem padrão ABNT/Médica
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 24),
            _buildPatientInfo(summary),
            pw.SizedBox(height: 24),
            _buildSummary(summary),
            pw.SizedBox(height: 32),
            _buildChart(dataset, summary),
            pw.SizedBox(height: 32),
            if (summary.records.isEmpty) pw.Text('Nenhuma medição no período.'),
            if (summary.records.isNotEmpty) _buildTable(summary),
            pw.SizedBox(height: 16),
            pw.Text(
              'Observações do paciente',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            ...summary.records
                .where((r) => r.notes.isNotEmpty)
                .map(
                  (r) => pw.Paragraph(
                    text:
                        '${dateLabel(r.measuredAt)} ${timeLabel(r.measuredAt)}: ${r.notes}',
                  ),
                ),
            pw.Text(
              'Indicadores informativos. Este relatório não fornece diagnóstico nem recomenda doses ou tratamentos.',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // --- Subcomponentes de Layout do PDF ---

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Relatório de Acompanhamento Glicêmico',
          style: pw.TextStyle(
            fontSize: 22,
            color: PdfColors.blue900,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Gerado via GlicoTrack App',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(color: PdfColors.grey400),
      ],
    );
  }

  static pw.Widget _buildPatientInfo(WeeklySummaryModel summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Paciente: ${summary.profile.name}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Idade: ${summary.profile.age ?? '--'} • Peso: ${summary.profile.weight ?? '--'} kg',
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Período Analisado:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(summary.dateRange),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(WeeklySummaryModel summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Medições', '${summary.stats.count}'),
          _summaryItem(
            'Na faixa',
            '${summary.stats.inRangePercent.toStringAsFixed(0)}%',
          ),
          _summaryItem(
            'Média',
            summary.stats.count == 0
                ? '--'
                : '${summary.average.toStringAsFixed(1)} mg/dL',
          ),
          _summaryItem(
            'Mínima',
            summary.stats.count == 0 ? '--' : '${summary.min.toInt()} mg/dL',
          ),
          _summaryItem(
            'Máxima',
            summary.stats.count == 0 ? '--' : '${summary.max.toInt()} mg/dL',
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 12),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 16,
            color: PdfColors.blue900,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildChart(pw.Dataset dataset, WeeklySummaryModel summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Variabilidade no período selecionado',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          height: 200,
          child: pw.Chart(
            grid: pw.CartesianGrid(
              xAxis: pw.FixedAxis(
                [0, 0.25, 0.5, 0.75, 1],
                format: (v) => dateLabel(
                  summary.start.add(
                    Duration(
                      milliseconds:
                          ((summary.end.millisecondsSinceEpoch -
                                      summary.start.millisecondsSinceEpoch -
                                      1) *
                                  v)
                              .round(),
                    ),
                  ),
                ),
                ticks: true,
              ),
              yAxis: pw.FixedAxis(
                [
                  0,
                  70,
                  summary.settings.upper.toDouble(),
                  (summary.max > summary.settings.upper
                          ? summary.max
                          : summary.settings.upper.toDouble()) +
                      30,
                ]..sort(),
                ticks: true,
              ),
            ),
            datasets: [dataset],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTable(WeeklySummaryModel summary) =>
      pw.TableHelper.fromTextArray(
        headers: [
          'Data/hora',
          'Categoria',
          'mg/dL',
          'Insulina U',
          'Carboidratos g',
          'Classificação',
        ],
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          fontSize: 9,
        ),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
        data: summary.records
            .map(
              (r) => [
                '${dateLabel(r.measuredAt)} ${timeLabel(r.measuredAt)}',
                r.category.label,
                '${r.glucose}',
                '${r.insulin ?? '--'}',
                '${r.carbs ?? '--'}',
                summary.settings.classify(r.glucose).label,
              ],
            )
            .toList(),
      );
}
