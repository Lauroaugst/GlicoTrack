import 'dart:io';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:glicotrack_dev/data/sync_service.dart';
import 'package:glicotrack_dev/presentation/app_store.dart';
import 'package:glicotrack_dev/screens/data_management_screen.dart';
import 'package:glicotrack_dev/screens/register_screen.dart';
import 'package:glicotrack_dev/screens/history_screen.dart';
import 'package:glicotrack_dev/screens/home_screen.dart';
import 'package:glicotrack_dev/screens/main_screen.dart';
import 'package:glicotrack_dev/screens/timeline_screen.dart';

import 'support/fixtures.dart';
import 'support/memory_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final textFont = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final iconFont = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await textFont.load();
    await iconFont.load();
  });
  late MemoryRepository local;
  late AppStore store;
  var alerts = 0;
  setUp(() async {
    local = MemoryRepository();
    store = AppStore(
      uid: uid,
      local: local,
      sync: SyncService(local, FakeRemote()),
      initialProfile: profile,
    );
    await store.initialize(startSync: false);
    alerts = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('glicotrack/alerts'), (
          _,
        ) async {
          alerts++;
          return null;
        });
  });
  tearDown(() {
    store.dispose();
  });
  Future<void> mount(WidgetTester tester, Widget child) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: store,
        child: MaterialApp(home: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'formulário abre focado, classifica e alerta uma vez por episódio',
    (tester) async {
      await mount(tester, const RegisterScreen());
      final glucose = find.byType(TextField).first;
      expect(tester.widget<TextField>(glucose).focusNode!.hasFocus, isTrue);
      expect(
        tester.widget<TextField>(glucose).keyboardType,
        TextInputType.numberWithOptions(decimal: false),
      );
      await tester.enterText(glucose, '68');
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Hipoglicemia'), findsOneWidget);
      expect(alerts, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(alerts, 1);
      await tester.enterText(glucose, '69');
      await tester.pump(const Duration(milliseconds: 500));
      expect(alerts, 1);
      await tester.enterText(glucose, '120');
      await tester.pump();
      expect(find.text('Na faixa'), findsOneWidget);
      await tester.enterText(glucose, '60');
      await tester.pump(const Duration(milliseconds: 500));
      expect(alerts, 2);
    },
  );
  testWidgets('botão de salvar permanece acessível acima do teclado', (
    tester,
  ) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await mount(tester, const RegisterScreen());
    final button = find.text('Guardar Registro');
    expect(button, findsOneWidget);
    final media = MediaQuery.of(tester.element(find.byType(RegisterScreen)));
    expect(
      tester.getRect(button).bottom,
      lessThan(media.size.height - media.viewInsets.bottom),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'navegação principal inicia na tela de registro com teclado focado e refoca ao retornar',
    (tester) async {
      await mount(tester, const MainScreen());
      final registerFinder = find.byType(RegisterScreen, skipOffstage: false);
      expect(find.byType(RegisterScreen), findsOneWidget);
      final glucoseField = find.descendant(
        of: registerFinder,
        matching: find.byType(TextField, skipOffstage: false),
      );
      expect(
        tester.widget<TextField>(glucoseField.first).focusNode!.hasFocus,
        isTrue,
      );
      // Sai para a Home e confirma perda de foco
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(glucoseField.first).focusNode!.hasFocus,
        isFalse,
      );
      // Retorna para Registro e confirma foco automático novamente
      await tester.tap(find.byIcon(Icons.water_drop_outlined).last);
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(
        tester.widget<TextField>(glucoseField.first).focusNode!.hasFocus,
        isTrue,
      );
    },
  );
  testWidgets(
    'navegação principal mantém o botão acima do teclado sem dupla redução da tela',
    (tester) async {
      await mount(tester, const MainScreen());
      await tester.tap(find.byIcon(Icons.water_drop_outlined).last);
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      final button = find.text('Guardar Registro');
      expect(button, findsOneWidget);
      final media = MediaQuery.of(tester.element(find.byType(RegisterScreen)));
      expect(
        tester.getRect(button).bottom,
        lessThan(media.size.height - media.viewInsets.bottom),
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('salva no repositório antes de confirmar e limpa os campos', (
    tester,
  ) async {
    await mount(tester, const RegisterScreen());
    await tester.enterText(find.byType(TextField).first, '120');
    await tester.ensureVisible(find.text('Guardar Registro'));
    await tester.tap(find.text('Guardar Registro'));
    await tester.pumpAndSettle();
    expect(local.docs.length, 1);
    expect(local.docs.values.single.payload['glucose'], 120);
    expect(find.text('Registro salvo neste aparelho.'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );
  });
  testWidgets('falha local preserva o formulário e não confirma sucesso', (
    tester,
  ) async {
    local.failSave = true;
    await mount(tester, const RegisterScreen());
    await tester.enterText(find.byType(TextField).first, '120');
    await tester.ensureVisible(find.text('Guardar Registro'));
    await tester.tap(find.text('Guardar Registro'));
    await tester.pumpAndSettle();
    expect(local.docs, isEmpty);
    expect(find.text('Registro salvo neste aparelho.'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      '120',
    );
  });
  testWidgets(
    'linha do tempo mantém refeição e detalhes e reage a edição e exclusão',
    (tester) async {
      await store.saveRecord(
        record(
          at: DateTime.now(),
          glucose: 120,
          notes: 'Observação preservada',
        ),
      );
      await mount(tester, const TimelineScreen());
      expect(find.text('Refeição: Café da manhã'), findsOneWidget);
      expect(find.text('Observação preservada'), findsOneWidget);
      expect(find.textContaining('Insulina: 2.0 U'), findsOneWidget);
      expect(find.textContaining('Carboidratos: 30.0 g'), findsOneWidget);
      await store.saveRecord(record(at: DateTime.now(), glucose: 155));
      await tester.pumpAndSettle();
      expect(find.text('155 mg/dL'), findsOneWidget);
      expect(find.text('120 mg/dL'), findsNothing);
      await tester.tap(find.byTooltip('Excluir registro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
      expect(find.text('Nenhum registro encontrado.'), findsOneWidget);
      expect(local.docs[recordId]!.deleted, isTrue);
    },
  );
  testWidgets('Home e histórico exibem somente dados reais e estados vazios', (
    tester,
  ) async {
    await mount(tester, const HomeScreen());
    expect(find.text('Pendente'), findsNWidgets(3));
    expect(find.text('--'), findsNWidgets(3));
    await mount(tester, const DataManagementScreen());
    expect(find.textContaining('0 medições hoje'), findsOneWidget);
    await store.saveRecord(record(at: DateTime.now(), glucose: 133));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 medições hoje'), findsOneWidget);
    await mount(tester, const HomeScreen());
    expect(find.text('133'), findsOneWidget);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: store,
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('133.0 mg/dL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'interface do histórico mantém layout com registros e metas reais',
    (tester) async {
      await store.saveRecord(record(at: DateTime.now(), glucose: 133));
      final boundaryKey = GlobalKey();
      await mount(
        tester,
        RepaintBoundary(key: boundaryKey, child: const HistoryScreen()),
      );
      expect(tester.takeException(), isNull);
      final output = Platform.environment['GLICO_QA_OUTPUT'];
      if (output != null) {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final screenshot = await boundary.toImage(pixelRatio: 1);
          final png = await screenshot.toByteData(
            format: ui.ImageByteFormat.png,
          );
          await Directory(output).create(recursive: true);
          await File('$output/history.png')
              .writeAsBytes(png!.buffer.asUint8List());
          screenshot.dispose();
        });
      }
    },
  );
}
