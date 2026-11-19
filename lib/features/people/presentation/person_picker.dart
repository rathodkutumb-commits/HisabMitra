import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/people_repository.dart';

/// Field that lets the user pick a person (searchable) or add a new one.
class PersonPickerField extends ConsumerWidget {
  const PersonPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.required = false,
    this.errorText,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String? label;
  final bool required;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final person = value == null
        ? null
        : ref.watch(personProvider(value!)).value;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showPersonPicker(context);
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label ?? l.person,
          errorText: errorText,
          prefixIcon: person == null
              ? const Icon(Icons.person_outline_rounded)
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: InitialsAvatar(name: person.name, radius: 12),
                ),
          suffixIcon: value != null && !required
              ? IconButton(
                  tooltip: l.clear,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.arrow_drop_down_rounded),
        ),
        child: Text(person?.name ?? l.selectPerson),
      ),
    );
  }
}

/// Bottom sheet listing people; returns the chosen id (or a newly created one).
Future<String?> showPersonPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (ctx, scroll) => _PersonPickerSheet(scroll: scroll),
    ),
  );
}

class _PersonPickerSheet extends ConsumerStatefulWidget {
  const _PersonPickerSheet({required this.scroll});

  final ScrollController scroll;

  @override
  ConsumerState<_PersonPickerSheet> createState() => _PersonPickerSheetState();
}

class _PersonPickerSheetState extends ConsumerState<_PersonPickerSheet> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final people = ref.watch(peopleProvider).value ?? const <PersonRow>[];
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? people
        : people
              .where(
                (p) =>
                    p.name.toLowerCase().contains(q) ||
                    (p.phone ?? '').contains(q),
              )
              .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            autofocus: people.length > 8,
            decoration: InputDecoration(
              hintText: l.searchPeople,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person_add_alt_1_rounded),
          ),
          title: Text(l.addNewPerson),
          onTap: () async {
            final id = await context.push<String>(Routes.newPerson);
            if (id != null && context.mounted) Navigator.of(context).pop(id);
          },
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            controller: widget.scroll,
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final p = filtered[i];
              return ListTile(
                leading: InitialsAvatar(name: p.name),
                title: Text(p.name),
                subtitle: p.phone == null ? null : Text(p.phone!),
                onTap: () => Navigator.of(context).pop(p.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
