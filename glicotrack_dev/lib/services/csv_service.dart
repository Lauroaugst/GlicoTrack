import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../presentation/history_summary.dart';
import '../presentation/glucose_style.dart';

class CsvService {
  static String _cell(Object? value) {
    var text = value?.toString() ?? '';
    // Spreadsheet formula injection is possible even in quoted CSV cells.
    if (RegExp(r'^\s*[=+@-]').hasMatch(text)) text = "'$text";
    return '"${text.replaceAll('"', '""')}"';
  }

  static String encode(WeeklySummaryModel summary) {
    final rows = <List<Object?>>[
      [
        'ID',
        'Paciente',
        'Data',
        'Horário',
        'Categoria',
        'Refeição',
        'Glicemia (mg/dL)',
        'Insulina (U)',
        'Carboidratos (g)',
        'Classificação',
        'Observações',
      ],
      ...summary.records.map(
        (r) => [
          r.id,
          summary.profile.name,
          dateLabel(r.measuredAt),
          timeLabel(r.measuredAt),
          r.category.label,
          r.meal,
          r.glucose,
          r.insulin,
          r.carbs,
          summary.settings.classify(r.glucose).label,
          r.notes,
        ],
      ),
    ];
    return '\uFEFF${rows.map((row) => row.map(_cell).join(';')).join('\r\n')}\r\n';
  }

  static String _reportFileName(String patientName) {
    final cleaned = patientName
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^\wÀ-ÿ-]'), '');
    final suffix = cleaned.isEmpty ? 'Paciente' : cleaned;
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final date = '$day-$month-${now.year}';
    return 'Relatorio_${suffix}_$date.csv';
  }

  static Future<void> share(WeeklySummaryModel summary) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(encode(summary))),
            mimeType: 'text/csv',
          ),
        ],
        fileNameOverrides: [_reportFileName(summary.profile.name)],
      ),
    );
  }
}
