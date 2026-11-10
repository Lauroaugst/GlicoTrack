import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../screens/history_screen.dart'; // Para acessar os modelos GlucoseReading e WeeklySummaryModel

class PdfService {
  /// Gera o relatório médico e abre a interface nativa para salvar/compartilhar
  static Future<void> generateMedicalReport(WeeklySummaryModel summary) async {
    final pdf = pw.Document();

    // Mapeamento dos dias da semana para posições numéricas no eixo X do gráfico
    final Map<String, double> dayToX = {
      'SEG': 1,
      'TER': 2,
      'QUA': 3,
      'QUI': 4,
      'SEX': 5,
      'SAB': 6,
      'DOM': 7,
    };

    // Montagem dos dados (Dataset) corrigida para usar LineDataSet
    final dataset = pw.LineDataSet(
      color: PdfColors.blue800,
      data: summary.readings.map((r) {
        return pw.PointChartValue(dayToX[r.day] ?? 0, r.value);
      }).toList(),
    );

    // Constrói as páginas do PDF (MultiPage cria novas páginas automaticamente se o conteúdo vazar)
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40), // Margem padrão ABNT/Médica
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 24),
            _buildPatientInfo(summary.dateRange),
            pw.SizedBox(height: 24),
            _buildSummary(summary),
            pw.SizedBox(height: 32),
            _buildChart(dataset),
            pw.SizedBox(height: 32),
            _buildTable(summary.readings),
          ];
        },
      ),
    );

    // Dispara a interface nativa do celular (Preview, Imprimir, Enviar por WhatsApp, Salvar PDF)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Relatorio_Glicemia_${summary.dateRange.replaceAll(' ', '_')}.pdf',
    );
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

  static pw.Widget _buildPatientInfo(String dateRange) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Paciente: ___________________________',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Idade/Peso: _________________________'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Período Analisado:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(dateRange),
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
          _summaryItem('Média', '${summary.average.toInt()} mg/dL'),
          _summaryItem('Mínima', '${summary.min.toInt()} mg/dL'),
          _summaryItem('Máxima', '${summary.max.toInt()} mg/dL'),
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

  static pw.Widget _buildChart(pw.Dataset dataset) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Gráfico de Acompanhamento Semanal',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          height: 200,
          child: pw.Chart(
            grid: pw.CartesianGrid(
              xAxis: pw.FixedAxis(
                [1, 2, 3, 4, 5, 6, 7],
                format: (v) => [
                  'SEG',
                  'TER',
                  'QUA',
                  'QUI',
                  'SEX',
                  'SAB',
                  'DOM',
                ][v.toInt() - 1],
                ticks: true,
              ),
              yAxis: pw.FixedAxis([
                40,
                80,
                120,
                160,
                200,
                240,
                280,
                320,
              ], ticks: true),
            ),
            datasets: [dataset],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTable(List<GlucoseReading> readings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Registros Detalhados',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: [
            'Dia da Semana',
            'Glicemia (mg/dL)',
            'Classificação Médica',
          ],
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
          cellAlignment: pw.Alignment.center,
          data: readings.map((r) {
            String status = 'Normal';
            if (r.value < 70) status = 'Hipoglicemia';
            if (r.value > 180) status = 'Hiperglicemia';

            return [r.day, r.value.toString(), status];
          }).toList(),
        ),
      ],
    );
  }
}
