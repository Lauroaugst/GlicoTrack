import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glicotrack_dev/domain/models.dart';
import 'package:glicotrack_dev/presentation/history_summary.dart';
import 'package:glicotrack_dev/screens/history_screen.dart';
import 'package:glicotrack_dev/services/csv_service.dart';
import 'package:glicotrack_dev/services/pdf_service.dart';

import 'support/fixtures.dart';

WeeklySummaryModel summary({bool empty = false}) => WeeklySummaryModel(
  start: DateTime(2026, 11, 16),
  end: DateTime(2026, 11, 23),
  records: empty ? [] : [record(notes: '=1+1; "observação"\nLinha 2')],
  settings: const GlucoseSettings(),
  profile: profile,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('CSV preserva campos e neutraliza fórmula em observações', () {
    final csv = CsvService.encode(summary());
    expect(csv, contains('Paciente teste'));
    expect(csv, contains('16/11/2026'));
    expect(csv, contains('Jejum'));
    expect(csv, contains('"\'=1+1; ""observação""\nLinha 2"'));
    expect(csv, contains('"2.0"'));
    expect(csv, contains('"30.0"'));
    expect(csv.startsWith('\uFEFF'), isTrue);
  });
  test('PDF gera bytes válidos com dados reais e sem rede', () async {
    final bytes = await PdfService.buildReport(summary());
    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
    expect(bytes.length, greaterThan(1000));
    final output = Platform.environment['GLICO_QA_OUTPUT'];
    if (output != null) {
      await Directory(output).create(recursive: true);
      await File('$output/report.pdf').writeAsBytes(bytes);
    }
  });
  test(
    'PDF suporta histórico extenso e observações longas em múltiplas páginas',
    () async {
      final data = WeeklySummaryModel(
        start: now,
        end: now.add(const Duration(days: 30)),
        records: List.generate(
          100,
          (i) => record(
            at: now.add(Duration(hours: i)),
            notes: i == 0 ? 'Observação do paciente. ' * 80 : '',
          ),
        ),
        settings: const GlucoseSettings(),
        profile: profile,
      );
      final bytes = await PdfService.buildReport(data);
      expect(bytes.length, greaterThan(10000));
    },
  );
  test('PDF aceita período sem registros', () async {
    expect(
      (await PdfService.buildReport(summary(empty: true))).length,
      greaterThan(1000),
    );
  });
  test(
    'gráfico não redesenha dados iguais, redesenha metas/dados alterados',
    () {
      final data = summary();
      final a = GlucoseMedicalChartPainter(
        readings: data.readings,
        start: data.start,
        end: data.end,
      );
      final equal = GlucoseMedicalChartPainter(
        readings: [...data.readings],
        start: data.start,
        end: data.end,
      );
      expect(equal.shouldRepaint(a), isFalse);
      expect(
        GlucoseMedicalChartPainter(
          readings: data.readings,
          lower: 80,
          start: data.start,
          end: data.end,
        ).shouldRepaint(a),
        isTrue,
      );
      expect(
        GlucoseMedicalChartPainter(
          readings: [
            const GlucoseReading(
              day: '16/11',
              value: 70,
              color: Colors.red,
              x: .5,
            ),
          ],
          start: data.start,
          end: data.end,
        ).shouldRepaint(a),
        isTrue,
      );
    },
  );
  test(
    'ordem cronológica e posição por instante, sem agrupar semanas diferentes',
    () {
      final data = WeeklySummaryModel(
        start: now,
        end: now.add(const Duration(days: 30)),
        records: [
          record(at: now.add(const Duration(days: 14))),
          record(at: now.add(const Duration(days: 7))),
        ],
        settings: const GlucoseSettings(),
        profile: profile,
      );
      expect(data.readings.first.x, lessThan(data.readings.last.x));
    },
  );
}
