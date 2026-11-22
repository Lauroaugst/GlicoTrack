import 'package:material_ui/material_ui.dart';

import '../domain/models.dart';
import 'glucose_style.dart';

class GlucoseReading {
  const GlucoseReading({
    required this.day,
    required this.value,
    required this.color,
    required this.x,
  });
  final String day;
  final double value;
  final Color color;
  final double x;
  @override
  bool operator ==(Object other) =>
      other is GlucoseReading &&
      day == other.day &&
      value == other.value &&
      color == other.color &&
      x == other.x;
  @override
  int get hashCode => Object.hash(day, value, color, x);
}

class WeeklySummaryModel {
  WeeklySummaryModel({
    required this.start,
    required this.end,
    required this.records,
    required this.settings,
    required this.profile,
  }) {
    final days = DateUtils.dateOnly(end)
        .difference(DateUtils.dateOnly(start))
        .inDays;
    stats = RecordStatistics(records, settings, days: days);
    final sorted = [...records]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    readings = List.unmodifiable(
      sorted.map(
        (r) => GlucoseReading(
          day: dateLabel(r.measuredAt),
          value: r.glucose.toDouble(),
          color: glucoseColor(settings.classify(r.glucose)),
          x:
              ((r.measuredAt.millisecondsSinceEpoch -
                          start.millisecondsSinceEpoch) /
                      (end.millisecondsSinceEpoch -
                          start.millisecondsSinceEpoch))
                  .clamp(0, 1),
        ),
      ),
    );
  }
  final DateTime start;
  final DateTime
  end; // Exclusive upper bound, including the entire last selected day.
  final List<HealthRecord> records;
  final GlucoseSettings settings;
  final PatientProfile profile;
  late final RecordStatistics stats;
  late final List<GlucoseReading> readings;
  String get dateRange =>
      '${dateLabel(start)} até ${dateLabel(end.subtract(const Duration(microseconds: 1)))}';
  double get average => stats.average ?? 0;
  double get min => stats.min?.toDouble() ?? 0;
  double get max => stats.max?.toDouble() ?? 0;
}
