import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:glicotrack_dev/data/local_database.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;

import '../test/support/fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('SQLCipher nativo persiste, reabre e impede leitura sem chave', (
    _,
  ) async {
    final local = await LocalDatabase.open('encryption-test');
    final path = local.db.path;
    final rows = await local.db.rawQuery('PRAGMA cipher_version');
    expect(rows, isNotEmpty);
    await local.save(
      recordId,
      'record',
      record(owner: 'encryption-test').toJson(),
    );
    await local.close();
    final bytes = await File(path).openRead(0, 16).first;
    expect(String.fromCharCodes(bytes), isNot(startsWith('SQLite format 3')));
    await expectLater(() async {
      final wrong = await cipher.openDatabase(
        path,
        password: 'incorrect-key',
        singleInstance: false,
      );
      try {
        await wrong.rawQuery('SELECT * FROM documents');
      } finally {
        await wrong.close();
      }
    }(), throwsA(anything));
    final reopened = await LocalDatabase.open('encryption-test');
    expect((await reopened.get(recordId))!.payload['glucose'], 120);
    await reopened.purge();
    await reopened.close();
  });
}
