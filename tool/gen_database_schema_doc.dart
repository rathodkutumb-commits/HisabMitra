// Generates docs/DATABASE_SCHEMA.md from Drift's exported schema, so the
// documented columns, keys, checks and indexes always match the real local
// database. Run after changing lib/core/database/tables.dart:
//
//   dart run drift_dev make-migrations
//   dart run tool/gen_database_schema_doc.dart
import 'dart:convert';
import 'dart:io';

/// Purpose, owner and sync behaviour per table (the parts a schema export
/// cannot know).
const _about = <String, (String, String)>{
  'local_user_profile': (
    'The person using this device: name, mobile number and email '
        '(compulsory at sign-up; the email is verified) and the Supabase '
        'user id.',
    'Local. Name and phone are sent to the cloud `user_profiles` row at '
        'sign-up; the email lives in Supabase Auth.',
  ),
  'app_settings': (
    'Non-sensitive preferences as key/value strings (palette, language, '
        'finance and privacy choices, account/tour flags, the pending '
        'sign-up and the tour sample-data ids). Secrets live in secure '
        'storage.',
    'Local only. Included in backups.',
  ),
  'backup_history': (
    'One row per backup ZIP created (manual, automatic or safety) with its '
        'checksum and encryption flag.',
    'Local only.',
  ),
  'categories': (
    'Income and expense categories: built-in defaults (system_key) and the '
        "user's own, with icon and colour.",
    'Local only.',
  ),
  'persons': (
    'People directory used by transactions, the personal ledger, reminders '
        'and group members.',
    'Local only — never uploaded.',
  ),
  'transactions': (
    'Personal income and expense. Loan principal is not stored here.',
    'Local only — never uploaded.',
  ),
  'money_ledger': (
    'Personal lending and borrowing: money given (receivable) or taken '
        '(payable), with optional due date.',
    'Local only — never uploaded.',
  ),
  'money_settlements': (
    'Repayments against a ledger entry; their sum never exceeds the '
        'principal (enforced in LedgerRepository).',
    'Local only — never uploaded.',
  ),
  'groups_cache': (
    'Family, trip and event groups. Local until the owner shares the group '
        'to the cloud.',
    'Local by default. When `is_shared`, mirrors cloud `groups` '
        '(revision, sync_state, deleted_at tombstone).',
  ),
  'group_members_cache': (
    'Group members. A member may be linked to a local person and, when '
        'shared, to a Supabase user.',
    'Synced for shared groups.',
  ),
  'group_expenses_cache': (
    'Group expenses with one payer and a split method.',
    'Synced for shared groups.',
  ),
  'group_expense_splits_cache': (
    'Each member\'s share of a group expense. Shares always add up to the '
        'expense amount (SplitCalculator).',
    'Written together with the expense; synced as part of it.',
  ),
  'group_settlements_cache': (
    'Payments between two members that settle group balances (full or '
        'partial). Expenses are never modified by a settlement.',
    'Synced for shared groups.',
  ),
  'attachments': (
    'Bills and receipts stored in app-private storage. Exactly one parent '
        'column is set.',
    'Local. A group-expense attachment is uploaded to Storage only when the '
        'user explicitly shares it (`remote_path`).',
  ),
  'reminders': (
    'Repayment, collection, group and custom reminders, and recurring '
        'payments (EMI, SIP, rent…) with their schedule.',
    'Local only.',
  ),
  'sync_outbox': (
    'Group changes waiting to be pushed, written in the same DB transaction '
        'as the change. `op_id` is the idempotency key.',
    'Local queue for the sync service.',
  ),
  'sync_inbox': (
    'Server change events received for shared groups (by sequence number).',
    'Local queue for the sync service.',
  ),
  'sync_conflicts': (
    'Both versions of a group record when local and server changes clash. '
        'The user chooses which to keep — never last-write-wins.',
    'Local only.',
  ),
};

String _type(String moor) => switch (moor) {
  'string' => 'TEXT',
  'int' => 'INTEGER',
  'bool' => 'INTEGER (0/1)',
  'dateTime' => 'INTEGER (unix s)',
  'double' => 'REAL',
  'blob' => 'BLOB',
  _ => moor,
};

String _dartExpr(Map<String, Object?> e) => [
  for (final el in (e['elements']! as List))
    if (el is String) el else (el as Map)['lexeme'],
].join();

/// `ComparableExpr(x).isBiggerThanValue(0)` → `amount_paise > 0`.
String _checkSql(String column, String dart) {
  final m = RegExp(r'\.(\w+)\(([^)]*)\)$').firstMatch(dart);
  if (m == null) return dart;
  final args = m.group(2)!.split(',').map((a) => a.trim()).toList();
  return switch (m.group(1)) {
    'isBiggerThanValue' => '$column > ${args[0]}',
    'isBiggerOrEqualValue' => '$column >= ${args[0]}',
    'isSmallerThanValue' => '$column < ${args[0]}',
    'isSmallerOrEqualValue' => '$column <= ${args[0]}',
    'isBetweenValues' => '$column BETWEEN ${args[0]} AND ${args[1]}',
    _ => dart,
  };
}

String _default(Map<String, Object?> c) {
  final raw = c['default_dart'] as String?;
  if (raw == null) return '';
  final m = RegExp(r'Constant\((.*)\)$').firstMatch(raw);
  if (m != null) return m.group(1)!;
  final s = RegExp(r"CustomExpression\('(.*)'\)$").firstMatch(raw);
  return s != null ? s.group(1)!.replaceAll(r"\'", "'") : raw;
}

void main() {
  final dir = Directory('drift_schemas/hisabmitra');
  final latest =
      (dir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.json'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path)))
          .last;
  final version = RegExp(r'v(\d+)\.json$').firstMatch(latest.path)!.group(1);
  final json = jsonDecode(latest.readAsStringSync()) as Map<String, Object?>;
  final entities = (json['entities']! as List).cast<Map<String, Object?>>();
  final tables = {
    for (final e in entities.where((e) => e['type'] == 'table'))
      e['id']! as int: e['data']! as Map<String, Object?>,
  };
  final indexes = entities
      .where((e) => e['type'] == 'index')
      .map((e) => e['data']! as Map<String, Object?>)
      .toList();

  final out = StringBuffer()
    ..writeln('# HisabMitra — Local Database Schema (SQLite / Drift)')
    ..writeln()
    ..writeln(
      '_Generated by `dart run tool/gen_database_schema_doc.dart` from '
      '`${latest.path.replaceAll(r'\', '/')}` — schema version $version. '
      'Do not edit by hand._',
    )
    ..writeln()
    ..writeln('## Conventions')
    ..writeln()
    ..writeln(
      '- Primary keys are client-generated UUID v4 strings (TD-02), so '
      'rows keep the same id locally and in the cloud.',
    )
    ..writeln(
      '- Money is `INTEGER` paise in columns named `*_paise` (TD-01). '
      'No floating point is used for money.',
    )
    ..writeln('- Date-times are stored as unix seconds (Drift default).')
    ..writeln(
      '- Personal tables are local only and hard-deleted. Group tables carry '
      '`revision`, `sync_state` and a `deleted_at` tombstone for sync.',
    )
    ..writeln(
      '- Foreign keys are enforced (`PRAGMA foreign_keys = ON`). '
      'Multi-row financial changes run inside one DB transaction.',
    )
    ..writeln(
      '- Upgrades use step-by-step Drift migrations; user data is never '
      'dropped. Each schema version is exported to `drift_schemas/` and '
      'covered by `test/drift/hisabmitra/migration_test.dart`.',
    )
    ..writeln()
    ..writeln('## Tables')
    ..writeln();
  for (final t in tables.values) {
    out.writeln('- [`${t['name']}`](#${t['name']})');
  }
  out.writeln();

  for (final entry in tables.entries) {
    final t = entry.value;
    final name = t['name']! as String;
    final (purpose, sync) = _about[name] ?? ('', '');
    out
      ..writeln('### `$name`')
      ..writeln()
      ..writeln(purpose)
      ..writeln()
      ..writeln('**Ownership / sync:** $sync')
      ..writeln()
      ..writeln('| Column | Type | Null | Default | Constraints |')
      ..writeln('|---|---|---|---|---|');
    final checks = <String>[];
    for (final c in (t['columns']! as List).cast<Map<String, Object?>>()) {
      final constraints = <String>[];
      for (final f in (c['dsl_features']! as List)) {
        if (f == 'unique') constraints.add('UNIQUE');
        if (f is! Map) continue;
        if (f['foreign_key'] case final Map<Object?, Object?> fk) {
          final to = fk['to']! as Map<Object?, Object?>;
          final onDelete = fk['on_delete'];
          constraints.add(
            'FK → `${to['table']}.${to['column']}`'
            '${onDelete == null ? '' : ' (on delete $onDelete)'}',
          );
        }
        if (f['check'] case final Map<Object?, Object?> check) {
          checks.add(
            '`${_checkSql(c['name']! as String, _dartExpr((check['dart_expression']! as Map<Object?, Object?>).cast()))}`',
          );
          constraints.add('CHECK');
        }
        if (f['allowed-lengths'] case final Map<Object?, Object?> len) {
          constraints.add('length ${len['min']}–${len['max']}');
        }
      }
      out.writeln(
        '| `${c['name']}` | ${_type(c['moor_type']! as String)} '
        '| ${c['nullable'] == true ? 'yes' : 'no'} '
        '| ${_default(c).isEmpty ? '' : '`${_default(c)}`'} '
        '| ${constraints.join(', ')} |',
      );
    }
    out.writeln();
    final pk = (t['explicit_pk'] as List?)?.cast<String>();
    out.writeln(
      '**Primary key:** ${pk == null ? '`rowid`' : pk.map((c) => '`$c`').join(', ')}',
    );
    final uniqueKeys = (t['unique_keys'] as List?)?.cast<List<Object?>>();
    if (uniqueKeys != null && uniqueKeys.isNotEmpty) {
      out.writeln(
        '  \n**Unique:** ${uniqueKeys.map((k) => '(${k.join(', ')})').join('; ')}',
      );
    }
    final tableChecks = [
      ...checks,
      for (final s in (t['constraints'] as List? ?? const []).cast<String>())
        '`$s`',
    ];
    if (tableChecks.isNotEmpty) {
      out.writeln('  \n**Checks:** ${tableChecks.join('; ')}');
    }
    final idx = indexes.where((i) => i['on'] == entry.key).toList();
    if (idx.isNotEmpty) {
      out.writeln(
        '  \n**Indexes:** ${idx.map((i) {
          final cols = (i['columns'] as List).map((c) => (c as Map)['column']).join(', ');
          return '`${i['name']}` ($cols)${i['unique'] == true ? ' unique' : ''}';
        }).join('; ')}',
      );
    }
    out.writeln();
  }

  File('docs/DATABASE_SCHEMA.md').writeAsStringSync(out.toString());
  stdout.writeln('Wrote docs/DATABASE_SCHEMA.md (${tables.length} tables).');
}
