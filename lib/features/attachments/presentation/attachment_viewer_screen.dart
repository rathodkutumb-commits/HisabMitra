import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../data/attachment_service.dart';

class AttachmentViewerScreen extends ConsumerWidget {
  const AttachmentViewerScreen({super.key, required this.attachmentId});

  final String attachmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final row = ref.watch(attachmentProvider(attachmentId));
    return AsyncValueView(
      value: row,
      data: (a) {
        if (a == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.broken_image_rounded,
              title: l.errorNotFound,
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(a.originalName, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                tooltip: l.attachmentOpenExternal,
                icon: const Icon(Icons.open_in_new_rounded),
                onPressed: () async {
                  final file = await ref
                      .read(attachmentServiceProvider)
                      .ensureLocal(a);
                  if (file == null) {
                    if (context.mounted) {
                      showFailure(context, const AttachmentFailure('missing'));
                    }
                    return;
                  }
                  await SharePlus.instance.share(
                    ShareParams(
                      files: [
                        XFile(
                          file.path,
                          mimeType: a.mimeType,
                          name: a.originalName,
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: l.delete,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () async {
                  final ok = await confirmDelete(
                    context,
                    message: l.attachmentDeleteConfirm,
                  );
                  if (!ok) return;
                  await ref.read(attachmentServiceProvider).delete(a.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
          body: _AttachmentBody(row: a),
        );
      },
    );
  }
}

class _AttachmentBody extends ConsumerStatefulWidget {
  const _AttachmentBody({required this.row});

  final AttachmentRow row;

  @override
  ConsumerState<_AttachmentBody> createState() => _AttachmentBodyState();
}

class _AttachmentBodyState extends ConsumerState<_AttachmentBody> {
  late Future<File?> _file = _load();

  AttachmentRow get row => widget.row;

  /// The file on this phone, downloaded from the account when needed.
  Future<File?> _load() => ref.read(attachmentServiceProvider).ensureLocal(row);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return FutureBuilder<File?>(
      future: _file,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        final file = snap.data;
        if (file == null) {
          final canDownload = row.remotePath?.isNotEmpty ?? false;
          return EmptyState(
            icon: Icons.broken_image_rounded,
            title: canDownload
                ? l.attachmentDownloadRetry
                : l.attachmentMissing,
            actionLabel: canDownload ? l.retry : null,
            onAction: canDownload
                ? () => setState(() => _file = _load())
                : null,
          );
        }
        if (row.mimeType.startsWith('image/')) {
          return InteractiveViewer(
            maxScale: 5,
            child: Center(
              child: Image.file(
                file,
                errorBuilder: (_, _, _) => EmptyState(
                  icon: Icons.broken_image_rounded,
                  title: l.attachmentMissing,
                ),
              ),
            ),
          );
        }
        return _PdfPages(file: file);
      },
    );
  }
}

/// Renders PDF pages to images in-app (via the platform PDF renderer).
class _PdfPages extends StatelessWidget {
  const _PdfPages({required this.file});

  final File file;

  Stream<Uint8List> _pages() async* {
    final bytes = await file.readAsBytes();
    await for (final page in Printing.raster(bytes, dpi: 120)) {
      yield await page.toPng();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Uint8List>>(
      stream: _pages()
          .fold<List<Uint8List>>([], (list, p) => [...list, p])
          .asStream(),
      builder: (context, snap) {
        if (snap.hasError) {
          return EmptyState(
            icon: Icons.picture_as_pdf_rounded,
            title: context.l10n.genericError,
          );
        }
        if (!snap.hasData) return const LoadingView();
        return InteractiveViewer(
          maxScale: 4,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: snap.data!.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                Material(elevation: 2, child: Image.memory(snap.data![i])),
          ),
        );
      },
    );
  }
}
