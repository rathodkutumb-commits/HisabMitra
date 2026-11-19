import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/dialogs.dart';
import '../data/attachment_service.dart';

/// Pending attachment changes of a form, applied only when the form saves.
class AttachmentDraft extends ChangeNotifier {
  final List<StagedAttachment> staged = [];
  final Set<String> removedIds = {};

  bool get hasChanges => staged.isNotEmpty || removedIds.isNotEmpty;

  void add(StagedAttachment a) {
    staged.add(a);
    notifyListeners();
  }

  void removeStaged(StagedAttachment a) {
    staged.remove(a);
    notifyListeners();
  }

  void removeExisting(String id) {
    removedIds.add(id);
    notifyListeners();
  }

  /// Commits staged files and deletes removed ones for [parentId].
  Future<void> apply(
    AttachmentService service, {
    required AttachmentParent parent,
    required String parentId,
  }) async {
    for (final a in List.of(staged)) {
      await service.commit(a, parent: parent, parentId: parentId);
    }
    for (final id in removedIds) {
      await service.delete(id);
    }
    staged.clear();
    removedIds.clear();
  }

  Future<void> discard(AttachmentService service) async {
    for (final a in staged) {
      await service.discard(a);
    }
    staged.clear();
  }
}

class AttachmentsEditor extends ConsumerWidget {
  const AttachmentsEditor({
    super.key,
    required this.draft,
    required this.parent,
    this.parentId,
  });

  final AttachmentDraft draft;
  final AttachmentParent parent;
  final String? parentId;

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    Future<StagedAttachment?> Function(AttachmentService) pick,
  ) async {
    try {
      final staged = await pick(ref.read(attachmentServiceProvider));
      if (staged != null) draft.add(staged);
    } catch (e) {
      if (context.mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final existing = parentId == null
        ? const <AttachmentRow>[]
        : ref.watch(attachmentsForProvider((parent, parentId!))).value ??
              const <AttachmentRow>[];
    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) {
        final visible = existing
            .where((a) => !draft.removedIds.contains(a.id))
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.attachments, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (visible.isNotEmpty || draft.staged.isNotEmpty)
              SizedBox(
                height: 92,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final a in visible)
                      _Thumb(
                        storedName: a.storedName,
                        isImage: a.mimeType.startsWith('image/'),
                        label: a.originalName,
                        onOpen: () => context.push(Routes.attachment(a.id)),
                        onRemove: () => draft.removeExisting(a.id),
                      ),
                    for (final s in draft.staged)
                      _Thumb(
                        stagedPath: s.path,
                        isImage: s.isImage,
                        label: s.originalName,
                        onRemove: () async {
                          draft.removeStaged(s);
                          await ref.read(attachmentServiceProvider).discard(s);
                        },
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.photo_camera_rounded, size: 18),
                  label: Text(l.attachCamera),
                  onPressed: () =>
                      _pick(context, ref, (s) => s.pickImage(camera: true)),
                ),
                ActionChip(
                  avatar: const Icon(Icons.photo_library_rounded, size: 18),
                  label: Text(l.attachGallery),
                  onPressed: () =>
                      _pick(context, ref, (s) => s.pickImage(camera: false)),
                ),
                ActionChip(
                  avatar: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: Text(l.attachPdf),
                  onPressed: () => _pick(context, ref, (s) => s.pickPdf()),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l.attachmentPrivateNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Thumb extends ConsumerWidget {
  const _Thumb({
    this.storedName,
    this.stagedPath,
    required this.isImage,
    required this.label,
    this.onOpen,
    required this.onRemove,
  });

  final String? storedName;
  final String? stagedPath;
  final bool isImage;
  final String label;
  final VoidCallback? onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    Widget content = Icon(
      isImage ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
      size: 36,
      color: scheme.secondary,
    );
    if (isImage) {
      final future = stagedPath != null
          ? Future.value(File(stagedPath!))
          : ref.read(attachmentServiceProvider).fileFor(storedName!);
      content = FutureBuilder<File>(
        future: future,
        builder: (context, snap) => snap.hasData && snap.data!.existsSync()
            ? Image.file(
                snap.data!,
                fit: BoxFit.cover,
                width: 84,
                height: 84,
                cacheWidth: 200,
              )
            : content,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Tooltip(
            message: label,
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 84,
                height: 84,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: content),
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: context.l10n.attachmentRemove,
              icon: CircleAvatar(
                radius: 11,
                backgroundColor: scheme.errorContainer,
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: scheme.onErrorContainer,
                ),
              ),
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only list of attachments for detail screens.
class AttachmentStrip extends ConsumerWidget {
  const AttachmentStrip({
    super.key,
    required this.parent,
    required this.parentId,
  });

  final AttachmentParent parent;
  final String parentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows =
        ref.watch(attachmentsForProvider((parent, parentId))).value ?? const [];
    if (rows.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.attachments, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in rows)
              ActionChip(
                avatar: Icon(
                  a.mimeType.startsWith('image/')
                      ? Icons.image_rounded
                      : Icons.picture_as_pdf_rounded,
                  size: 18,
                ),
                label: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(a.originalName, overflow: TextOverflow.ellipsis),
                ),
                onPressed: () => context.push(Routes.attachment(a.id)),
              ),
          ],
        ),
      ],
    );
  }
}
