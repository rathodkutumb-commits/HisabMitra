import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/attachments/data/attachment_service.dart';
import 'package:hisabmitra/features/attachments/presentation/attachments_editor.dart';
import 'package:hisabmitra/l10n/app_localizations.dart';

import '../../helpers/test_db.dart';

/// A valid 1×1 transparent PNG.
const _png = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

Future<StagedAttachment> _stagedPng(WidgetTester tester) async {
  final file = await tester.runAsync(() async {
    final dir = await Directory.systemTemp.createTemp('hm_attach_');
    addTearDown(() => dir.delete(recursive: true));
    final f = File('${dir.path}${Platform.pathSeparator}bill.png');
    await f.writeAsBytes(_png);
    return f;
  });
  return StagedAttachment(
    path: file!.path,
    originalName: 'bill.png',
    mimeType: 'image/png',
    sizeBytes: _png.length,
    sha256: 'test',
  );
}

ProviderContainer _container() {
  final db = newTestDatabase();
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
  );
  addTearDown(() async {
    container.dispose();
    await db.close();
  });
  return container;
}

Future<void> _pumpEditor(
  WidgetTester tester, {
  required AttachmentDraft draft,
  String? parentId,
  ProviderContainer? container,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container ?? _container(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AttachmentsEditor(
            draft: draft,
            parent: AttachmentParent.transaction,
            parentId: parentId,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('staged image thumbnail renders without a build loop', (
    tester,
  ) async {
    final draft = AttachmentDraft()..add(await _stagedPng(tester));

    await _pumpEditor(tester, draft: draft);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsOneWidget);

    // Unmount before the in-memory database closes.
    await tester.pumpWidget(const SizedBox());
  });

  group('recovered camera photo', () {
    testWidgets('is added to a new form once', (tester) async {
      final container = _container();
      container
          .read(recoveredPhotoProvider.notifier)
          .set(await _stagedPng(tester));

      final first = AttachmentDraft();
      await _pumpEditor(tester, draft: first, container: container);
      expect(first.staged, hasLength(1));
      expect(container.read(recoveredPhotoProvider), isNull);

      final second = AttachmentDraft();
      await tester.pumpWidget(const SizedBox());
      await _pumpEditor(tester, draft: second, container: container);
      expect(second.staged, isEmpty);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('is not added to an edit form', (tester) async {
      final container = _container();
      container
          .read(recoveredPhotoProvider.notifier)
          .set(await _stagedPng(tester));

      final draft = AttachmentDraft();
      await _pumpEditor(
        tester,
        draft: draft,
        parentId: 't1',
        container: container,
      );
      expect(draft.staged, isEmpty);
      expect(container.read(recoveredPhotoProvider), isNotNull);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
