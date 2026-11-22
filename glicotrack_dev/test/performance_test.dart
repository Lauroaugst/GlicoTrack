import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:glicotrack_dev/domain/models.dart';
import 'package:glicotrack_dev/presentation/history_summary.dart';
import 'package:glicotrack_dev/screens/history_screen.dart';

import 'local_database_test.dart' show openTestDatabase;
import 'support/fixtures.dart';

void main() {
  sqfliteFfiInit();
  test('métricas de CPU do painter e persistência FFI no host', () async {
    final records = List.generate(
      500,
      (i) => record(
        glucose: 70 + i % 160,
        at: now.add(Duration(minutes: i)),
      ),
    );
    final summary = WeeklySummaryModel(
      start: now,
      end: now.add(const Duration(days: 7)),
      records: records,
      settings: const GlucoseSettings(),
      profile: profile,
    );
    final painter = GlucoseMedicalChartPainter(
      readings: summary.readings,
      start: summary.start,
      end: summary.end,
    );
    final samples = <int>[];
    for (var i = 0; i < 210; i++) {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final clock = Stopwatch()..start();
      painter.paint(canvas, const ui.Size(360, 240));
      clock.stop();
      recorder.endRecording().dispose();
      if (i >= 10) samples.add(clock.elapsedMicroseconds);
    }
    samples.sort();
    final temp = await Directory.systemTemp.createTemp('glicotrack-perf-');
    final dbPath = '${temp.path}${Platform.pathSeparator}benchmark.sqlite';
    final local = await openTestDatabase(path: dbPath);
    final saves = <int>[];
    try {
      for (var i = 0; i < 5; i++) {
        final id = '00000000-0000-4000-8000-${i.toString().padLeft(12, '0')}';
        final clock = Stopwatch()..start();
        await local.save(id, 'record', record(id: id).toJson());
        clock.stop();
        saves.add(clock.elapsedMicroseconds);
      }
      expect((await local.all()).length, 5);
    } finally {
      await local.close();
      await File(dbPath).delete();
      await temp.delete();
    }
    // CPU paint recording is not a GPU frame or a 2 GB Android device benchmark.
    // ignore: avoid_print
    print(
      'HOST_METRICS painter_500_points_cpu_us p50=${samples[100]} p95=${samples[190]} sqlite_ffi_disk_5_saves_us=$saves',
    );
  });
}
