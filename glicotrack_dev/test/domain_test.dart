import 'package:flutter_test/flutter_test.dart';
import 'package:glicotrack_dev/domain/models.dart';
import 'package:glicotrack_dev/domain/sync_document.dart';

import 'support/fixtures.dart';

void main() {
  group('classificação', () {
    const settings = GlucoseSettings(lower: 90, upper: 170);
    test('hipoglicemia sempre abaixo de 70, independente da meta', () {
      expect(settings.classify(69), GlucoseStatus.hypo);
      expect(settings.classify(70), GlucoseStatus.belowTarget);
      expect(settings.classify(89), GlucoseStatus.belowTarget);
      expect(settings.classify(90), GlucoseStatus.inRange);
      expect(settings.classify(170), GlucoseStatus.inRange);
      expect(settings.classify(171), GlucoseStatus.hyper);
    });
    test('faixa padrão e limites inválidos', () {
      expect(const GlucoseSettings().classify(180), GlucoseStatus.inRange);
      expect(const GlucoseSettings(lower: 60).validate, throwsFormatException);
      expect(
        const GlucoseSettings(lower: 180, upper: 180).validate,
        throwsFormatException,
      );
    });
  });
  test('validação dos campos clínicos e limites', () {
    for (final glucose in [-1, 0, 1001]) {
      expect(record(glucose: glucose).validate, throwsFormatException);
    }
    expect(record(insulin: double.nan).validate, throwsFormatException);
    expect(record(carbs: -1).validate, throwsFormatException);
    expect(record(insulin: null, carbs: null).validate, returnsNormally);
    expect(record(notes: 'a' * 2001).validate, throwsFormatException);
  });
  test('serialização preserva categoria, observações e instante', () {
    final r = record(
      category: MeasurementCategory.bedtime,
      notes: 'Após caminhada',
    );
    final restored = HealthRecord.fromJson(r.id, r.uid, r.toJson());
    expect(restored.toJson(), r.toJson());
  });
  test('estatísticas vazias não inventam valores', () {
    final stats = RecordStatistics([], const GlucoseSettings(), days: 7);
    expect(stats.count, 0);
    expect(stats.average, isNull);
    expect(stats.min, isNull);
  });
  test('média, extremos, frequência e percentual de medições na faixa', () {
    final stats = RecordStatistics(
      [record(glucose: 60), record(glucose: 120), record(glucose: 200)],
      const GlucoseSettings(),
      days: 7,
    );
    expect(stats.average, closeTo(126.6667, .001));
    expect(stats.min, 60);
    expect(stats.max, 200);
    expect(stats.inRangePercent, closeTo(100 / 3, .001));
    expect(stats.frequency, closeTo(3 / 7, .001));
  });
  test('tendências exigem histórico e não recomendam dose', () {
    expect(
      TrendIndicator.analyze([], const GlucoseSettings()).message,
      contains('6 medições'),
    );
    final records = List.generate(
      6,
      (i) => record(
        glucose: 110 - i * 8,
        at: now.add(Duration(hours: i)),
      ),
    );
    expect(
      TrendIndicator.analyze(records, const GlucoseSettings()).message,
      contains('baixa glicemia'),
    );
    expect(
      TrendIndicator.analyze(records, const GlucoseSettings()).message,
      contains('não orienta doses'),
    );
  });
  group('conflitos', () {
    test(
      'mesma revisão é idempotente',
      () => expect(
        resolveConflict(document(), document()).revision,
        document().revision,
      ),
    );
    test('revisão causal vence relógio da versão anterior', () {
      final previous = document(clock: 300);
      final next = document(clock: 100, base: previous.revision);
      expect(resolveConflict(previous, next).revision, next.revision);
    });
    test('concorrência usa ordem determinística nos dois sentidos', () {
      final a = document(clock: 100);
      final b = document(clock: 200);
      expect(resolveConflict(a, b).revision, b.revision);
      expect(resolveConflict(b, a).revision, b.revision);
      expect(isConcurrent(a, b), isTrue);
    });
    test('exclusão concorrente impede ressurreição', () {
      final deleted = document(clock: 100, deleted: true);
      final edited = document(clock: 200);
      expect(resolveConflict(deleted, edited).deleted, isTrue);
      expect(resolveConflict(edited, deleted).deleted, isTrue);
    });
    test('rejeita documento de outro usuário', () {
      expect(() => document(owner: 'bob').validate(uid), throwsFormatException);
      expect(
        () => resolveConflict(document(), document(owner: 'bob')),
        throwsFormatException,
      );
    });
  });
}
