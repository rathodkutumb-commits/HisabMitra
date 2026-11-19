import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/category_icons.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../data/category_repository.dart';
import 'category_labels.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({
    super.key,
    this.categoryId,
    this.initialType = TransactionType.expense,
  });

  final String? categoryId;
  final TransactionType initialType;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  late TransactionType _type = widget.initialType;
  String _icon = 'more';
  int _color = CategoryIcons.palette.first;
  String? _originalLabel;
  var _loaded = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId == null) {
      _loaded = true;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    final c = await ref
        .read(categoryRepositoryProvider)
        .getById(widget.categoryId!);
    if (!mounted) return;
    if (c == null) {
      Navigator.of(context).pop();
      return;
    }
    final label = c.label(context.l10n);
    setState(() {
      _type = c.type;
      _icon = c.iconKey;
      _color = c.colorValue;
      _name.text = label;
      _originalLabel = c.systemKey == null ? null : label;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(categoryRepositoryProvider)
          .save(
            CategoryDraft(
              id: widget.categoryId,
              name: _name.text,
              type: _type,
              iconKey: _icon,
              colorValue: _color,
              keepSystemName:
                  _originalLabel != null && _name.text.trim() == _originalLabel,
            ),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showFailure(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryId == null ? l.addCategory : l.editCategory),
      ),
      body: !_loaded
          ? const LoadingView()
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: IconBadge(
                      icon: CategoryIcons.of(_icon),
                      color: Color(_color),
                      size: 72,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.categoryId == null) ...[
                    SegmentedButton<TransactionType>(
                      segments: [
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text(l.expense),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text(l.income),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (s) =>
                          setState(() => _type = s.first),
                    ),
                    const SizedBox(height: 16),
                  ],
                  HmTextField(
                    controller: _name,
                    label: l.categoryName,
                    maxLength: 60,
                    required: true,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.categoryIcon,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in CategoryIcons.all.entries)
                        Semantics(
                          selected: _icon == entry.key,
                          button: true,
                          label: entry.key,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _icon = entry.key),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _icon == entry.key
                                    ? Color(_color).withValues(alpha: 0.2)
                                    : scheme.surfaceContainerHigh,
                                border: Border.all(
                                  color: _icon == entry.key
                                      ? Color(_color)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                entry.value,
                                color: _icon == entry.key
                                    ? Color(_color)
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.categoryColor,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final c in CategoryIcons.palette)
                        Semantics(
                          selected: _color == c,
                          button: true,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => setState(() => _color = c),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(c),
                              child: _color == c
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(l.save),
          ),
        ),
      ),
    );
  }
}
