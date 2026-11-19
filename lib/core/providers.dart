import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'database/app_database.dart';

/// The single local database. Overridden in `main()` and in tests.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);

/// Source of "now" — overridable for deterministic tests.
class Clock {
  const Clock();
  DateTime now() => DateTime.now();
}

final clockProvider = Provider<Clock>((ref) => const Clock());

class IdGenerator {
  const IdGenerator();
  static const _uuid = Uuid();
  String newId() => _uuid.v4();
}

final idGeneratorProvider = Provider<IdGenerator>((ref) => const IdGenerator());

/// Local owner id for personal records before/without sign-in.
const String localOwnerId = 'self';
