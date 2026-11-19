// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalUserProfileTable extends LocalUserProfile
    with TableInfo<$LocalUserProfileTable, LocalUserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteUserIdMeta = const VerificationMeta(
    'remoteUserId',
  );
  @override
  late final GeneratedColumn<String> remoteUserId = GeneratedColumn<String>(
    'remote_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    displayName,
    phone,
    email,
    remoteUserId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_user_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('remote_user_id')) {
      context.handle(
        _remoteUserIdMeta,
        remoteUserId.isAcceptableOrUnknown(
          data['remote_user_id']!,
          _remoteUserIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserProfileRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      remoteUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_user_id'],
      ),
    );
  }

  @override
  $LocalUserProfileTable createAlias(String alias) {
    return $LocalUserProfileTable(attachedDatabase, alias);
  }
}

class LocalUserProfileRow extends DataClass
    implements Insertable<LocalUserProfileRow> {
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Always `self` — single row table.
  final String id;
  final String displayName;

  /// Mobile number in E.164 (compulsory at sign-up; not SMS-verified).
  final String? phone;

  /// Email address, verified by a code or link at sign-up (schema v3).
  final String? email;

  /// Supabase auth user id once the user has signed in.
  final String? remoteUserId;
  const LocalUserProfileRow({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.displayName,
    this.phone,
    this.email,
    this.remoteUserId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || remoteUserId != null) {
      map['remote_user_id'] = Variable<String>(remoteUserId);
    }
    return map;
  }

  LocalUserProfileCompanion toCompanion(bool nullToAbsent) {
    return LocalUserProfileCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      displayName: Value(displayName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      remoteUserId: remoteUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUserId),
    );
  }

  factory LocalUserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserProfileRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      remoteUserId: serializer.fromJson<String?>(json['remoteUserId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'remoteUserId': serializer.toJson<String?>(remoteUserId),
    };
  }

  LocalUserProfileRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    String? displayName,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> remoteUserId = const Value.absent(),
  }) => LocalUserProfileRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    remoteUserId: remoteUserId.present ? remoteUserId.value : this.remoteUserId,
  );
  LocalUserProfileRow copyWithCompanion(LocalUserProfileCompanion data) {
    return LocalUserProfileRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      remoteUserId: data.remoteUserId.present
          ? data.remoteUserId.value
          : this.remoteUserId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserProfileRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('remoteUserId: $remoteUserId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    displayName,
    phone,
    email,
    remoteUserId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserProfileRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.remoteUserId == this.remoteUserId);
}

class LocalUserProfileCompanion extends UpdateCompanion<LocalUserProfileRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> displayName;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> remoteUserId;
  final Value<int> rowid;
  const LocalUserProfileCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.remoteUserId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUserProfileCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    required String id,
    required String displayName,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.remoteUserId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       displayName = Value(displayName);
  static Insertable<LocalUserProfileRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? remoteUserId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (remoteUserId != null) 'remote_user_id': remoteUserId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUserProfileCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? displayName,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? remoteUserId,
    Value<int>? rowid,
  }) {
    return LocalUserProfileCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      remoteUserId: remoteUserId ?? this.remoteUserId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (remoteUserId.present) {
      map['remote_user_id'] = Variable<String>(remoteUserId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserProfileCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('remoteUserId: $remoteUserId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSettingRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingRow copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupHistoryTable extends BackupHistory
    with TableInfo<$BackupHistoryTable, BackupHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedMeta = const VerificationMeta(
    'encrypted',
  );
  @override
  late final GeneratedColumn<bool> encrypted = GeneratedColumn<bool>(
    'encrypted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("encrypted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<BackupKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BackupKind>($BackupHistoryTable.$converterkind);
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fileName,
    filePath,
    sizeBytes,
    sha256,
    encrypted,
    kind,
    schemaVersion,
    appVersion,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('encrypted')) {
      context.handle(
        _encryptedMeta,
        encrypted.isAcceptableOrUnknown(data['encrypted']!, _encryptedMeta),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      encrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}encrypted'],
      )!,
      kind: $BackupHistoryTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BackupHistoryTable createAlias(String alias) {
    return $BackupHistoryTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BackupKind, String, String> $converterkind =
      const EnumNameConverter<BackupKind>(BackupKind.values);
}

class BackupHistoryRow extends DataClass
    implements Insertable<BackupHistoryRow> {
  final String id;
  final String fileName;
  final String filePath;
  final int sizeBytes;
  final String sha256;
  final bool encrypted;
  final BackupKind kind;
  final int schemaVersion;
  final String appVersion;
  final DateTime createdAt;
  const BackupHistoryRow({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.sizeBytes,
    required this.sha256,
    required this.encrypted,
    required this.kind,
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['sha256'] = Variable<String>(sha256);
    map['encrypted'] = Variable<bool>(encrypted);
    {
      map['kind'] = Variable<String>(
        $BackupHistoryTable.$converterkind.toSql(kind),
      );
    }
    map['schema_version'] = Variable<int>(schemaVersion);
    map['app_version'] = Variable<String>(appVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BackupHistoryCompanion toCompanion(bool nullToAbsent) {
    return BackupHistoryCompanion(
      id: Value(id),
      fileName: Value(fileName),
      filePath: Value(filePath),
      sizeBytes: Value(sizeBytes),
      sha256: Value(sha256),
      encrypted: Value(encrypted),
      kind: Value(kind),
      schemaVersion: Value(schemaVersion),
      appVersion: Value(appVersion),
      createdAt: Value(createdAt),
    );
  }

  factory BackupHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      sha256: serializer.fromJson<String>(json['sha256']),
      encrypted: serializer.fromJson<bool>(json['encrypted']),
      kind: $BackupHistoryTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'sha256': serializer.toJson<String>(sha256),
      'encrypted': serializer.toJson<bool>(encrypted),
      'kind': serializer.toJson<String>(
        $BackupHistoryTable.$converterkind.toJson(kind),
      ),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'appVersion': serializer.toJson<String>(appVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BackupHistoryRow copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? sizeBytes,
    String? sha256,
    bool? encrypted,
    BackupKind? kind,
    int? schemaVersion,
    String? appVersion,
    DateTime? createdAt,
  }) => BackupHistoryRow(
    id: id ?? this.id,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    sha256: sha256 ?? this.sha256,
    encrypted: encrypted ?? this.encrypted,
    kind: kind ?? this.kind,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    appVersion: appVersion ?? this.appVersion,
    createdAt: createdAt ?? this.createdAt,
  );
  BackupHistoryRow copyWithCompanion(BackupHistoryCompanion data) {
    return BackupHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      encrypted: data.encrypted.present ? data.encrypted.value : this.encrypted,
      kind: data.kind.present ? data.kind.value : this.kind,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupHistoryRow(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('encrypted: $encrypted, ')
          ..write('kind: $kind, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fileName,
    filePath,
    sizeBytes,
    sha256,
    encrypted,
    kind,
    schemaVersion,
    appVersion,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupHistoryRow &&
          other.id == this.id &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.sizeBytes == this.sizeBytes &&
          other.sha256 == this.sha256 &&
          other.encrypted == this.encrypted &&
          other.kind == this.kind &&
          other.schemaVersion == this.schemaVersion &&
          other.appVersion == this.appVersion &&
          other.createdAt == this.createdAt);
}

class BackupHistoryCompanion extends UpdateCompanion<BackupHistoryRow> {
  final Value<String> id;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<int> sizeBytes;
  final Value<String> sha256;
  final Value<bool> encrypted;
  final Value<BackupKind> kind;
  final Value<int> schemaVersion;
  final Value<String> appVersion;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BackupHistoryCompanion({
    this.id = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.encrypted = const Value.absent(),
    this.kind = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupHistoryCompanion.insert({
    required String id,
    required String fileName,
    required String filePath,
    required int sizeBytes,
    required String sha256,
    this.encrypted = const Value.absent(),
    required BackupKind kind,
    required int schemaVersion,
    required String appVersion,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fileName = Value(fileName),
       filePath = Value(filePath),
       sizeBytes = Value(sizeBytes),
       sha256 = Value(sha256),
       kind = Value(kind),
       schemaVersion = Value(schemaVersion),
       appVersion = Value(appVersion),
       createdAt = Value(createdAt);
  static Insertable<BackupHistoryRow> custom({
    Expression<String>? id,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<int>? sizeBytes,
    Expression<String>? sha256,
    Expression<bool>? encrypted,
    Expression<String>? kind,
    Expression<int>? schemaVersion,
    Expression<String>? appVersion,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha256 != null) 'sha256': sha256,
      if (encrypted != null) 'encrypted': encrypted,
      if (kind != null) 'kind': kind,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (appVersion != null) 'app_version': appVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? fileName,
    Value<String>? filePath,
    Value<int>? sizeBytes,
    Value<String>? sha256,
    Value<bool>? encrypted,
    Value<BackupKind>? kind,
    Value<int>? schemaVersion,
    Value<String>? appVersion,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BackupHistoryCompanion(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      encrypted: encrypted ?? this.encrypted,
      kind: kind ?? this.kind,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (encrypted.present) {
      map['encrypted'] = Variable<bool>(encrypted.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $BackupHistoryTable.$converterkind.toSql(kind.value),
      );
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupHistoryCompanion(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('encrypted: $encrypted, ')
          ..write('kind: $kind, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemKeyMeta = const VerificationMeta(
    'systemKey',
  );
  @override
  late final GeneratedColumn<String> systemKey = GeneratedColumn<String>(
    'system_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TransactionType>($CategoriesTable.$convertertype);
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    systemKey,
    name,
    type,
    iconKey,
    colorValue,
    sortOrder,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('system_key')) {
      context.handle(
        _systemKeyMeta,
        systemKey.isAcceptableOrUnknown(data['system_key']!, _systemKeyMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      systemKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_key'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $CategoriesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, String, String> $convertertype =
      const EnumNameConverter<TransactionType>(TransactionType.values);
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;

  /// Stable key of a built-in category (localised name in the UI). `null`
  /// for user-created categories or once a built-in one is renamed.
  final String? systemKey;
  final String name;
  final TransactionType type;
  final String iconKey;
  final int colorValue;
  final int sortOrder;
  final bool isArchived;
  const CategoryRow({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.systemKey,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorValue,
    required this.sortOrder,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || systemKey != null) {
      map['system_key'] = Variable<String>(systemKey);
    }
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>(
        $CategoriesTable.$convertertype.toSql(type),
      );
    }
    map['icon_key'] = Variable<String>(iconKey);
    map['color_value'] = Variable<int>(colorValue);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      systemKey: systemKey == null && nullToAbsent
          ? const Value.absent()
          : Value(systemKey),
      name: Value(name),
      type: Value(type),
      iconKey: Value(iconKey),
      colorValue: Value(colorValue),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      systemKey: serializer.fromJson<String?>(json['systemKey']),
      name: serializer.fromJson<String>(json['name']),
      type: $CategoriesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'systemKey': serializer.toJson<String?>(systemKey),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $CategoriesTable.$convertertype.toJson(type),
      ),
      'iconKey': serializer.toJson<String>(iconKey),
      'colorValue': serializer.toJson<int>(colorValue),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  CategoryRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    Value<String?> systemKey = const Value.absent(),
    String? name,
    TransactionType? type,
    String? iconKey,
    int? colorValue,
    int? sortOrder,
    bool? isArchived,
  }) => CategoryRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    systemKey: systemKey.present ? systemKey.value : this.systemKey,
    name: name ?? this.name,
    type: type ?? this.type,
    iconKey: iconKey ?? this.iconKey,
    colorValue: colorValue ?? this.colorValue,
    sortOrder: sortOrder ?? this.sortOrder,
    isArchived: isArchived ?? this.isArchived,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      systemKey: data.systemKey.present ? data.systemKey.value : this.systemKey,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('systemKey: $systemKey, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    systemKey,
    name,
    type,
    iconKey,
    colorValue,
    sortOrder,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.systemKey == this.systemKey &&
          other.name == this.name &&
          other.type == this.type &&
          other.iconKey == this.iconKey &&
          other.colorValue == this.colorValue &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String?> systemKey;
  final Value<String> name;
  final Value<TransactionType> type;
  final Value<String> iconKey;
  final Value<int> colorValue;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.systemKey = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    required String id,
    this.systemKey = const Value.absent(),
    required String name,
    required TransactionType type,
    required String iconKey,
    required int colorValue,
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       type = Value(type),
       iconKey = Value(iconKey),
       colorValue = Value(colorValue);
  static Insertable<CategoryRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? systemKey,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? iconKey,
    Expression<int>? colorValue,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (systemKey != null) 'system_key': systemKey,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorValue != null) 'color_value': colorValue,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String?>? systemKey,
    Value<String>? name,
    Value<TransactionType>? type,
    Value<String>? iconKey,
    Value<int>? colorValue,
    Value<int>? sortOrder,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      systemKey: systemKey ?? this.systemKey,
      name: name ?? this.name,
      type: type ?? this.type,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (systemKey.present) {
      map['system_key'] = Variable<String>(systemKey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $CategoriesTable.$convertertype.toSql(type.value),
      );
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('systemKey: $systemKey, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonsTable extends Persons with TableInfo<$PersonsTable, PersonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    name,
    phone,
    email,
    description,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'persons';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $PersonsTable createAlias(String alias) {
    return $PersonsTable(attachedDatabase, alias);
  }
}

class PersonRow extends DataClass implements Insertable<PersonRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? description;
  final String? notes;
  const PersonRow({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.description,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PersonsCompanion toCompanion(bool nullToAbsent) {
    return PersonsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory PersonRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      description: serializer.fromJson<String?>(json['description']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'description': serializer.toJson<String?>(description),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  PersonRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => PersonRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    description: description.present ? description.value : this.description,
    notes: notes.present ? notes.value : this.notes,
  );
  PersonRow copyWithCompanion(PersonsCompanion data) {
    return PersonRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      description: data.description.present
          ? data.description.value
          : this.description,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('description: $description, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    name,
    phone,
    email,
    description,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.description == this.description &&
          other.notes == this.notes);
}

class PersonsCompanion extends UpdateCompanion<PersonRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> description;
  final Value<String?> notes;
  final Value<int> rowid;
  const PersonsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonsCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name);
  static Insertable<PersonRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? description,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? description,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return PersonsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TransactionType>($TransactionsTable.$convertertype);
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(amountPaise).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _txnDateMeta = const VerificationMeta(
    'txnDate',
  );
  @override
  late final GeneratedColumn<DateTime> txnDate = GeneratedColumn<DateTime>(
    'txn_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String>
  paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PaymentMethod>($TransactionsTable.$converterpaymentMethod);
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    ownerId,
    type,
    amountPaise,
    categoryId,
    txnDate,
    paymentMethod,
    personId,
    description,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('txn_date')) {
      context.handle(
        _txnDateMeta,
        txnDate.isAcceptableOrUnknown(data['txn_date']!, _txnDateMeta),
      );
    } else if (isInserting) {
      context.missing(_txnDateMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      type: $TransactionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      txnDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}txn_date'],
      )!,
      paymentMethod: $TransactionsTable.$converterpaymentMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_method'],
        )!,
      ),
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, String, String> $convertertype =
      const EnumNameConverter<TransactionType>(TransactionType.values);
  static JsonTypeConverter2<PaymentMethod, String, String>
  $converterpaymentMethod = const EnumNameConverter<PaymentMethod>(
    PaymentMethod.values,
  );
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;

  /// `self` locally, or the Supabase user id once signed in.
  final String ownerId;
  final TransactionType type;
  final int amountPaise;
  final String categoryId;
  final DateTime txnDate;
  final PaymentMethod paymentMethod;
  final String? personId;
  final String description;
  final String? notes;
  const TransactionRow({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.ownerId,
    required this.type,
    required this.amountPaise,
    required this.categoryId,
    required this.txnDate,
    required this.paymentMethod,
    this.personId,
    required this.description,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['type'] = Variable<String>(
        $TransactionsTable.$convertertype.toSql(type),
      );
    }
    map['amount_paise'] = Variable<int>(amountPaise);
    map['category_id'] = Variable<String>(categoryId);
    map['txn_date'] = Variable<DateTime>(txnDate);
    {
      map['payment_method'] = Variable<String>(
        $TransactionsTable.$converterpaymentMethod.toSql(paymentMethod),
      );
    }
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      ownerId: Value(ownerId),
      type: Value(type),
      amountPaise: Value(amountPaise),
      categoryId: Value(categoryId),
      txnDate: Value(txnDate),
      paymentMethod: Value(paymentMethod),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      description: Value(description),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      type: $TransactionsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      txnDate: serializer.fromJson<DateTime>(json['txnDate']),
      paymentMethod: $TransactionsTable.$converterpaymentMethod.fromJson(
        serializer.fromJson<String>(json['paymentMethod']),
      ),
      personId: serializer.fromJson<String?>(json['personId']),
      description: serializer.fromJson<String>(json['description']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'type': serializer.toJson<String>(
        $TransactionsTable.$convertertype.toJson(type),
      ),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'categoryId': serializer.toJson<String>(categoryId),
      'txnDate': serializer.toJson<DateTime>(txnDate),
      'paymentMethod': serializer.toJson<String>(
        $TransactionsTable.$converterpaymentMethod.toJson(paymentMethod),
      ),
      'personId': serializer.toJson<String?>(personId),
      'description': serializer.toJson<String>(description),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  TransactionRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    String? ownerId,
    TransactionType? type,
    int? amountPaise,
    String? categoryId,
    DateTime? txnDate,
    PaymentMethod? paymentMethod,
    Value<String?> personId = const Value.absent(),
    String? description,
    Value<String?> notes = const Value.absent(),
  }) => TransactionRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    type: type ?? this.type,
    amountPaise: amountPaise ?? this.amountPaise,
    categoryId: categoryId ?? this.categoryId,
    txnDate: txnDate ?? this.txnDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    personId: personId.present ? personId.value : this.personId,
    description: description ?? this.description,
    notes: notes.present ? notes.value : this.notes,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      type: data.type.present ? data.type.value : this.type,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      txnDate: data.txnDate.present ? data.txnDate.value : this.txnDate,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      personId: data.personId.present ? data.personId.value : this.personId,
      description: data.description.present
          ? data.description.value
          : this.description,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('type: $type, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('categoryId: $categoryId, ')
          ..write('txnDate: $txnDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('personId: $personId, ')
          ..write('description: $description, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    ownerId,
    type,
    amountPaise,
    categoryId,
    txnDate,
    paymentMethod,
    personId,
    description,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.type == this.type &&
          other.amountPaise == this.amountPaise &&
          other.categoryId == this.categoryId &&
          other.txnDate == this.txnDate &&
          other.paymentMethod == this.paymentMethod &&
          other.personId == this.personId &&
          other.description == this.description &&
          other.notes == this.notes);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> ownerId;
  final Value<TransactionType> type;
  final Value<int> amountPaise;
  final Value<String> categoryId;
  final Value<DateTime> txnDate;
  final Value<PaymentMethod> paymentMethod;
  final Value<String?> personId;
  final Value<String> description;
  final Value<String?> notes;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.type = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.txnDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.personId = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    required String id,
    required String ownerId,
    required TransactionType type,
    required int amountPaise,
    required String categoryId,
    required DateTime txnDate,
    required PaymentMethod paymentMethod,
    this.personId = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       ownerId = Value(ownerId),
       type = Value(type),
       amountPaise = Value(amountPaise),
       categoryId = Value(categoryId),
       txnDate = Value(txnDate),
       paymentMethod = Value(paymentMethod);
  static Insertable<TransactionRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? type,
    Expression<int>? amountPaise,
    Expression<String>? categoryId,
    Expression<DateTime>? txnDate,
    Expression<String>? paymentMethod,
    Expression<String>? personId,
    Expression<String>? description,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (type != null) 'type': type,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (categoryId != null) 'category_id': categoryId,
      if (txnDate != null) 'txn_date': txnDate,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (personId != null) 'person_id': personId,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? ownerId,
    Value<TransactionType>? type,
    Value<int>? amountPaise,
    Value<String>? categoryId,
    Value<DateTime>? txnDate,
    Value<PaymentMethod>? paymentMethod,
    Value<String?>? personId,
    Value<String>? description,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      amountPaise: amountPaise ?? this.amountPaise,
      categoryId: categoryId ?? this.categoryId,
      txnDate: txnDate ?? this.txnDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      personId: personId ?? this.personId,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $TransactionsTable.$convertertype.toSql(type.value),
      );
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (txnDate.present) {
      map['txn_date'] = Variable<DateTime>(txnDate.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        $TransactionsTable.$converterpaymentMethod.toSql(paymentMethod.value),
      );
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('type: $type, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('categoryId: $categoryId, ')
          ..write('txnDate: $txnDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('personId: $personId, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoneyLedgerTable extends MoneyLedger
    with TableInfo<$MoneyLedgerTable, LedgerEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoneyLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LedgerDirection, String>
  direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LedgerDirection>($MoneyLedgerTable.$converterdirection);
  static const VerificationMeta _principalPaiseMeta = const VerificationMeta(
    'principalPaise',
  );
  @override
  late final GeneratedColumn<int> principalPaise = GeneratedColumn<int>(
    'principal_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(principalPaise).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String>
  paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PaymentMethod>($MoneyLedgerTable.$converterpaymentMethod);
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    personId,
    direction,
    principalPaise,
    entryDate,
    dueDate,
    paymentMethod,
    description,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('principal_paise')) {
      context.handle(
        _principalPaiseMeta,
        principalPaise.isAcceptableOrUnknown(
          data['principal_paise']!,
          _principalPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_principalPaiseMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntryRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      direction: $MoneyLedgerTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      principalPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}principal_paise'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_date'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      paymentMethod: $MoneyLedgerTable.$converterpaymentMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_method'],
        )!,
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $MoneyLedgerTable createAlias(String alias) {
    return $MoneyLedgerTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LedgerDirection, String, String>
  $converterdirection = const EnumNameConverter<LedgerDirection>(
    LedgerDirection.values,
  );
  static JsonTypeConverter2<PaymentMethod, String, String>
  $converterpaymentMethod = const EnumNameConverter<PaymentMethod>(
    PaymentMethod.values,
  );
}

class LedgerEntryRow extends DataClass implements Insertable<LedgerEntryRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final String personId;
  final LedgerDirection direction;
  final int principalPaise;
  final DateTime entryDate;
  final DateTime? dueDate;
  final PaymentMethod paymentMethod;
  final String description;
  final String? notes;
  const LedgerEntryRow({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.personId,
    required this.direction,
    required this.principalPaise,
    required this.entryDate,
    this.dueDate,
    required this.paymentMethod,
    required this.description,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    {
      map['direction'] = Variable<String>(
        $MoneyLedgerTable.$converterdirection.toSql(direction),
      );
    }
    map['principal_paise'] = Variable<int>(principalPaise);
    map['entry_date'] = Variable<DateTime>(entryDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    {
      map['payment_method'] = Variable<String>(
        $MoneyLedgerTable.$converterpaymentMethod.toSql(paymentMethod),
      );
    }
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  MoneyLedgerCompanion toCompanion(bool nullToAbsent) {
    return MoneyLedgerCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      personId: Value(personId),
      direction: Value(direction),
      principalPaise: Value(principalPaise),
      entryDate: Value(entryDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      paymentMethod: Value(paymentMethod),
      description: Value(description),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LedgerEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntryRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      direction: $MoneyLedgerTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      principalPaise: serializer.fromJson<int>(json['principalPaise']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      paymentMethod: $MoneyLedgerTable.$converterpaymentMethod.fromJson(
        serializer.fromJson<String>(json['paymentMethod']),
      ),
      description: serializer.fromJson<String>(json['description']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'direction': serializer.toJson<String>(
        $MoneyLedgerTable.$converterdirection.toJson(direction),
      ),
      'principalPaise': serializer.toJson<int>(principalPaise),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'paymentMethod': serializer.toJson<String>(
        $MoneyLedgerTable.$converterpaymentMethod.toJson(paymentMethod),
      ),
      'description': serializer.toJson<String>(description),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LedgerEntryRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    String? personId,
    LedgerDirection? direction,
    int? principalPaise,
    DateTime? entryDate,
    Value<DateTime?> dueDate = const Value.absent(),
    PaymentMethod? paymentMethod,
    String? description,
    Value<String?> notes = const Value.absent(),
  }) => LedgerEntryRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    personId: personId ?? this.personId,
    direction: direction ?? this.direction,
    principalPaise: principalPaise ?? this.principalPaise,
    entryDate: entryDate ?? this.entryDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    description: description ?? this.description,
    notes: notes.present ? notes.value : this.notes,
  );
  LedgerEntryRow copyWithCompanion(MoneyLedgerCompanion data) {
    return LedgerEntryRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      direction: data.direction.present ? data.direction.value : this.direction,
      principalPaise: data.principalPaise.present
          ? data.principalPaise.value
          : this.principalPaise,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      description: data.description.present
          ? data.description.value
          : this.description,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntryRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('direction: $direction, ')
          ..write('principalPaise: $principalPaise, ')
          ..write('entryDate: $entryDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('description: $description, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    personId,
    direction,
    principalPaise,
    entryDate,
    dueDate,
    paymentMethod,
    description,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntryRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.direction == this.direction &&
          other.principalPaise == this.principalPaise &&
          other.entryDate == this.entryDate &&
          other.dueDate == this.dueDate &&
          other.paymentMethod == this.paymentMethod &&
          other.description == this.description &&
          other.notes == this.notes);
}

class MoneyLedgerCompanion extends UpdateCompanion<LedgerEntryRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> personId;
  final Value<LedgerDirection> direction;
  final Value<int> principalPaise;
  final Value<DateTime> entryDate;
  final Value<DateTime?> dueDate;
  final Value<PaymentMethod> paymentMethod;
  final Value<String> description;
  final Value<String?> notes;
  final Value<int> rowid;
  const MoneyLedgerCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.direction = const Value.absent(),
    this.principalPaise = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoneyLedgerCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    required String id,
    required String personId,
    required LedgerDirection direction,
    required int principalPaise,
    required DateTime entryDate,
    this.dueDate = const Value.absent(),
    required PaymentMethod paymentMethod,
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       personId = Value(personId),
       direction = Value(direction),
       principalPaise = Value(principalPaise),
       entryDate = Value(entryDate),
       paymentMethod = Value(paymentMethod);
  static Insertable<LedgerEntryRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? direction,
    Expression<int>? principalPaise,
    Expression<DateTime>? entryDate,
    Expression<DateTime>? dueDate,
    Expression<String>? paymentMethod,
    Expression<String>? description,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (direction != null) 'direction': direction,
      if (principalPaise != null) 'principal_paise': principalPaise,
      if (entryDate != null) 'entry_date': entryDate,
      if (dueDate != null) 'due_date': dueDate,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoneyLedgerCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? personId,
    Value<LedgerDirection>? direction,
    Value<int>? principalPaise,
    Value<DateTime>? entryDate,
    Value<DateTime?>? dueDate,
    Value<PaymentMethod>? paymentMethod,
    Value<String>? description,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return MoneyLedgerCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      personId: personId ?? this.personId,
      direction: direction ?? this.direction,
      principalPaise: principalPaise ?? this.principalPaise,
      entryDate: entryDate ?? this.entryDate,
      dueDate: dueDate ?? this.dueDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $MoneyLedgerTable.$converterdirection.toSql(direction.value),
      );
    }
    if (principalPaise.present) {
      map['principal_paise'] = Variable<int>(principalPaise.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        $MoneyLedgerTable.$converterpaymentMethod.toSql(paymentMethod.value),
      );
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyLedgerCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('direction: $direction, ')
          ..write('principalPaise: $principalPaise, ')
          ..write('entryDate: $entryDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoneySettlementsTable extends MoneySettlements
    with TableInfo<$MoneySettlementsTable, LedgerRepaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoneySettlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES money_ledger (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(amountPaise).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settledOnMeta = const VerificationMeta(
    'settledOn',
  );
  @override
  late final GeneratedColumn<DateTime> settledOn = GeneratedColumn<DateTime>(
    'settled_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String>
  paymentMethod =
      GeneratedColumn<String>(
        'payment_method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentMethod>(
        $MoneySettlementsTable.$converterpaymentMethod,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    ledgerId,
    amountPaise,
    settledOn,
    paymentMethod,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_settlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerRepaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('settled_on')) {
      context.handle(
        _settledOnMeta,
        settledOn.isAcceptableOrUnknown(data['settled_on']!, _settledOnMeta),
      );
    } else if (isInserting) {
      context.missing(_settledOnMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerRepaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerRepaymentRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      settledOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settled_on'],
      )!,
      paymentMethod: $MoneySettlementsTable.$converterpaymentMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_method'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $MoneySettlementsTable createAlias(String alias) {
    return $MoneySettlementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMethod, String, String>
  $converterpaymentMethod = const EnumNameConverter<PaymentMethod>(
    PaymentMethod.values,
  );
}

class LedgerRepaymentRow extends DataClass
    implements Insertable<LedgerRepaymentRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final String ledgerId;
  final int amountPaise;
  final DateTime settledOn;
  final PaymentMethod paymentMethod;
  final String? notes;
  const LedgerRepaymentRow({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.ledgerId,
    required this.amountPaise,
    required this.settledOn,
    required this.paymentMethod,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['ledger_id'] = Variable<String>(ledgerId);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['settled_on'] = Variable<DateTime>(settledOn);
    {
      map['payment_method'] = Variable<String>(
        $MoneySettlementsTable.$converterpaymentMethod.toSql(paymentMethod),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  MoneySettlementsCompanion toCompanion(bool nullToAbsent) {
    return MoneySettlementsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      ledgerId: Value(ledgerId),
      amountPaise: Value(amountPaise),
      settledOn: Value(settledOn),
      paymentMethod: Value(paymentMethod),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LedgerRepaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerRepaymentRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      ledgerId: serializer.fromJson<String>(json['ledgerId']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      settledOn: serializer.fromJson<DateTime>(json['settledOn']),
      paymentMethod: $MoneySettlementsTable.$converterpaymentMethod.fromJson(
        serializer.fromJson<String>(json['paymentMethod']),
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'ledgerId': serializer.toJson<String>(ledgerId),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'settledOn': serializer.toJson<DateTime>(settledOn),
      'paymentMethod': serializer.toJson<String>(
        $MoneySettlementsTable.$converterpaymentMethod.toJson(paymentMethod),
      ),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LedgerRepaymentRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    String? ledgerId,
    int? amountPaise,
    DateTime? settledOn,
    PaymentMethod? paymentMethod,
    Value<String?> notes = const Value.absent(),
  }) => LedgerRepaymentRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    ledgerId: ledgerId ?? this.ledgerId,
    amountPaise: amountPaise ?? this.amountPaise,
    settledOn: settledOn ?? this.settledOn,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    notes: notes.present ? notes.value : this.notes,
  );
  LedgerRepaymentRow copyWithCompanion(MoneySettlementsCompanion data) {
    return LedgerRepaymentRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      settledOn: data.settledOn.present ? data.settledOn.value : this.settledOn,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerRepaymentRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('settledOn: $settledOn, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    ledgerId,
    amountPaise,
    settledOn,
    paymentMethod,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerRepaymentRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.ledgerId == this.ledgerId &&
          other.amountPaise == this.amountPaise &&
          other.settledOn == this.settledOn &&
          other.paymentMethod == this.paymentMethod &&
          other.notes == this.notes);
}

class MoneySettlementsCompanion extends UpdateCompanion<LedgerRepaymentRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> ledgerId;
  final Value<int> amountPaise;
  final Value<DateTime> settledOn;
  final Value<PaymentMethod> paymentMethod;
  final Value<String?> notes;
  final Value<int> rowid;
  const MoneySettlementsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.settledOn = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoneySettlementsCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    required String id,
    required String ledgerId,
    required int amountPaise,
    required DateTime settledOn,
    required PaymentMethod paymentMethod,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       ledgerId = Value(ledgerId),
       amountPaise = Value(amountPaise),
       settledOn = Value(settledOn),
       paymentMethod = Value(paymentMethod);
  static Insertable<LedgerRepaymentRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? ledgerId,
    Expression<int>? amountPaise,
    Expression<DateTime>? settledOn,
    Expression<String>? paymentMethod,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (settledOn != null) 'settled_on': settledOn,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoneySettlementsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? ledgerId,
    Value<int>? amountPaise,
    Value<DateTime>? settledOn,
    Value<PaymentMethod>? paymentMethod,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return MoneySettlementsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      ledgerId: ledgerId ?? this.ledgerId,
      amountPaise: amountPaise ?? this.amountPaise,
      settledOn: settledOn ?? this.settledOn,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (settledOn.present) {
      map['settled_on'] = Variable<DateTime>(settledOn.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        $MoneySettlementsTable.$converterpaymentMethod.toSql(
          paymentMethod.value,
        ),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneySettlementsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('settledOn: $settledOn, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsCacheTable extends GroupsCache
    with TableInfo<$GroupsCacheTable, GroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>($GroupsCacheTable.$convertersyncState);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GroupType, String> groupType =
      GeneratedColumn<String>(
        'group_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GroupType>($GroupsCacheTable.$convertergroupType);
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<GroupStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('active'),
      ).withConverter<GroupStatus>($GroupsCacheTable.$converterstatus);
  static const VerificationMeta _isSharedMeta = const VerificationMeta(
    'isShared',
  );
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
    'is_shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    revision,
    syncState,
    deletedAt,
    id,
    name,
    description,
    groupType,
    createdBy,
    currency,
    status,
    isShared,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('is_shared')) {
      context.handle(
        _isSharedMeta,
        isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      syncState: $GroupsCacheTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      groupType: $GroupsCacheTable.$convertergroupType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}group_type'],
        )!,
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      status: $GroupsCacheTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      isShared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared'],
      )!,
    );
  }

  @override
  $GroupsCacheTable createAlias(String alias) {
    return $GroupsCacheTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<GroupType, String, String> $convertergroupType =
      const EnumNameConverter<GroupType>(GroupType.values);
  static JsonTypeConverter2<GroupStatus, String, String> $converterstatus =
      const EnumNameConverter<GroupStatus>(GroupStatus.values);
}

class GroupRow extends DataClass implements Insertable<GroupRow> {
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Server revision this local row is based on (0 = never synced).
  final int revision;
  final SyncState syncState;
  final DateTime? deletedAt;
  final String id;
  final String name;
  final String? description;
  final GroupType groupType;

  /// Local member id (or Supabase user id for shared groups) of the creator.
  final String createdBy;
  final String currency;
  final GroupStatus status;

  /// True once the owner shared the group to the cloud (TD-06).
  final bool isShared;
  const GroupRow({
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
    required this.syncState,
    this.deletedAt,
    required this.id,
    required this.name,
    this.description,
    required this.groupType,
    required this.createdBy,
    required this.currency,
    required this.status,
    required this.isShared,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['revision'] = Variable<int>(revision);
    {
      map['sync_state'] = Variable<String>(
        $GroupsCacheTable.$convertersyncState.toSql(syncState),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    {
      map['group_type'] = Variable<String>(
        $GroupsCacheTable.$convertergroupType.toSql(groupType),
      );
    }
    map['created_by'] = Variable<String>(createdBy);
    map['currency'] = Variable<String>(currency);
    {
      map['status'] = Variable<String>(
        $GroupsCacheTable.$converterstatus.toSql(status),
      );
    }
    map['is_shared'] = Variable<bool>(isShared);
    return map;
  }

  GroupsCacheCompanion toCompanion(bool nullToAbsent) {
    return GroupsCacheCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
      syncState: Value(syncState),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      groupType: Value(groupType),
      createdBy: Value(createdBy),
      currency: Value(currency),
      status: Value(status),
      isShared: Value(isShared),
    );
  }

  factory GroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      syncState: $GroupsCacheTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      groupType: $GroupsCacheTable.$convertergroupType.fromJson(
        serializer.fromJson<String>(json['groupType']),
      ),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      currency: serializer.fromJson<String>(json['currency']),
      status: $GroupsCacheTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      isShared: serializer.fromJson<bool>(json['isShared']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'revision': serializer.toJson<int>(revision),
      'syncState': serializer.toJson<String>(
        $GroupsCacheTable.$convertersyncState.toJson(syncState),
      ),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'groupType': serializer.toJson<String>(
        $GroupsCacheTable.$convertergroupType.toJson(groupType),
      ),
      'createdBy': serializer.toJson<String>(createdBy),
      'currency': serializer.toJson<String>(currency),
      'status': serializer.toJson<String>(
        $GroupsCacheTable.$converterstatus.toJson(status),
      ),
      'isShared': serializer.toJson<bool>(isShared),
    };
  }

  GroupRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    int? revision,
    SyncState? syncState,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    GroupType? groupType,
    String? createdBy,
    String? currency,
    GroupStatus? status,
    bool? isShared,
  }) => GroupRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
    syncState: syncState ?? this.syncState,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    groupType: groupType ?? this.groupType,
    createdBy: createdBy ?? this.createdBy,
    currency: currency ?? this.currency,
    status: status ?? this.status,
    isShared: isShared ?? this.isShared,
  );
  GroupRow copyWithCompanion(GroupsCacheCompanion data) {
    return GroupRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      groupType: data.groupType.present ? data.groupType.value : this.groupType,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      currency: data.currency.present ? data.currency.value : this.currency,
      status: data.status.present ? data.status.value : this.status,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('groupType: $groupType, ')
          ..write('createdBy: $createdBy, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('isShared: $isShared')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    revision,
    syncState,
    deletedAt,
    id,
    name,
    description,
    groupType,
    createdBy,
    currency,
    status,
    isShared,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision &&
          other.syncState == this.syncState &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.groupType == this.groupType &&
          other.createdBy == this.createdBy &&
          other.currency == this.currency &&
          other.status == this.status &&
          other.isShared == this.isShared);
}

class GroupsCacheCompanion extends UpdateCompanion<GroupRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> revision;
  final Value<SyncState> syncState;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<GroupType> groupType;
  final Value<String> createdBy;
  final Value<String> currency;
  final Value<GroupStatus> status;
  final Value<bool> isShared;
  final Value<int> rowid;
  const GroupsCacheCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.groupType = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.isShared = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCacheCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String name,
    this.description = const Value.absent(),
    required GroupType groupType,
    required String createdBy,
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.isShared = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       groupType = Value(groupType),
       createdBy = Value(createdBy);
  static Insertable<GroupRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? revision,
    Expression<String>? syncState,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? groupType,
    Expression<String>? createdBy,
    Expression<String>? currency,
    Expression<String>? status,
    Expression<bool>? isShared,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (syncState != null) 'sync_state': syncState,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (groupType != null) 'group_type': groupType,
      if (createdBy != null) 'created_by': createdBy,
      if (currency != null) 'currency': currency,
      if (status != null) 'status': status,
      if (isShared != null) 'is_shared': isShared,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCacheCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? revision,
    Value<SyncState>? syncState,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<GroupType>? groupType,
    Value<String>? createdBy,
    Value<String>? currency,
    Value<GroupStatus>? status,
    Value<bool>? isShared,
    Value<int>? rowid,
  }) {
    return GroupsCacheCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      syncState: syncState ?? this.syncState,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      groupType: groupType ?? this.groupType,
      createdBy: createdBy ?? this.createdBy,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      isShared: isShared ?? this.isShared,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $GroupsCacheTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (groupType.present) {
      map['group_type'] = Variable<String>(
        $GroupsCacheTable.$convertergroupType.toSql(groupType.value),
      );
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $GroupsCacheTable.$converterstatus.toSql(status.value),
      );
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCacheCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('groupType: $groupType, ')
          ..write('createdBy: $createdBy, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('isShared: $isShared, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersCacheTable extends GroupMembersCache
    with TableInfo<$GroupMembersCacheTable, GroupMemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>($GroupMembersCacheTable.$convertersyncState);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES groups_cache (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MemberRole, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('member'),
      ).withConverter<MemberRole>($GroupMembersCacheTable.$converterrole);
  @override
  late final GeneratedColumnWithTypeConverter<MemberStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('active'),
      ).withConverter<MemberStatus>($GroupMembersCacheTable.$converterstatus);
  static const VerificationMeta _isSelfMeta = const VerificationMeta('isSelf');
  @override
  late final GeneratedColumn<bool> isSelf = GeneratedColumn<bool>(
    'is_self',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_self" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    revision,
    syncState,
    deletedAt,
    id,
    groupId,
    userId,
    displayName,
    phone,
    personId,
    role,
    status,
    isSelf,
    joinedAt,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupMemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('is_self')) {
      context.handle(
        _isSelfMeta,
        isSelf.isAcceptableOrUnknown(data['is_self']!, _isSelfMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupMemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMemberRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      syncState: $GroupMembersCacheTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      ),
      role: $GroupMembersCacheTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
      status: $GroupMembersCacheTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      isSelf: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_self'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $GroupMembersCacheTable createAlias(String alias) {
    return $GroupMembersCacheTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<MemberRole, String, String> $converterrole =
      const EnumNameConverter<MemberRole>(MemberRole.values);
  static JsonTypeConverter2<MemberStatus, String, String> $converterstatus =
      const EnumNameConverter<MemberStatus>(MemberStatus.values);
}

class GroupMemberRow extends DataClass implements Insertable<GroupMemberRow> {
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Server revision this local row is based on (0 = never synced).
  final int revision;
  final SyncState syncState;
  final DateTime? deletedAt;
  final String id;
  final String groupId;

  /// Supabase auth user id for authenticated members; null for local-only
  /// participants (who never get cloud access).
  final String? userId;
  final String displayName;
  final String? phone;
  final String? personId;
  final MemberRole role;
  final MemberStatus status;

  /// The member representing the device owner.
  final bool isSelf;
  final DateTime joinedAt;

  /// Stable display order — also used for deterministic remainder
  /// distribution in splits.
  final int sortOrder;
  const GroupMemberRow({
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
    required this.syncState,
    this.deletedAt,
    required this.id,
    required this.groupId,
    this.userId,
    required this.displayName,
    this.phone,
    this.personId,
    required this.role,
    required this.status,
    required this.isSelf,
    required this.joinedAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['revision'] = Variable<int>(revision);
    {
      map['sync_state'] = Variable<String>(
        $GroupMembersCacheTable.$convertersyncState.toSql(syncState),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    {
      map['role'] = Variable<String>(
        $GroupMembersCacheTable.$converterrole.toSql(role),
      );
    }
    {
      map['status'] = Variable<String>(
        $GroupMembersCacheTable.$converterstatus.toSql(status),
      );
    }
    map['is_self'] = Variable<bool>(isSelf);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  GroupMembersCacheCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCacheCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
      syncState: Value(syncState),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      groupId: Value(groupId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      displayName: Value(displayName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      role: Value(role),
      status: Value(status),
      isSelf: Value(isSelf),
      joinedAt: Value(joinedAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory GroupMemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMemberRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      syncState: $GroupMembersCacheTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      userId: serializer.fromJson<String?>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      phone: serializer.fromJson<String?>(json['phone']),
      personId: serializer.fromJson<String?>(json['personId']),
      role: $GroupMembersCacheTable.$converterrole.fromJson(
        serializer.fromJson<String>(json['role']),
      ),
      status: $GroupMembersCacheTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      isSelf: serializer.fromJson<bool>(json['isSelf']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'revision': serializer.toJson<int>(revision),
      'syncState': serializer.toJson<String>(
        $GroupMembersCacheTable.$convertersyncState.toJson(syncState),
      ),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'userId': serializer.toJson<String?>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'phone': serializer.toJson<String?>(phone),
      'personId': serializer.toJson<String?>(personId),
      'role': serializer.toJson<String>(
        $GroupMembersCacheTable.$converterrole.toJson(role),
      ),
      'status': serializer.toJson<String>(
        $GroupMembersCacheTable.$converterstatus.toJson(status),
      ),
      'isSelf': serializer.toJson<bool>(isSelf),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  GroupMemberRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    int? revision,
    SyncState? syncState,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? groupId,
    Value<String?> userId = const Value.absent(),
    String? displayName,
    Value<String?> phone = const Value.absent(),
    Value<String?> personId = const Value.absent(),
    MemberRole? role,
    MemberStatus? status,
    bool? isSelf,
    DateTime? joinedAt,
    int? sortOrder,
  }) => GroupMemberRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
    syncState: syncState ?? this.syncState,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    userId: userId.present ? userId.value : this.userId,
    displayName: displayName ?? this.displayName,
    phone: phone.present ? phone.value : this.phone,
    personId: personId.present ? personId.value : this.personId,
    role: role ?? this.role,
    status: status ?? this.status,
    isSelf: isSelf ?? this.isSelf,
    joinedAt: joinedAt ?? this.joinedAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  GroupMemberRow copyWithCompanion(GroupMembersCacheCompanion data) {
    return GroupMemberRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      phone: data.phone.present ? data.phone.value : this.phone,
      personId: data.personId.present ? data.personId.value : this.personId,
      role: data.role.present ? data.role.value : this.role,
      status: data.status.present ? data.status.value : this.status,
      isSelf: data.isSelf.present ? data.isSelf.value : this.isSelf,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMemberRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('phone: $phone, ')
          ..write('personId: $personId, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('isSelf: $isSelf, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    revision,
    syncState,
    deletedAt,
    id,
    groupId,
    userId,
    displayName,
    phone,
    personId,
    role,
    status,
    isSelf,
    joinedAt,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMemberRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision &&
          other.syncState == this.syncState &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.phone == this.phone &&
          other.personId == this.personId &&
          other.role == this.role &&
          other.status == this.status &&
          other.isSelf == this.isSelf &&
          other.joinedAt == this.joinedAt &&
          other.sortOrder == this.sortOrder);
}

class GroupMembersCacheCompanion extends UpdateCompanion<GroupMemberRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> revision;
  final Value<SyncState> syncState;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> groupId;
  final Value<String?> userId;
  final Value<String> displayName;
  final Value<String?> phone;
  final Value<String?> personId;
  final Value<MemberRole> role;
  final Value<MemberStatus> status;
  final Value<bool> isSelf;
  final Value<DateTime> joinedAt;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const GroupMembersCacheCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.phone = const Value.absent(),
    this.personId = const Value.absent(),
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.isSelf = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupMembersCacheCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String groupId,
    this.userId = const Value.absent(),
    required String displayName,
    this.phone = const Value.absent(),
    this.personId = const Value.absent(),
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.isSelf = const Value.absent(),
    required DateTime joinedAt,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       groupId = Value(groupId),
       displayName = Value(displayName),
       joinedAt = Value(joinedAt);
  static Insertable<GroupMemberRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? revision,
    Expression<String>? syncState,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<String>? phone,
    Expression<String>? personId,
    Expression<String>? role,
    Expression<String>? status,
    Expression<bool>? isSelf,
    Expression<DateTime>? joinedAt,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (syncState != null) 'sync_state': syncState,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (phone != null) 'phone': phone,
      if (personId != null) 'person_id': personId,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (isSelf != null) 'is_self': isSelf,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupMembersCacheCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? revision,
    Value<SyncState>? syncState,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? groupId,
    Value<String?>? userId,
    Value<String>? displayName,
    Value<String?>? phone,
    Value<String?>? personId,
    Value<MemberRole>? role,
    Value<MemberStatus>? status,
    Value<bool>? isSelf,
    Value<DateTime>? joinedAt,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return GroupMembersCacheCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      syncState: syncState ?? this.syncState,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      personId: personId ?? this.personId,
      role: role ?? this.role,
      status: status ?? this.status,
      isSelf: isSelf ?? this.isSelf,
      joinedAt: joinedAt ?? this.joinedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $GroupMembersCacheTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $GroupMembersCacheTable.$converterrole.toSql(role.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $GroupMembersCacheTable.$converterstatus.toSql(status.value),
      );
    }
    if (isSelf.present) {
      map['is_self'] = Variable<bool>(isSelf.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCacheCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('phone: $phone, ')
          ..write('personId: $personId, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('isSelf: $isSelf, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupExpensesCacheTable extends GroupExpensesCache
    with TableInfo<$GroupExpensesCacheTable, GroupExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupExpensesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>($GroupExpensesCacheTable.$convertersyncState);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES groups_cache (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryKeyMeta = const VerificationMeta(
    'categoryKey',
  );
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
    'category_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(amountPaise).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidByMemberIdMeta = const VerificationMeta(
    'paidByMemberId',
  );
  @override
  late final GeneratedColumn<String> paidByMemberId = GeneratedColumn<String>(
    'paid_by_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_members_cache (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _expenseDateMeta = const VerificationMeta(
    'expenseDate',
  );
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
    'expense_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SplitMethod, String> splitMethod =
      GeneratedColumn<String>(
        'split_method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SplitMethod>(
        $GroupExpensesCacheTable.$convertersplitMethod,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    revision,
    syncState,
    deletedAt,
    id,
    groupId,
    description,
    categoryKey,
    amountPaise,
    paidByMemberId,
    expenseDate,
    splitMethod,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_expenses_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category_key')) {
      context.handle(
        _categoryKeyMeta,
        categoryKey.isAcceptableOrUnknown(
          data['category_key']!,
          _categoryKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryKeyMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('paid_by_member_id')) {
      context.handle(
        _paidByMemberIdMeta,
        paidByMemberId.isAcceptableOrUnknown(
          data['paid_by_member_id']!,
          _paidByMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paidByMemberIdMeta);
    }
    if (data.containsKey('expense_date')) {
      context.handle(
        _expenseDateMeta,
        expenseDate.isAcceptableOrUnknown(
          data['expense_date']!,
          _expenseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupExpenseRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      syncState: $GroupExpensesCacheTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      categoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_key'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      paidByMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_by_member_id'],
      )!,
      expenseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expense_date'],
      )!,
      splitMethod: $GroupExpensesCacheTable.$convertersplitMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}split_method'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $GroupExpensesCacheTable createAlias(String alias) {
    return $GroupExpensesCacheTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<SplitMethod, String, String> $convertersplitMethod =
      const EnumNameConverter<SplitMethod>(SplitMethod.values);
}

class GroupExpenseRow extends DataClass implements Insertable<GroupExpenseRow> {
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Server revision this local row is based on (0 = never synced).
  final int revision;
  final SyncState syncState;
  final DateTime? deletedAt;
  final String id;
  final String groupId;
  final String description;

  /// Category key from the group category list (food, travel, stay, …).
  final String categoryKey;
  final int amountPaise;
  final String paidByMemberId;
  final DateTime expenseDate;
  final SplitMethod splitMethod;
  final String? notes;
  const GroupExpenseRow({
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
    required this.syncState,
    this.deletedAt,
    required this.id,
    required this.groupId,
    required this.description,
    required this.categoryKey,
    required this.amountPaise,
    required this.paidByMemberId,
    required this.expenseDate,
    required this.splitMethod,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['revision'] = Variable<int>(revision);
    {
      map['sync_state'] = Variable<String>(
        $GroupExpensesCacheTable.$convertersyncState.toSql(syncState),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['description'] = Variable<String>(description);
    map['category_key'] = Variable<String>(categoryKey);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['paid_by_member_id'] = Variable<String>(paidByMemberId);
    map['expense_date'] = Variable<DateTime>(expenseDate);
    {
      map['split_method'] = Variable<String>(
        $GroupExpensesCacheTable.$convertersplitMethod.toSql(splitMethod),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  GroupExpensesCacheCompanion toCompanion(bool nullToAbsent) {
    return GroupExpensesCacheCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
      syncState: Value(syncState),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      groupId: Value(groupId),
      description: Value(description),
      categoryKey: Value(categoryKey),
      amountPaise: Value(amountPaise),
      paidByMemberId: Value(paidByMemberId),
      expenseDate: Value(expenseDate),
      splitMethod: Value(splitMethod),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory GroupExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupExpenseRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      syncState: $GroupExpensesCacheTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      description: serializer.fromJson<String>(json['description']),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      paidByMemberId: serializer.fromJson<String>(json['paidByMemberId']),
      expenseDate: serializer.fromJson<DateTime>(json['expenseDate']),
      splitMethod: $GroupExpensesCacheTable.$convertersplitMethod.fromJson(
        serializer.fromJson<String>(json['splitMethod']),
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'revision': serializer.toJson<int>(revision),
      'syncState': serializer.toJson<String>(
        $GroupExpensesCacheTable.$convertersyncState.toJson(syncState),
      ),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'description': serializer.toJson<String>(description),
      'categoryKey': serializer.toJson<String>(categoryKey),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'paidByMemberId': serializer.toJson<String>(paidByMemberId),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'splitMethod': serializer.toJson<String>(
        $GroupExpensesCacheTable.$convertersplitMethod.toJson(splitMethod),
      ),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  GroupExpenseRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    int? revision,
    SyncState? syncState,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? groupId,
    String? description,
    String? categoryKey,
    int? amountPaise,
    String? paidByMemberId,
    DateTime? expenseDate,
    SplitMethod? splitMethod,
    Value<String?> notes = const Value.absent(),
  }) => GroupExpenseRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
    syncState: syncState ?? this.syncState,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    description: description ?? this.description,
    categoryKey: categoryKey ?? this.categoryKey,
    amountPaise: amountPaise ?? this.amountPaise,
    paidByMemberId: paidByMemberId ?? this.paidByMemberId,
    expenseDate: expenseDate ?? this.expenseDate,
    splitMethod: splitMethod ?? this.splitMethod,
    notes: notes.present ? notes.value : this.notes,
  );
  GroupExpenseRow copyWithCompanion(GroupExpensesCacheCompanion data) {
    return GroupExpenseRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryKey: data.categoryKey.present
          ? data.categoryKey.value
          : this.categoryKey,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      paidByMemberId: data.paidByMemberId.present
          ? data.paidByMemberId.value
          : this.paidByMemberId,
      expenseDate: data.expenseDate.present
          ? data.expenseDate.value
          : this.expenseDate,
      splitMethod: data.splitMethod.present
          ? data.splitMethod.value
          : this.splitMethod,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupExpenseRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('description: $description, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('paidByMemberId: $paidByMemberId, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('splitMethod: $splitMethod, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    revision,
    syncState,
    deletedAt,
    id,
    groupId,
    description,
    categoryKey,
    amountPaise,
    paidByMemberId,
    expenseDate,
    splitMethod,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupExpenseRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision &&
          other.syncState == this.syncState &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.description == this.description &&
          other.categoryKey == this.categoryKey &&
          other.amountPaise == this.amountPaise &&
          other.paidByMemberId == this.paidByMemberId &&
          other.expenseDate == this.expenseDate &&
          other.splitMethod == this.splitMethod &&
          other.notes == this.notes);
}

class GroupExpensesCacheCompanion extends UpdateCompanion<GroupExpenseRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> revision;
  final Value<SyncState> syncState;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> description;
  final Value<String> categoryKey;
  final Value<int> amountPaise;
  final Value<String> paidByMemberId;
  final Value<DateTime> expenseDate;
  final Value<SplitMethod> splitMethod;
  final Value<String?> notes;
  final Value<int> rowid;
  const GroupExpensesCacheCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.paidByMemberId = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.splitMethod = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupExpensesCacheCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String groupId,
    required String description,
    required String categoryKey,
    required int amountPaise,
    required String paidByMemberId,
    required DateTime expenseDate,
    required SplitMethod splitMethod,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       groupId = Value(groupId),
       description = Value(description),
       categoryKey = Value(categoryKey),
       amountPaise = Value(amountPaise),
       paidByMemberId = Value(paidByMemberId),
       expenseDate = Value(expenseDate),
       splitMethod = Value(splitMethod);
  static Insertable<GroupExpenseRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? revision,
    Expression<String>? syncState,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? description,
    Expression<String>? categoryKey,
    Expression<int>? amountPaise,
    Expression<String>? paidByMemberId,
    Expression<DateTime>? expenseDate,
    Expression<String>? splitMethod,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (syncState != null) 'sync_state': syncState,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (description != null) 'description': description,
      if (categoryKey != null) 'category_key': categoryKey,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (paidByMemberId != null) 'paid_by_member_id': paidByMemberId,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (splitMethod != null) 'split_method': splitMethod,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupExpensesCacheCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? revision,
    Value<SyncState>? syncState,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? description,
    Value<String>? categoryKey,
    Value<int>? amountPaise,
    Value<String>? paidByMemberId,
    Value<DateTime>? expenseDate,
    Value<SplitMethod>? splitMethod,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return GroupExpensesCacheCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      syncState: syncState ?? this.syncState,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      description: description ?? this.description,
      categoryKey: categoryKey ?? this.categoryKey,
      amountPaise: amountPaise ?? this.amountPaise,
      paidByMemberId: paidByMemberId ?? this.paidByMemberId,
      expenseDate: expenseDate ?? this.expenseDate,
      splitMethod: splitMethod ?? this.splitMethod,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $GroupExpensesCacheTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (paidByMemberId.present) {
      map['paid_by_member_id'] = Variable<String>(paidByMemberId.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<DateTime>(expenseDate.value);
    }
    if (splitMethod.present) {
      map['split_method'] = Variable<String>(
        $GroupExpensesCacheTable.$convertersplitMethod.toSql(splitMethod.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupExpensesCacheCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('description: $description, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('paidByMemberId: $paidByMemberId, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('splitMethod: $splitMethod, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupExpenseSplitsCacheTable extends GroupExpenseSplitsCache
    with TableInfo<$GroupExpenseSplitsCacheTable, GroupSplitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupExpenseSplitsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_expenses_cache (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_members_cache (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _sharePaiseMeta = const VerificationMeta(
    'sharePaise',
  );
  @override
  late final GeneratedColumn<int> sharePaise = GeneratedColumn<int>(
    'share_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(sharePaise).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputValueMeta = const VerificationMeta(
    'inputValue',
  );
  @override
  late final GeneratedColumn<int> inputValue = GeneratedColumn<int>(
    'input_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    expenseId,
    memberId,
    sharePaise,
    inputValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_expense_splits_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupSplitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('share_paise')) {
      context.handle(
        _sharePaiseMeta,
        sharePaise.isAcceptableOrUnknown(data['share_paise']!, _sharePaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_sharePaiseMeta);
    }
    if (data.containsKey('input_value')) {
      context.handle(
        _inputValueMeta,
        inputValue.isAcceptableOrUnknown(data['input_value']!, _inputValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {expenseId, memberId},
  ];
  @override
  GroupSplitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupSplitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      sharePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}share_paise'],
      )!,
      inputValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}input_value'],
      ),
    );
  }

  @override
  $GroupExpenseSplitsCacheTable createAlias(String alias) {
    return $GroupExpenseSplitsCacheTable(attachedDatabase, alias);
  }
}

class GroupSplitRow extends DataClass implements Insertable<GroupSplitRow> {
  final String id;
  final String expenseId;
  final String memberId;
  final int sharePaise;

  /// Raw user input for the split method: exact paise, basis points, weight
  /// or adjustment paise. Kept so the split can be edited faithfully.
  final int? inputValue;
  const GroupSplitRow({
    required this.id,
    required this.expenseId,
    required this.memberId,
    required this.sharePaise,
    this.inputValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['expense_id'] = Variable<String>(expenseId);
    map['member_id'] = Variable<String>(memberId);
    map['share_paise'] = Variable<int>(sharePaise);
    if (!nullToAbsent || inputValue != null) {
      map['input_value'] = Variable<int>(inputValue);
    }
    return map;
  }

  GroupExpenseSplitsCacheCompanion toCompanion(bool nullToAbsent) {
    return GroupExpenseSplitsCacheCompanion(
      id: Value(id),
      expenseId: Value(expenseId),
      memberId: Value(memberId),
      sharePaise: Value(sharePaise),
      inputValue: inputValue == null && nullToAbsent
          ? const Value.absent()
          : Value(inputValue),
    );
  }

  factory GroupSplitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupSplitRow(
      id: serializer.fromJson<String>(json['id']),
      expenseId: serializer.fromJson<String>(json['expenseId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      sharePaise: serializer.fromJson<int>(json['sharePaise']),
      inputValue: serializer.fromJson<int?>(json['inputValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'expenseId': serializer.toJson<String>(expenseId),
      'memberId': serializer.toJson<String>(memberId),
      'sharePaise': serializer.toJson<int>(sharePaise),
      'inputValue': serializer.toJson<int?>(inputValue),
    };
  }

  GroupSplitRow copyWith({
    String? id,
    String? expenseId,
    String? memberId,
    int? sharePaise,
    Value<int?> inputValue = const Value.absent(),
  }) => GroupSplitRow(
    id: id ?? this.id,
    expenseId: expenseId ?? this.expenseId,
    memberId: memberId ?? this.memberId,
    sharePaise: sharePaise ?? this.sharePaise,
    inputValue: inputValue.present ? inputValue.value : this.inputValue,
  );
  GroupSplitRow copyWithCompanion(GroupExpenseSplitsCacheCompanion data) {
    return GroupSplitRow(
      id: data.id.present ? data.id.value : this.id,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      sharePaise: data.sharePaise.present
          ? data.sharePaise.value
          : this.sharePaise,
      inputValue: data.inputValue.present
          ? data.inputValue.value
          : this.inputValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupSplitRow(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('memberId: $memberId, ')
          ..write('sharePaise: $sharePaise, ')
          ..write('inputValue: $inputValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, expenseId, memberId, sharePaise, inputValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupSplitRow &&
          other.id == this.id &&
          other.expenseId == this.expenseId &&
          other.memberId == this.memberId &&
          other.sharePaise == this.sharePaise &&
          other.inputValue == this.inputValue);
}

class GroupExpenseSplitsCacheCompanion extends UpdateCompanion<GroupSplitRow> {
  final Value<String> id;
  final Value<String> expenseId;
  final Value<String> memberId;
  final Value<int> sharePaise;
  final Value<int?> inputValue;
  final Value<int> rowid;
  const GroupExpenseSplitsCacheCompanion({
    this.id = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.sharePaise = const Value.absent(),
    this.inputValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupExpenseSplitsCacheCompanion.insert({
    required String id,
    required String expenseId,
    required String memberId,
    required int sharePaise,
    this.inputValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       expenseId = Value(expenseId),
       memberId = Value(memberId),
       sharePaise = Value(sharePaise);
  static Insertable<GroupSplitRow> custom({
    Expression<String>? id,
    Expression<String>? expenseId,
    Expression<String>? memberId,
    Expression<int>? sharePaise,
    Expression<int>? inputValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (expenseId != null) 'expense_id': expenseId,
      if (memberId != null) 'member_id': memberId,
      if (sharePaise != null) 'share_paise': sharePaise,
      if (inputValue != null) 'input_value': inputValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupExpenseSplitsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? expenseId,
    Value<String>? memberId,
    Value<int>? sharePaise,
    Value<int?>? inputValue,
    Value<int>? rowid,
  }) {
    return GroupExpenseSplitsCacheCompanion(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      memberId: memberId ?? this.memberId,
      sharePaise: sharePaise ?? this.sharePaise,
      inputValue: inputValue ?? this.inputValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (sharePaise.present) {
      map['share_paise'] = Variable<int>(sharePaise.value);
    }
    if (inputValue.present) {
      map['input_value'] = Variable<int>(inputValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupExpenseSplitsCacheCompanion(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('memberId: $memberId, ')
          ..write('sharePaise: $sharePaise, ')
          ..write('inputValue: $inputValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupSettlementsCacheTable extends GroupSettlementsCache
    with TableInfo<$GroupSettlementsCacheTable, GroupSettlementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupSettlementsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>(
        $GroupSettlementsCacheTable.$convertersyncState,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES groups_cache (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fromMemberIdMeta = const VerificationMeta(
    'fromMemberId',
  );
  @override
  late final GeneratedColumn<String> fromMemberId = GeneratedColumn<String>(
    'from_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_members_cache (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _toMemberIdMeta = const VerificationMeta(
    'toMemberId',
  );
  @override
  late final GeneratedColumn<String> toMemberId = GeneratedColumn<String>(
    'to_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_members_cache (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(amountPaise).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settledOnMeta = const VerificationMeta(
    'settledOn',
  );
  @override
  late final GeneratedColumn<DateTime> settledOn = GeneratedColumn<DateTime>(
    'settled_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String>
  paymentMethod =
      GeneratedColumn<String>(
        'payment_method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentMethod>(
        $GroupSettlementsCacheTable.$converterpaymentMethod,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    revision,
    syncState,
    deletedAt,
    id,
    groupId,
    fromMemberId,
    toMemberId,
    amountPaise,
    settledOn,
    paymentMethod,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_settlements_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupSettlementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('from_member_id')) {
      context.handle(
        _fromMemberIdMeta,
        fromMemberId.isAcceptableOrUnknown(
          data['from_member_id']!,
          _fromMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromMemberIdMeta);
    }
    if (data.containsKey('to_member_id')) {
      context.handle(
        _toMemberIdMeta,
        toMemberId.isAcceptableOrUnknown(
          data['to_member_id']!,
          _toMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toMemberIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('settled_on')) {
      context.handle(
        _settledOnMeta,
        settledOn.isAcceptableOrUnknown(data['settled_on']!, _settledOnMeta),
      );
    } else if (isInserting) {
      context.missing(_settledOnMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupSettlementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupSettlementRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      syncState: $GroupSettlementsCacheTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      fromMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_member_id'],
      )!,
      toMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_member_id'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      settledOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settled_on'],
      )!,
      paymentMethod: $GroupSettlementsCacheTable.$converterpaymentMethod
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}payment_method'],
            )!,
          ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $GroupSettlementsCacheTable createAlias(String alias) {
    return $GroupSettlementsCacheTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<PaymentMethod, String, String>
  $converterpaymentMethod = const EnumNameConverter<PaymentMethod>(
    PaymentMethod.values,
  );
}

class GroupSettlementRow extends DataClass
    implements Insertable<GroupSettlementRow> {
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Server revision this local row is based on (0 = never synced).
  final int revision;
  final SyncState syncState;
  final DateTime? deletedAt;
  final String id;
  final String groupId;
  final String fromMemberId;
  final String toMemberId;
  final int amountPaise;
  final DateTime settledOn;
  final PaymentMethod paymentMethod;
  final String? notes;
  const GroupSettlementRow({
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
    required this.syncState,
    this.deletedAt,
    required this.id,
    required this.groupId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amountPaise,
    required this.settledOn,
    required this.paymentMethod,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['revision'] = Variable<int>(revision);
    {
      map['sync_state'] = Variable<String>(
        $GroupSettlementsCacheTable.$convertersyncState.toSql(syncState),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['from_member_id'] = Variable<String>(fromMemberId);
    map['to_member_id'] = Variable<String>(toMemberId);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['settled_on'] = Variable<DateTime>(settledOn);
    {
      map['payment_method'] = Variable<String>(
        $GroupSettlementsCacheTable.$converterpaymentMethod.toSql(
          paymentMethod,
        ),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  GroupSettlementsCacheCompanion toCompanion(bool nullToAbsent) {
    return GroupSettlementsCacheCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
      syncState: Value(syncState),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      groupId: Value(groupId),
      fromMemberId: Value(fromMemberId),
      toMemberId: Value(toMemberId),
      amountPaise: Value(amountPaise),
      settledOn: Value(settledOn),
      paymentMethod: Value(paymentMethod),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory GroupSettlementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupSettlementRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      syncState: $GroupSettlementsCacheTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      fromMemberId: serializer.fromJson<String>(json['fromMemberId']),
      toMemberId: serializer.fromJson<String>(json['toMemberId']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      settledOn: serializer.fromJson<DateTime>(json['settledOn']),
      paymentMethod: $GroupSettlementsCacheTable.$converterpaymentMethod
          .fromJson(serializer.fromJson<String>(json['paymentMethod'])),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'revision': serializer.toJson<int>(revision),
      'syncState': serializer.toJson<String>(
        $GroupSettlementsCacheTable.$convertersyncState.toJson(syncState),
      ),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'fromMemberId': serializer.toJson<String>(fromMemberId),
      'toMemberId': serializer.toJson<String>(toMemberId),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'settledOn': serializer.toJson<DateTime>(settledOn),
      'paymentMethod': serializer.toJson<String>(
        $GroupSettlementsCacheTable.$converterpaymentMethod.toJson(
          paymentMethod,
        ),
      ),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  GroupSettlementRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    int? revision,
    SyncState? syncState,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? groupId,
    String? fromMemberId,
    String? toMemberId,
    int? amountPaise,
    DateTime? settledOn,
    PaymentMethod? paymentMethod,
    Value<String?> notes = const Value.absent(),
  }) => GroupSettlementRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
    syncState: syncState ?? this.syncState,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    fromMemberId: fromMemberId ?? this.fromMemberId,
    toMemberId: toMemberId ?? this.toMemberId,
    amountPaise: amountPaise ?? this.amountPaise,
    settledOn: settledOn ?? this.settledOn,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    notes: notes.present ? notes.value : this.notes,
  );
  GroupSettlementRow copyWithCompanion(GroupSettlementsCacheCompanion data) {
    return GroupSettlementRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      fromMemberId: data.fromMemberId.present
          ? data.fromMemberId.value
          : this.fromMemberId,
      toMemberId: data.toMemberId.present
          ? data.toMemberId.value
          : this.toMemberId,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      settledOn: data.settledOn.present ? data.settledOn.value : this.settledOn,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupSettlementRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('fromMemberId: $fromMemberId, ')
          ..write('toMemberId: $toMemberId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('settledOn: $settledOn, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    revision,
    syncState,
    deletedAt,
    id,
    groupId,
    fromMemberId,
    toMemberId,
    amountPaise,
    settledOn,
    paymentMethod,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupSettlementRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision &&
          other.syncState == this.syncState &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.fromMemberId == this.fromMemberId &&
          other.toMemberId == this.toMemberId &&
          other.amountPaise == this.amountPaise &&
          other.settledOn == this.settledOn &&
          other.paymentMethod == this.paymentMethod &&
          other.notes == this.notes);
}

class GroupSettlementsCacheCompanion
    extends UpdateCompanion<GroupSettlementRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> revision;
  final Value<SyncState> syncState;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> fromMemberId;
  final Value<String> toMemberId;
  final Value<int> amountPaise;
  final Value<DateTime> settledOn;
  final Value<PaymentMethod> paymentMethod;
  final Value<String?> notes;
  final Value<int> rowid;
  const GroupSettlementsCacheCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.fromMemberId = const Value.absent(),
    this.toMemberId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.settledOn = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupSettlementsCacheCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String groupId,
    required String fromMemberId,
    required String toMemberId,
    required int amountPaise,
    required DateTime settledOn,
    required PaymentMethod paymentMethod,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       groupId = Value(groupId),
       fromMemberId = Value(fromMemberId),
       toMemberId = Value(toMemberId),
       amountPaise = Value(amountPaise),
       settledOn = Value(settledOn),
       paymentMethod = Value(paymentMethod);
  static Insertable<GroupSettlementRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? revision,
    Expression<String>? syncState,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? fromMemberId,
    Expression<String>? toMemberId,
    Expression<int>? amountPaise,
    Expression<DateTime>? settledOn,
    Expression<String>? paymentMethod,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (syncState != null) 'sync_state': syncState,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (fromMemberId != null) 'from_member_id': fromMemberId,
      if (toMemberId != null) 'to_member_id': toMemberId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (settledOn != null) 'settled_on': settledOn,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupSettlementsCacheCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? revision,
    Value<SyncState>? syncState,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? fromMemberId,
    Value<String>? toMemberId,
    Value<int>? amountPaise,
    Value<DateTime>? settledOn,
    Value<PaymentMethod>? paymentMethod,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return GroupSettlementsCacheCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      syncState: syncState ?? this.syncState,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      fromMemberId: fromMemberId ?? this.fromMemberId,
      toMemberId: toMemberId ?? this.toMemberId,
      amountPaise: amountPaise ?? this.amountPaise,
      settledOn: settledOn ?? this.settledOn,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $GroupSettlementsCacheTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (fromMemberId.present) {
      map['from_member_id'] = Variable<String>(fromMemberId.value);
    }
    if (toMemberId.present) {
      map['to_member_id'] = Variable<String>(toMemberId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (settledOn.present) {
      map['settled_on'] = Variable<DateTime>(settledOn.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        $GroupSettlementsCacheTable.$converterpaymentMethod.toSql(
          paymentMethod.value,
        ),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupSettlementsCacheCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('fromMemberId: $fromMemberId, ')
          ..write('toMemberId: $toMemberId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('settledOn: $settledOn, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ledgerEntryIdMeta = const VerificationMeta(
    'ledgerEntryId',
  );
  @override
  late final GeneratedColumn<String> ledgerEntryId = GeneratedColumn<String>(
    'ledger_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES money_ledger (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _groupExpenseIdMeta = const VerificationMeta(
    'groupExpenseId',
  );
  @override
  late final GeneratedColumn<String> groupExpenseId = GeneratedColumn<String>(
    'group_expense_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_expenses_cache (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _storedNameMeta = const VerificationMeta(
    'storedName',
  );
  @override
  late final GeneratedColumn<String> storedName = GeneratedColumn<String>(
    'stored_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remotePathMeta = const VerificationMeta(
    'remotePath',
  );
  @override
  late final GeneratedColumn<String> remotePath = GeneratedColumn<String>(
    'remote_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    ledgerEntryId,
    groupExpenseId,
    storedName,
    originalName,
    mimeType,
    sizeBytes,
    sha256,
    remotePath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('ledger_entry_id')) {
      context.handle(
        _ledgerEntryIdMeta,
        ledgerEntryId.isAcceptableOrUnknown(
          data['ledger_entry_id']!,
          _ledgerEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('group_expense_id')) {
      context.handle(
        _groupExpenseIdMeta,
        groupExpenseId.isAcceptableOrUnknown(
          data['group_expense_id']!,
          _groupExpenseIdMeta,
        ),
      );
    }
    if (data.containsKey('stored_name')) {
      context.handle(
        _storedNameMeta,
        storedName.isAcceptableOrUnknown(data['stored_name']!, _storedNameMeta),
      );
    } else if (isInserting) {
      context.missing(_storedNameMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('remote_path')) {
      context.handle(
        _remotePathMeta,
        remotePath.isAcceptableOrUnknown(data['remote_path']!, _remotePathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      ),
      ledgerEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_entry_id'],
      ),
      groupExpenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_expense_id'],
      ),
      storedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stored_name'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      remotePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final String id;
  final String? transactionId;
  final String? ledgerEntryId;
  final String? groupExpenseId;

  /// Path relative to the app attachments directory.
  final String storedName;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
  final String sha256;
  final String? remotePath;
  final DateTime createdAt;
  const AttachmentRow({
    required this.id,
    this.transactionId,
    this.ledgerEntryId,
    this.groupExpenseId,
    required this.storedName,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
    this.remotePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    if (!nullToAbsent || ledgerEntryId != null) {
      map['ledger_entry_id'] = Variable<String>(ledgerEntryId);
    }
    if (!nullToAbsent || groupExpenseId != null) {
      map['group_expense_id'] = Variable<String>(groupExpenseId);
    }
    map['stored_name'] = Variable<String>(storedName);
    map['original_name'] = Variable<String>(originalName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['sha256'] = Variable<String>(sha256);
    if (!nullToAbsent || remotePath != null) {
      map['remote_path'] = Variable<String>(remotePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      ledgerEntryId: ledgerEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(ledgerEntryId),
      groupExpenseId: groupExpenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupExpenseId),
      storedName: Value(storedName),
      originalName: Value(originalName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      sha256: Value(sha256),
      remotePath: remotePath == null && nullToAbsent
          ? const Value.absent()
          : Value(remotePath),
      createdAt: Value(createdAt),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
      ledgerEntryId: serializer.fromJson<String?>(json['ledgerEntryId']),
      groupExpenseId: serializer.fromJson<String?>(json['groupExpenseId']),
      storedName: serializer.fromJson<String>(json['storedName']),
      originalName: serializer.fromJson<String>(json['originalName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      sha256: serializer.fromJson<String>(json['sha256']),
      remotePath: serializer.fromJson<String?>(json['remotePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String?>(transactionId),
      'ledgerEntryId': serializer.toJson<String?>(ledgerEntryId),
      'groupExpenseId': serializer.toJson<String?>(groupExpenseId),
      'storedName': serializer.toJson<String>(storedName),
      'originalName': serializer.toJson<String>(originalName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'sha256': serializer.toJson<String>(sha256),
      'remotePath': serializer.toJson<String?>(remotePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AttachmentRow copyWith({
    String? id,
    Value<String?> transactionId = const Value.absent(),
    Value<String?> ledgerEntryId = const Value.absent(),
    Value<String?> groupExpenseId = const Value.absent(),
    String? storedName,
    String? originalName,
    String? mimeType,
    int? sizeBytes,
    String? sha256,
    Value<String?> remotePath = const Value.absent(),
    DateTime? createdAt,
  }) => AttachmentRow(
    id: id ?? this.id,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
    ledgerEntryId: ledgerEntryId.present
        ? ledgerEntryId.value
        : this.ledgerEntryId,
    groupExpenseId: groupExpenseId.present
        ? groupExpenseId.value
        : this.groupExpenseId,
    storedName: storedName ?? this.storedName,
    originalName: originalName ?? this.originalName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    sha256: sha256 ?? this.sha256,
    remotePath: remotePath.present ? remotePath.value : this.remotePath,
    createdAt: createdAt ?? this.createdAt,
  );
  AttachmentRow copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      ledgerEntryId: data.ledgerEntryId.present
          ? data.ledgerEntryId.value
          : this.ledgerEntryId,
      groupExpenseId: data.groupExpenseId.present
          ? data.groupExpenseId.value
          : this.groupExpenseId,
      storedName: data.storedName.present
          ? data.storedName.value
          : this.storedName,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      remotePath: data.remotePath.present
          ? data.remotePath.value
          : this.remotePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('ledgerEntryId: $ledgerEntryId, ')
          ..write('groupExpenseId: $groupExpenseId, ')
          ..write('storedName: $storedName, ')
          ..write('originalName: $originalName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('remotePath: $remotePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    ledgerEntryId,
    groupExpenseId,
    storedName,
    originalName,
    mimeType,
    sizeBytes,
    sha256,
    remotePath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.ledgerEntryId == this.ledgerEntryId &&
          other.groupExpenseId == this.groupExpenseId &&
          other.storedName == this.storedName &&
          other.originalName == this.originalName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.sha256 == this.sha256 &&
          other.remotePath == this.remotePath &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<String> id;
  final Value<String?> transactionId;
  final Value<String?> ledgerEntryId;
  final Value<String?> groupExpenseId;
  final Value<String> storedName;
  final Value<String> originalName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String> sha256;
  final Value<String?> remotePath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.ledgerEntryId = const Value.absent(),
    this.groupExpenseId = const Value.absent(),
    this.storedName = const Value.absent(),
    this.originalName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.remotePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    this.transactionId = const Value.absent(),
    this.ledgerEntryId = const Value.absent(),
    this.groupExpenseId = const Value.absent(),
    required String storedName,
    required String originalName,
    required String mimeType,
    required int sizeBytes,
    required String sha256,
    this.remotePath = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storedName = Value(storedName),
       originalName = Value(originalName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       sha256 = Value(sha256),
       createdAt = Value(createdAt);
  static Insertable<AttachmentRow> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? ledgerEntryId,
    Expression<String>? groupExpenseId,
    Expression<String>? storedName,
    Expression<String>? originalName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? sha256,
    Expression<String>? remotePath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (ledgerEntryId != null) 'ledger_entry_id': ledgerEntryId,
      if (groupExpenseId != null) 'group_expense_id': groupExpenseId,
      if (storedName != null) 'stored_name': storedName,
      if (originalName != null) 'original_name': originalName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha256 != null) 'sha256': sha256,
      if (remotePath != null) 'remote_path': remotePath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String?>? transactionId,
    Value<String?>? ledgerEntryId,
    Value<String?>? groupExpenseId,
    Value<String>? storedName,
    Value<String>? originalName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String>? sha256,
    Value<String?>? remotePath,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      ledgerEntryId: ledgerEntryId ?? this.ledgerEntryId,
      groupExpenseId: groupExpenseId ?? this.groupExpenseId,
      storedName: storedName ?? this.storedName,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      remotePath: remotePath ?? this.remotePath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (ledgerEntryId.present) {
      map['ledger_entry_id'] = Variable<String>(ledgerEntryId.value);
    }
    if (groupExpenseId.present) {
      map['group_expense_id'] = Variable<String>(groupExpenseId.value);
    }
    if (storedName.present) {
      map['stored_name'] = Variable<String>(storedName.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (remotePath.present) {
      map['remote_path'] = Variable<String>(remotePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('ledgerEntryId: $ledgerEntryId, ')
          ..write('groupExpenseId: $groupExpenseId, ')
          ..write('storedName: $storedName, ')
          ..write('originalName: $originalName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('remotePath: $remotePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderKind>($RemindersTable.$converterkind);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderRepeat, String> repeat =
      GeneratedColumn<String>(
        'repeat',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('none'),
      ).withConverter<ReminderRepeat>($RemindersTable.$converterrepeat);
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _ledgerEntryIdMeta = const VerificationMeta(
    'ledgerEntryId',
  );
  @override
  late final GeneratedColumn<String> ledgerEntryId = GeneratedColumn<String>(
    'ledger_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES money_ledger (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES groups_cache (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    true,
    check: () => ComparableExpr(amountPaise).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _anchorDayMeta = const VerificationMeta(
    'anchorDay',
  );
  @override
  late final GeneratedColumn<int> anchorDay = GeneratedColumn<int>(
    'anchor_day',
    aliasedName,
    true,
    check: () => ComparableExpr(anchorDay).isBetweenValues(1, 31),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalOccurrencesMeta = const VerificationMeta(
    'totalOccurrences',
  );
  @override
  late final GeneratedColumn<int> totalOccurrences = GeneratedColumn<int>(
    'total_occurrences',
    aliasedName,
    true,
    check: () => ComparableExpr(totalOccurrences).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedOccurrencesMeta =
      const VerificationMeta('completedOccurrences');
  @override
  late final GeneratedColumn<int> completedOccurrences = GeneratedColumn<int>(
    'completed_occurrences',
    aliasedName,
    false,
    check: () => ComparableExpr(completedOccurrences).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<ReminderStatus>($RemindersTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    kind,
    title,
    note,
    dueAt,
    repeat,
    personId,
    ledgerEntryId,
    groupId,
    amountPaise,
    categoryId,
    anchorDay,
    totalOccurrences,
    completedOccurrences,
    notificationId,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('ledger_entry_id')) {
      context.handle(
        _ledgerEntryIdMeta,
        ledgerEntryId.isAcceptableOrUnknown(
          data['ledger_entry_id']!,
          _ledgerEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('anchor_day')) {
      context.handle(
        _anchorDayMeta,
        anchorDay.isAcceptableOrUnknown(data['anchor_day']!, _anchorDayMeta),
      );
    }
    if (data.containsKey('total_occurrences')) {
      context.handle(
        _totalOccurrencesMeta,
        totalOccurrences.isAcceptableOrUnknown(
          data['total_occurrences']!,
          _totalOccurrencesMeta,
        ),
      );
    }
    if (data.containsKey('completed_occurrences')) {
      context.handle(
        _completedOccurrencesMeta,
        completedOccurrences.isAcceptableOrUnknown(
          data['completed_occurrences']!,
          _completedOccurrencesMeta,
        ),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: $RemindersTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      repeat: $RemindersTable.$converterrepeat.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}repeat'],
        )!,
      ),
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      ),
      ledgerEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_entry_id'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      anchorDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_day'],
      ),
      totalOccurrences: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_occurrences'],
      ),
      completedOccurrences: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_occurrences'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
      status: $RemindersTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderKind, String, String> $converterkind =
      const EnumNameConverter<ReminderKind>(ReminderKind.values);
  static JsonTypeConverter2<ReminderRepeat, String, String> $converterrepeat =
      const EnumNameConverter<ReminderRepeat>(ReminderRepeat.values);
  static JsonTypeConverter2<ReminderStatus, String, String> $converterstatus =
      const EnumNameConverter<ReminderStatus>(ReminderStatus.values);
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final ReminderKind kind;
  final String title;
  final String? note;
  final DateTime dueAt;
  final ReminderRepeat repeat;
  final String? personId;
  final String? ledgerEntryId;
  final String? groupId;

  /// Fixed amount for recurring payments (EMI, SIP, maintenance, …). (v2)
  final int? amountPaise;

  /// Expense category used when the payment is recorded. (v2)
  final String? categoryId;

  /// Day of month the schedule is anchored to, so a payment due on the 31st
  /// returns to the 31st after a short month. Null → day of [dueAt]. (v2)
  final int? anchorDay;

  /// Number of payments in the series (e.g. 24 EMIs); null = no end. (v2)
  final int? totalOccurrences;

  /// How many occurrences have been completed (paid). (v2)
  final int completedOccurrences;

  /// 31-bit id used by the Android notification scheduler.
  final int notificationId;
  final ReminderStatus status;
  const ReminderRow({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.kind,
    required this.title,
    this.note,
    required this.dueAt,
    required this.repeat,
    this.personId,
    this.ledgerEntryId,
    this.groupId,
    this.amountPaise,
    this.categoryId,
    this.anchorDay,
    this.totalOccurrences,
    required this.completedOccurrences,
    required this.notificationId,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    {
      map['kind'] = Variable<String>(
        $RemindersTable.$converterkind.toSql(kind),
      );
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['due_at'] = Variable<DateTime>(dueAt);
    {
      map['repeat'] = Variable<String>(
        $RemindersTable.$converterrepeat.toSql(repeat),
      );
    }
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    if (!nullToAbsent || ledgerEntryId != null) {
      map['ledger_entry_id'] = Variable<String>(ledgerEntryId);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || amountPaise != null) {
      map['amount_paise'] = Variable<int>(amountPaise);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || anchorDay != null) {
      map['anchor_day'] = Variable<int>(anchorDay);
    }
    if (!nullToAbsent || totalOccurrences != null) {
      map['total_occurrences'] = Variable<int>(totalOccurrences);
    }
    map['completed_occurrences'] = Variable<int>(completedOccurrences);
    map['notification_id'] = Variable<int>(notificationId);
    {
      map['status'] = Variable<String>(
        $RemindersTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      dueAt: Value(dueAt),
      repeat: Value(repeat),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      ledgerEntryId: ledgerEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(ledgerEntryId),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      amountPaise: amountPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(amountPaise),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      anchorDay: anchorDay == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorDay),
      totalOccurrences: totalOccurrences == null && nullToAbsent
          ? const Value.absent()
          : Value(totalOccurrences),
      completedOccurrences: Value(completedOccurrences),
      notificationId: Value(notificationId),
      status: Value(status),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      kind: $RemindersTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      repeat: $RemindersTable.$converterrepeat.fromJson(
        serializer.fromJson<String>(json['repeat']),
      ),
      personId: serializer.fromJson<String?>(json['personId']),
      ledgerEntryId: serializer.fromJson<String?>(json['ledgerEntryId']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      amountPaise: serializer.fromJson<int?>(json['amountPaise']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      anchorDay: serializer.fromJson<int?>(json['anchorDay']),
      totalOccurrences: serializer.fromJson<int?>(json['totalOccurrences']),
      completedOccurrences: serializer.fromJson<int>(
        json['completedOccurrences'],
      ),
      notificationId: serializer.fromJson<int>(json['notificationId']),
      status: $RemindersTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(
        $RemindersTable.$converterkind.toJson(kind),
      ),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'repeat': serializer.toJson<String>(
        $RemindersTable.$converterrepeat.toJson(repeat),
      ),
      'personId': serializer.toJson<String?>(personId),
      'ledgerEntryId': serializer.toJson<String?>(ledgerEntryId),
      'groupId': serializer.toJson<String?>(groupId),
      'amountPaise': serializer.toJson<int?>(amountPaise),
      'categoryId': serializer.toJson<String?>(categoryId),
      'anchorDay': serializer.toJson<int?>(anchorDay),
      'totalOccurrences': serializer.toJson<int?>(totalOccurrences),
      'completedOccurrences': serializer.toJson<int>(completedOccurrences),
      'notificationId': serializer.toJson<int>(notificationId),
      'status': serializer.toJson<String>(
        $RemindersTable.$converterstatus.toJson(status),
      ),
    };
  }

  ReminderRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    ReminderKind? kind,
    String? title,
    Value<String?> note = const Value.absent(),
    DateTime? dueAt,
    ReminderRepeat? repeat,
    Value<String?> personId = const Value.absent(),
    Value<String?> ledgerEntryId = const Value.absent(),
    Value<String?> groupId = const Value.absent(),
    Value<int?> amountPaise = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<int?> anchorDay = const Value.absent(),
    Value<int?> totalOccurrences = const Value.absent(),
    int? completedOccurrences,
    int? notificationId,
    ReminderStatus? status,
  }) => ReminderRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    dueAt: dueAt ?? this.dueAt,
    repeat: repeat ?? this.repeat,
    personId: personId.present ? personId.value : this.personId,
    ledgerEntryId: ledgerEntryId.present
        ? ledgerEntryId.value
        : this.ledgerEntryId,
    groupId: groupId.present ? groupId.value : this.groupId,
    amountPaise: amountPaise.present ? amountPaise.value : this.amountPaise,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    anchorDay: anchorDay.present ? anchorDay.value : this.anchorDay,
    totalOccurrences: totalOccurrences.present
        ? totalOccurrences.value
        : this.totalOccurrences,
    completedOccurrences: completedOccurrences ?? this.completedOccurrences,
    notificationId: notificationId ?? this.notificationId,
    status: status ?? this.status,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      personId: data.personId.present ? data.personId.value : this.personId,
      ledgerEntryId: data.ledgerEntryId.present
          ? data.ledgerEntryId.value
          : this.ledgerEntryId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      anchorDay: data.anchorDay.present ? data.anchorDay.value : this.anchorDay,
      totalOccurrences: data.totalOccurrences.present
          ? data.totalOccurrences.value
          : this.totalOccurrences,
      completedOccurrences: data.completedOccurrences.present
          ? data.completedOccurrences.value
          : this.completedOccurrences,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('dueAt: $dueAt, ')
          ..write('repeat: $repeat, ')
          ..write('personId: $personId, ')
          ..write('ledgerEntryId: $ledgerEntryId, ')
          ..write('groupId: $groupId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('categoryId: $categoryId, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('totalOccurrences: $totalOccurrences, ')
          ..write('completedOccurrences: $completedOccurrences, ')
          ..write('notificationId: $notificationId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    kind,
    title,
    note,
    dueAt,
    repeat,
    personId,
    ledgerEntryId,
    groupId,
    amountPaise,
    categoryId,
    anchorDay,
    totalOccurrences,
    completedOccurrences,
    notificationId,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.note == this.note &&
          other.dueAt == this.dueAt &&
          other.repeat == this.repeat &&
          other.personId == this.personId &&
          other.ledgerEntryId == this.ledgerEntryId &&
          other.groupId == this.groupId &&
          other.amountPaise == this.amountPaise &&
          other.categoryId == this.categoryId &&
          other.anchorDay == this.anchorDay &&
          other.totalOccurrences == this.totalOccurrences &&
          other.completedOccurrences == this.completedOccurrences &&
          other.notificationId == this.notificationId &&
          other.status == this.status);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<ReminderKind> kind;
  final Value<String> title;
  final Value<String?> note;
  final Value<DateTime> dueAt;
  final Value<ReminderRepeat> repeat;
  final Value<String?> personId;
  final Value<String?> ledgerEntryId;
  final Value<String?> groupId;
  final Value<int?> amountPaise;
  final Value<String?> categoryId;
  final Value<int?> anchorDay;
  final Value<int?> totalOccurrences;
  final Value<int> completedOccurrences;
  final Value<int> notificationId;
  final Value<ReminderStatus> status;
  final Value<int> rowid;
  const RemindersCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.repeat = const Value.absent(),
    this.personId = const Value.absent(),
    this.ledgerEntryId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.anchorDay = const Value.absent(),
    this.totalOccurrences = const Value.absent(),
    this.completedOccurrences = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    required String id,
    required ReminderKind kind,
    required String title,
    this.note = const Value.absent(),
    required DateTime dueAt,
    this.repeat = const Value.absent(),
    this.personId = const Value.absent(),
    this.ledgerEntryId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.anchorDay = const Value.absent(),
    this.totalOccurrences = const Value.absent(),
    this.completedOccurrences = const Value.absent(),
    required int notificationId,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       kind = Value(kind),
       title = Value(title),
       dueAt = Value(dueAt),
       notificationId = Value(notificationId);
  static Insertable<ReminderRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? note,
    Expression<DateTime>? dueAt,
    Expression<String>? repeat,
    Expression<String>? personId,
    Expression<String>? ledgerEntryId,
    Expression<String>? groupId,
    Expression<int>? amountPaise,
    Expression<String>? categoryId,
    Expression<int>? anchorDay,
    Expression<int>? totalOccurrences,
    Expression<int>? completedOccurrences,
    Expression<int>? notificationId,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (dueAt != null) 'due_at': dueAt,
      if (repeat != null) 'repeat': repeat,
      if (personId != null) 'person_id': personId,
      if (ledgerEntryId != null) 'ledger_entry_id': ledgerEntryId,
      if (groupId != null) 'group_id': groupId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (categoryId != null) 'category_id': categoryId,
      if (anchorDay != null) 'anchor_day': anchorDay,
      if (totalOccurrences != null) 'total_occurrences': totalOccurrences,
      if (completedOccurrences != null)
        'completed_occurrences': completedOccurrences,
      if (notificationId != null) 'notification_id': notificationId,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<ReminderKind>? kind,
    Value<String>? title,
    Value<String?>? note,
    Value<DateTime>? dueAt,
    Value<ReminderRepeat>? repeat,
    Value<String?>? personId,
    Value<String?>? ledgerEntryId,
    Value<String?>? groupId,
    Value<int?>? amountPaise,
    Value<String?>? categoryId,
    Value<int?>? anchorDay,
    Value<int?>? totalOccurrences,
    Value<int>? completedOccurrences,
    Value<int>? notificationId,
    Value<ReminderStatus>? status,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      note: note ?? this.note,
      dueAt: dueAt ?? this.dueAt,
      repeat: repeat ?? this.repeat,
      personId: personId ?? this.personId,
      ledgerEntryId: ledgerEntryId ?? this.ledgerEntryId,
      groupId: groupId ?? this.groupId,
      amountPaise: amountPaise ?? this.amountPaise,
      categoryId: categoryId ?? this.categoryId,
      anchorDay: anchorDay ?? this.anchorDay,
      totalOccurrences: totalOccurrences ?? this.totalOccurrences,
      completedOccurrences: completedOccurrences ?? this.completedOccurrences,
      notificationId: notificationId ?? this.notificationId,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $RemindersTable.$converterkind.toSql(kind.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(
        $RemindersTable.$converterrepeat.toSql(repeat.value),
      );
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (ledgerEntryId.present) {
      map['ledger_entry_id'] = Variable<String>(ledgerEntryId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (anchorDay.present) {
      map['anchor_day'] = Variable<int>(anchorDay.value);
    }
    if (totalOccurrences.present) {
      map['total_occurrences'] = Variable<int>(totalOccurrences.value);
    }
    if (completedOccurrences.present) {
      map['completed_occurrences'] = Variable<int>(completedOccurrences.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $RemindersTable.$converterstatus.toSql(status.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('dueAt: $dueAt, ')
          ..write('repeat: $repeat, ')
          ..write('personId: $personId, ')
          ..write('ledgerEntryId: $ledgerEntryId, ')
          ..write('groupId: $groupId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('categoryId: $categoryId, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('totalOccurrences: $totalOccurrences, ')
          ..write('completedOccurrences: $completedOccurrences, ')
          ..write('notificationId: $notificationId, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  @override
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OutboxStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<OutboxStatus>($SyncOutboxTable.$converterstatus);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    groupId,
    entityType,
    entityId,
    opType,
    payload,
    baseRevision,
    status,
    attempts,
    nextAttemptAt,
    lastError,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseRevisionMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      )!,
      status: $SyncOutboxTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OutboxStatus, String, String> $converterstatus =
      const EnumNameConverter<OutboxStatus>(OutboxStatus.values);
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  /// Idempotency key sent to the server.
  final String opId;
  final String groupId;
  final String entityType;
  final String entityId;

  /// `upsert` or `delete`.
  final String opType;
  final String payload;
  final int baseRevision;
  final OutboxStatus status;
  final int attempts;
  final DateTime? nextAttemptAt;
  final String? lastError;
  final DateTime createdAt;
  const OutboxRow({
    required this.opId,
    required this.groupId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.payload,
    required this.baseRevision,
    required this.status,
    required this.attempts,
    this.nextAttemptAt,
    this.lastError,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['group_id'] = Variable<String>(groupId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['op_type'] = Variable<String>(opType);
    map['payload'] = Variable<String>(payload);
    map['base_revision'] = Variable<int>(baseRevision);
    {
      map['status'] = Variable<String>(
        $SyncOutboxTable.$converterstatus.toSql(status),
      );
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      opId: Value(opId),
      groupId: Value(groupId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      opType: Value(opType),
      payload: Value(payload),
      baseRevision: Value(baseRevision),
      status: Value(status),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      opId: serializer.fromJson<String>(json['opId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      opType: serializer.fromJson<String>(json['opType']),
      payload: serializer.fromJson<String>(json['payload']),
      baseRevision: serializer.fromJson<int>(json['baseRevision']),
      status: $SyncOutboxTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'groupId': serializer.toJson<String>(groupId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'opType': serializer.toJson<String>(opType),
      'payload': serializer.toJson<String>(payload),
      'baseRevision': serializer.toJson<int>(baseRevision),
      'status': serializer.toJson<String>(
        $SyncOutboxTable.$converterstatus.toJson(status),
      ),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxRow copyWith({
    String? opId,
    String? groupId,
    String? entityType,
    String? entityId,
    String? opType,
    String? payload,
    int? baseRevision,
    OutboxStatus? status,
    int? attempts,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
  }) => OutboxRow(
    opId: opId ?? this.opId,
    groupId: groupId ?? this.groupId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    opType: opType ?? this.opType,
    payload: payload ?? this.payload,
    baseRevision: baseRevision ?? this.baseRevision,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxRow copyWithCompanion(SyncOutboxCompanion data) {
    return OutboxRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      opType: data.opType.present ? data.opType.value : this.opType,
      payload: data.payload.present ? data.payload.value : this.payload,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('opId: $opId, ')
          ..write('groupId: $groupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('payload: $payload, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    groupId,
    entityType,
    entityId,
    opType,
    payload,
    baseRevision,
    status,
    attempts,
    nextAttemptAt,
    lastError,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.opId == this.opId &&
          other.groupId == this.groupId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.opType == this.opType &&
          other.payload == this.payload &&
          other.baseRevision == this.baseRevision &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class SyncOutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<String> opId;
  final Value<String> groupId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> opType;
  final Value<String> payload;
  final Value<int> baseRevision;
  final Value<OutboxStatus> status;
  final Value<int> attempts;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.opId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.opType = const Value.absent(),
    this.payload = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String opId,
    required String groupId,
    required String entityType,
    required String entityId,
    required String opType,
    required String payload,
    required int baseRevision,
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       groupId = Value(groupId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       opType = Value(opType),
       payload = Value(payload),
       baseRevision = Value(baseRevision),
       createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<String>? opId,
    Expression<String>? groupId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? opType,
    Expression<String>? payload,
    Expression<int>? baseRevision,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (groupId != null) 'group_id': groupId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (opType != null) 'op_type': opType,
      if (payload != null) 'payload': payload,
      if (baseRevision != null) 'base_revision': baseRevision,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? opId,
    Value<String>? groupId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? opType,
    Value<String>? payload,
    Value<int>? baseRevision,
    Value<OutboxStatus>? status,
    Value<int>? attempts,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      opId: opId ?? this.opId,
      groupId: groupId ?? this.groupId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      opType: opType ?? this.opType,
      payload: payload ?? this.payload,
      baseRevision: baseRevision ?? this.baseRevision,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SyncOutboxTable.$converterstatus.toSql(status.value),
      );
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('opId: $opId, ')
          ..write('groupId: $groupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('payload: $payload, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncInboxTable extends SyncInbox
    with TableInfo<$SyncInboxTable, InboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncInboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteRevisionMeta = const VerificationMeta(
    'remoteRevision',
  );
  @override
  late final GeneratedColumn<int> remoteRevision = GeneratedColumn<int>(
    'remote_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    groupId,
    entityType,
    entityId,
    opType,
    payload,
    remoteRevision,
    receivedAt,
    appliedAt,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_inbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<InboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('remote_revision')) {
      context.handle(
        _remoteRevisionMeta,
        remoteRevision.isAcceptableOrUnknown(
          data['remote_revision']!,
          _remoteRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteRevisionMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  InboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      remoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_revision'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $SyncInboxTable createAlias(String alias) {
    return $SyncInboxTable(attachedDatabase, alias);
  }
}

class InboxRow extends DataClass implements Insertable<InboxRow> {
  /// Server event sequence number (monotonic).
  final int seq;
  final String groupId;
  final String entityType;
  final String entityId;
  final String opType;
  final String payload;
  final int remoteRevision;
  final DateTime receivedAt;
  final DateTime? appliedAt;
  final String? error;
  const InboxRow({
    required this.seq,
    required this.groupId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.payload,
    required this.remoteRevision,
    required this.receivedAt,
    this.appliedAt,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['group_id'] = Variable<String>(groupId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['op_type'] = Variable<String>(opType);
    map['payload'] = Variable<String>(payload);
    map['remote_revision'] = Variable<int>(remoteRevision);
    map['received_at'] = Variable<DateTime>(receivedAt);
    if (!nullToAbsent || appliedAt != null) {
      map['applied_at'] = Variable<DateTime>(appliedAt);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  SyncInboxCompanion toCompanion(bool nullToAbsent) {
    return SyncInboxCompanion(
      seq: Value(seq),
      groupId: Value(groupId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      opType: Value(opType),
      payload: Value(payload),
      remoteRevision: Value(remoteRevision),
      receivedAt: Value(receivedAt),
      appliedAt: appliedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedAt),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory InboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxRow(
      seq: serializer.fromJson<int>(json['seq']),
      groupId: serializer.fromJson<String>(json['groupId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      opType: serializer.fromJson<String>(json['opType']),
      payload: serializer.fromJson<String>(json['payload']),
      remoteRevision: serializer.fromJson<int>(json['remoteRevision']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      appliedAt: serializer.fromJson<DateTime?>(json['appliedAt']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'groupId': serializer.toJson<String>(groupId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'opType': serializer.toJson<String>(opType),
      'payload': serializer.toJson<String>(payload),
      'remoteRevision': serializer.toJson<int>(remoteRevision),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'appliedAt': serializer.toJson<DateTime?>(appliedAt),
      'error': serializer.toJson<String?>(error),
    };
  }

  InboxRow copyWith({
    int? seq,
    String? groupId,
    String? entityType,
    String? entityId,
    String? opType,
    String? payload,
    int? remoteRevision,
    DateTime? receivedAt,
    Value<DateTime?> appliedAt = const Value.absent(),
    Value<String?> error = const Value.absent(),
  }) => InboxRow(
    seq: seq ?? this.seq,
    groupId: groupId ?? this.groupId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    opType: opType ?? this.opType,
    payload: payload ?? this.payload,
    remoteRevision: remoteRevision ?? this.remoteRevision,
    receivedAt: receivedAt ?? this.receivedAt,
    appliedAt: appliedAt.present ? appliedAt.value : this.appliedAt,
    error: error.present ? error.value : this.error,
  );
  InboxRow copyWithCompanion(SyncInboxCompanion data) {
    return InboxRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      opType: data.opType.present ? data.opType.value : this.opType,
      payload: data.payload.present ? data.payload.value : this.payload,
      remoteRevision: data.remoteRevision.present
          ? data.remoteRevision.value
          : this.remoteRevision,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxRow(')
          ..write('seq: $seq, ')
          ..write('groupId: $groupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('payload: $payload, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    groupId,
    entityType,
    entityId,
    opType,
    payload,
    remoteRevision,
    receivedAt,
    appliedAt,
    error,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxRow &&
          other.seq == this.seq &&
          other.groupId == this.groupId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.opType == this.opType &&
          other.payload == this.payload &&
          other.remoteRevision == this.remoteRevision &&
          other.receivedAt == this.receivedAt &&
          other.appliedAt == this.appliedAt &&
          other.error == this.error);
}

class SyncInboxCompanion extends UpdateCompanion<InboxRow> {
  final Value<int> seq;
  final Value<String> groupId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> opType;
  final Value<String> payload;
  final Value<int> remoteRevision;
  final Value<DateTime> receivedAt;
  final Value<DateTime?> appliedAt;
  final Value<String?> error;
  const SyncInboxCompanion({
    this.seq = const Value.absent(),
    this.groupId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.opType = const Value.absent(),
    this.payload = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.error = const Value.absent(),
  });
  SyncInboxCompanion.insert({
    this.seq = const Value.absent(),
    required String groupId,
    required String entityType,
    required String entityId,
    required String opType,
    required String payload,
    required int remoteRevision,
    required DateTime receivedAt,
    this.appliedAt = const Value.absent(),
    this.error = const Value.absent(),
  }) : groupId = Value(groupId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       opType = Value(opType),
       payload = Value(payload),
       remoteRevision = Value(remoteRevision),
       receivedAt = Value(receivedAt);
  static Insertable<InboxRow> custom({
    Expression<int>? seq,
    Expression<String>? groupId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? opType,
    Expression<String>? payload,
    Expression<int>? remoteRevision,
    Expression<DateTime>? receivedAt,
    Expression<DateTime>? appliedAt,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (groupId != null) 'group_id': groupId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (opType != null) 'op_type': opType,
      if (payload != null) 'payload': payload,
      if (remoteRevision != null) 'remote_revision': remoteRevision,
      if (receivedAt != null) 'received_at': receivedAt,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (error != null) 'error': error,
    });
  }

  SyncInboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? groupId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? opType,
    Value<String>? payload,
    Value<int>? remoteRevision,
    Value<DateTime>? receivedAt,
    Value<DateTime?>? appliedAt,
    Value<String?>? error,
  }) {
    return SyncInboxCompanion(
      seq: seq ?? this.seq,
      groupId: groupId ?? this.groupId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      opType: opType ?? this.opType,
      payload: payload ?? this.payload,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      receivedAt: receivedAt ?? this.receivedAt,
      appliedAt: appliedAt ?? this.appliedAt,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (remoteRevision.present) {
      map['remote_revision'] = Variable<int>(remoteRevision.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncInboxCompanion(')
          ..write('seq: $seq, ')
          ..write('groupId: $groupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('payload: $payload, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, ConflictRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPayloadMeta = const VerificationMeta(
    'localPayload',
  );
  @override
  late final GeneratedColumn<String> localPayload = GeneratedColumn<String>(
    'local_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remotePayloadMeta = const VerificationMeta(
    'remotePayload',
  );
  @override
  late final GeneratedColumn<String> remotePayload = GeneratedColumn<String>(
    'remote_payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteRevisionMeta = const VerificationMeta(
    'remoteRevision',
  );
  @override
  late final GeneratedColumn<int> remoteRevision = GeneratedColumn<int>(
    'remote_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    entityType,
    entityId,
    opId,
    localPayload,
    remotePayload,
    remoteRevision,
    detectedAt,
    resolvedAt,
    resolution,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflictRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('local_payload')) {
      context.handle(
        _localPayloadMeta,
        localPayload.isAcceptableOrUnknown(
          data['local_payload']!,
          _localPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPayloadMeta);
    }
    if (data.containsKey('remote_payload')) {
      context.handle(
        _remotePayloadMeta,
        remotePayload.isAcceptableOrUnknown(
          data['remote_payload']!,
          _remotePayloadMeta,
        ),
      );
    }
    if (data.containsKey('remote_revision')) {
      context.handle(
        _remoteRevisionMeta,
        remoteRevision.isAcceptableOrUnknown(
          data['remote_revision']!,
          _remoteRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteRevisionMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConflictRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflictRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      localPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_payload'],
      )!,
      remotePayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_payload'],
      ),
      remoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_revision'],
      )!,
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class ConflictRow extends DataClass implements Insertable<ConflictRow> {
  final String id;
  final String groupId;
  final String entityType;
  final String entityId;
  final String? opId;
  final String localPayload;
  final String? remotePayload;
  final int remoteRevision;
  final DateTime detectedAt;
  final DateTime? resolvedAt;

  /// `keepLocal` / `keepRemote`.
  final String? resolution;
  const ConflictRow({
    required this.id,
    required this.groupId,
    required this.entityType,
    required this.entityId,
    this.opId,
    required this.localPayload,
    this.remotePayload,
    required this.remoteRevision,
    required this.detectedAt,
    this.resolvedAt,
    this.resolution,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['local_payload'] = Variable<String>(localPayload);
    if (!nullToAbsent || remotePayload != null) {
      map['remote_payload'] = Variable<String>(remotePayload);
    }
    map['remote_revision'] = Variable<int>(remoteRevision);
    map['detected_at'] = Variable<DateTime>(detectedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      localPayload: Value(localPayload),
      remotePayload: remotePayload == null && nullToAbsent
          ? const Value.absent()
          : Value(remotePayload),
      remoteRevision: Value(remoteRevision),
      detectedAt: Value(detectedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
    );
  }

  factory ConflictRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflictRow(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      opId: serializer.fromJson<String?>(json['opId']),
      localPayload: serializer.fromJson<String>(json['localPayload']),
      remotePayload: serializer.fromJson<String?>(json['remotePayload']),
      remoteRevision: serializer.fromJson<int>(json['remoteRevision']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      resolution: serializer.fromJson<String?>(json['resolution']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'opId': serializer.toJson<String?>(opId),
      'localPayload': serializer.toJson<String>(localPayload),
      'remotePayload': serializer.toJson<String?>(remotePayload),
      'remoteRevision': serializer.toJson<int>(remoteRevision),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'resolution': serializer.toJson<String?>(resolution),
    };
  }

  ConflictRow copyWith({
    String? id,
    String? groupId,
    String? entityType,
    String? entityId,
    Value<String?> opId = const Value.absent(),
    String? localPayload,
    Value<String?> remotePayload = const Value.absent(),
    int? remoteRevision,
    DateTime? detectedAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<String?> resolution = const Value.absent(),
  }) => ConflictRow(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    opId: opId.present ? opId.value : this.opId,
    localPayload: localPayload ?? this.localPayload,
    remotePayload: remotePayload.present
        ? remotePayload.value
        : this.remotePayload,
    remoteRevision: remoteRevision ?? this.remoteRevision,
    detectedAt: detectedAt ?? this.detectedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    resolution: resolution.present ? resolution.value : this.resolution,
  );
  ConflictRow copyWithCompanion(SyncConflictsCompanion data) {
    return ConflictRow(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      opId: data.opId.present ? data.opId.value : this.opId,
      localPayload: data.localPayload.present
          ? data.localPayload.value
          : this.localPayload,
      remotePayload: data.remotePayload.present
          ? data.remotePayload.value
          : this.remotePayload,
      remoteRevision: data.remoteRevision.present
          ? data.remoteRevision.value
          : this.remoteRevision,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflictRow(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opId: $opId, ')
          ..write('localPayload: $localPayload, ')
          ..write('remotePayload: $remotePayload, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    entityType,
    entityId,
    opId,
    localPayload,
    remotePayload,
    remoteRevision,
    detectedAt,
    resolvedAt,
    resolution,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflictRow &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.opId == this.opId &&
          other.localPayload == this.localPayload &&
          other.remotePayload == this.remotePayload &&
          other.remoteRevision == this.remoteRevision &&
          other.detectedAt == this.detectedAt &&
          other.resolvedAt == this.resolvedAt &&
          other.resolution == this.resolution);
}

class SyncConflictsCompanion extends UpdateCompanion<ConflictRow> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String?> opId;
  final Value<String> localPayload;
  final Value<String?> remotePayload;
  final Value<int> remoteRevision;
  final Value<DateTime> detectedAt;
  final Value<DateTime?> resolvedAt;
  final Value<String?> resolution;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.opId = const Value.absent(),
    this.localPayload = const Value.absent(),
    this.remotePayload = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String groupId,
    required String entityType,
    required String entityId,
    this.opId = const Value.absent(),
    required String localPayload,
    this.remotePayload = const Value.absent(),
    required int remoteRevision,
    required DateTime detectedAt,
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       localPayload = Value(localPayload),
       remoteRevision = Value(remoteRevision),
       detectedAt = Value(detectedAt);
  static Insertable<ConflictRow> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? opId,
    Expression<String>? localPayload,
    Expression<String>? remotePayload,
    Expression<int>? remoteRevision,
    Expression<DateTime>? detectedAt,
    Expression<DateTime>? resolvedAt,
    Expression<String>? resolution,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (opId != null) 'op_id': opId,
      if (localPayload != null) 'local_payload': localPayload,
      if (remotePayload != null) 'remote_payload': remotePayload,
      if (remoteRevision != null) 'remote_revision': remoteRevision,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolution != null) 'resolution': resolution,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String?>? opId,
    Value<String>? localPayload,
    Value<String?>? remotePayload,
    Value<int>? remoteRevision,
    Value<DateTime>? detectedAt,
    Value<DateTime?>? resolvedAt,
    Value<String?>? resolution,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      opId: opId ?? this.opId,
      localPayload: localPayload ?? this.localPayload,
      remotePayload: remotePayload ?? this.remotePayload,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (localPayload.present) {
      map['local_payload'] = Variable<String>(localPayload.value);
    }
    if (remotePayload.present) {
      map['remote_payload'] = Variable<String>(remotePayload.value);
    }
    if (remoteRevision.present) {
      map['remote_revision'] = Variable<int>(remoteRevision.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opId: $opId, ')
          ..write('localPayload: $localPayload, ')
          ..write('remotePayload: $remotePayload, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalUserProfileTable localUserProfile = $LocalUserProfileTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $BackupHistoryTable backupHistory = $BackupHistoryTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $PersonsTable persons = $PersonsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $MoneyLedgerTable moneyLedger = $MoneyLedgerTable(this);
  late final $MoneySettlementsTable moneySettlements = $MoneySettlementsTable(
    this,
  );
  late final $GroupsCacheTable groupsCache = $GroupsCacheTable(this);
  late final $GroupMembersCacheTable groupMembersCache =
      $GroupMembersCacheTable(this);
  late final $GroupExpensesCacheTable groupExpensesCache =
      $GroupExpensesCacheTable(this);
  late final $GroupExpenseSplitsCacheTable groupExpenseSplitsCache =
      $GroupExpenseSplitsCacheTable(this);
  late final $GroupSettlementsCacheTable groupSettlementsCache =
      $GroupSettlementsCacheTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncInboxTable syncInbox = $SyncInboxTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final Index idxBackupHistoryCreated = Index(
    'idx_backup_history_created',
    'CREATE INDEX idx_backup_history_created ON backup_history (created_at)',
  );
  late final Index idxCategoriesType = Index(
    'idx_categories_type',
    'CREATE INDEX idx_categories_type ON categories (type, sort_order)',
  );
  late final Index idxPersonsName = Index(
    'idx_persons_name',
    'CREATE INDEX idx_persons_name ON persons (name)',
  );
  late final Index idxTransactionsDate = Index(
    'idx_transactions_date',
    'CREATE INDEX idx_transactions_date ON transactions (txn_date)',
  );
  late final Index idxTransactionsCategory = Index(
    'idx_transactions_category',
    'CREATE INDEX idx_transactions_category ON transactions (category_id)',
  );
  late final Index idxTransactionsPerson = Index(
    'idx_transactions_person',
    'CREATE INDEX idx_transactions_person ON transactions (person_id)',
  );
  late final Index idxLedgerPerson = Index(
    'idx_ledger_person',
    'CREATE INDEX idx_ledger_person ON money_ledger (person_id)',
  );
  late final Index idxLedgerDue = Index(
    'idx_ledger_due',
    'CREATE INDEX idx_ledger_due ON money_ledger (due_date)',
  );
  late final Index idxSettlementsLedger = Index(
    'idx_settlements_ledger',
    'CREATE INDEX idx_settlements_ledger ON money_settlements (ledger_id)',
  );
  late final Index idxMembersGroup = Index(
    'idx_members_group',
    'CREATE INDEX idx_members_group ON group_members_cache (group_id)',
  );
  late final Index idxGexpGroupDate = Index(
    'idx_gexp_group_date',
    'CREATE INDEX idx_gexp_group_date ON group_expenses_cache (group_id, expense_date)',
  );
  late final Index idxGsplitExpense = Index(
    'idx_gsplit_expense',
    'CREATE INDEX idx_gsplit_expense ON group_expense_splits_cache (expense_id)',
  );
  late final Index idxGsettleGroup = Index(
    'idx_gsettle_group',
    'CREATE INDEX idx_gsettle_group ON group_settlements_cache (group_id, settled_on)',
  );
  late final Index idxAttTxn = Index(
    'idx_att_txn',
    'CREATE INDEX idx_att_txn ON attachments (transaction_id)',
  );
  late final Index idxAttLedger = Index(
    'idx_att_ledger',
    'CREATE INDEX idx_att_ledger ON attachments (ledger_entry_id)',
  );
  late final Index idxAttGexp = Index(
    'idx_att_gexp',
    'CREATE INDEX idx_att_gexp ON attachments (group_expense_id)',
  );
  late final Index idxRemindersDue = Index(
    'idx_reminders_due',
    'CREATE INDEX idx_reminders_due ON reminders (status, due_at)',
  );
  late final Index idxOutboxStatus = Index(
    'idx_outbox_status',
    'CREATE INDEX idx_outbox_status ON sync_outbox (status, created_at)',
  );
  late final Index idxConflictsOpen = Index(
    'idx_conflicts_open',
    'CREATE INDEX idx_conflicts_open ON sync_conflicts (resolved_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localUserProfile,
    appSettings,
    backupHistory,
    categories,
    persons,
    transactions,
    moneyLedger,
    moneySettlements,
    groupsCache,
    groupMembersCache,
    groupExpensesCache,
    groupExpenseSplitsCache,
    groupSettlementsCache,
    attachments,
    reminders,
    syncOutbox,
    syncInbox,
    syncConflicts,
    idxBackupHistoryCreated,
    idxCategoriesType,
    idxPersonsName,
    idxTransactionsDate,
    idxTransactionsCategory,
    idxTransactionsPerson,
    idxLedgerPerson,
    idxLedgerDue,
    idxSettlementsLedger,
    idxMembersGroup,
    idxGexpGroupDate,
    idxGsplitExpense,
    idxGsettleGroup,
    idxAttTxn,
    idxAttLedger,
    idxAttGexp,
    idxRemindersDue,
    idxOutboxStatus,
    idxConflictsOpen,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('money_ledger', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'money_ledger',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('money_settlements', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups_cache',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_members_cache', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_members_cache', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups_cache',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_expenses_cache', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'group_expenses_cache',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('group_expense_splits_cache', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups_cache',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_settlements_cache', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'money_ledger',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'group_expenses_cache',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'money_ledger',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups_cache',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$LocalUserProfileTableCreateCompanionBuilder =
    LocalUserProfileCompanion Function({
      required DateTime createdAt,
      required DateTime updatedAt,
      required String id,
      required String displayName,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> remoteUserId,
      Value<int> rowid,
    });
typedef $$LocalUserProfileTableUpdateCompanionBuilder =
    LocalUserProfileCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> displayName,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> remoteUserId,
      Value<int> rowid,
    });

class $$LocalUserProfileTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUserProfileTable> {
  $$LocalUserProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUserId => $composableBuilder(
    column: $table.remoteUserId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUserProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUserProfileTable> {
  $$LocalUserProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUserId => $composableBuilder(
    column: $table.remoteUserId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUserProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUserProfileTable> {
  $$LocalUserProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get remoteUserId => $composableBuilder(
    column: $table.remoteUserId,
    builder: (column) => column,
  );
}

class $$LocalUserProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUserProfileTable,
          LocalUserProfileRow,
          $$LocalUserProfileTableFilterComposer,
          $$LocalUserProfileTableOrderingComposer,
          $$LocalUserProfileTableAnnotationComposer,
          $$LocalUserProfileTableCreateCompanionBuilder,
          $$LocalUserProfileTableUpdateCompanionBuilder,
          (
            LocalUserProfileRow,
            BaseReferences<
              _$AppDatabase,
              $LocalUserProfileTable,
              LocalUserProfileRow
            >,
          ),
          LocalUserProfileRow,
          PrefetchHooks Function()
        > {
  $$LocalUserProfileTableTableManager(
    _$AppDatabase db,
    $LocalUserProfileTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUserProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUserProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> remoteUserId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUserProfileCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                displayName: displayName,
                phone: phone,
                email: email,
                remoteUserId: remoteUserId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime createdAt,
                required DateTime updatedAt,
                required String id,
                required String displayName,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> remoteUserId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUserProfileCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                displayName: displayName,
                phone: phone,
                email: email,
                remoteUserId: remoteUserId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalUserProfileTable, LocalUserProfileRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalUserProfileTable,
                    LocalUserProfileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUserProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUserProfileTable,
      LocalUserProfileRow,
      $$LocalUserProfileTableFilterComposer,
      $$LocalUserProfileTableOrderingComposer,
      $$LocalUserProfileTableAnnotationComposer,
      $$LocalUserProfileTableCreateCompanionBuilder,
      $$LocalUserProfileTableUpdateCompanionBuilder,
      (
        LocalUserProfileRow,
        BaseReferences<
          _$AppDatabase,
          $LocalUserProfileTable,
          LocalUserProfileRow
        >,
      ),
      LocalUserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;
typedef $$BackupHistoryTableCreateCompanionBuilder =
    BackupHistoryCompanion Function({
      required String id,
      required String fileName,
      required String filePath,
      required int sizeBytes,
      required String sha256,
      Value<bool> encrypted,
      required BackupKind kind,
      required int schemaVersion,
      required String appVersion,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BackupHistoryTableUpdateCompanionBuilder =
    BackupHistoryCompanion Function({
      Value<String> id,
      Value<String> fileName,
      Value<String> filePath,
      Value<int> sizeBytes,
      Value<String> sha256,
      Value<bool> encrypted,
      Value<BackupKind> kind,
      Value<int> schemaVersion,
      Value<String> appVersion,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BackupHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get encrypted => $composableBuilder(
    column: $table.encrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BackupKind, BackupKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get encrypted => $composableBuilder(
    column: $table.encrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<bool> get encrypted =>
      $composableBuilder(column: $table.encrypted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BackupKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BackupHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupHistoryTable,
          BackupHistoryRow,
          $$BackupHistoryTableFilterComposer,
          $$BackupHistoryTableOrderingComposer,
          $$BackupHistoryTableAnnotationComposer,
          $$BackupHistoryTableCreateCompanionBuilder,
          $$BackupHistoryTableUpdateCompanionBuilder,
          (
            BackupHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $BackupHistoryTable,
              BackupHistoryRow
            >,
          ),
          BackupHistoryRow,
          PrefetchHooks Function()
        > {
  $$BackupHistoryTableTableManager(_$AppDatabase db, $BackupHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<bool> encrypted = const Value.absent(),
                Value<BackupKind> kind = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupHistoryCompanion(
                id: id,
                fileName: fileName,
                filePath: filePath,
                sizeBytes: sizeBytes,
                sha256: sha256,
                encrypted: encrypted,
                kind: kind,
                schemaVersion: schemaVersion,
                appVersion: appVersion,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fileName,
                required String filePath,
                required int sizeBytes,
                required String sha256,
                Value<bool> encrypted = const Value.absent(),
                required BackupKind kind,
                required int schemaVersion,
                required String appVersion,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BackupHistoryCompanion.insert(
                id: id,
                fileName: fileName,
                filePath: filePath,
                sizeBytes: sizeBytes,
                sha256: sha256,
                encrypted: encrypted,
                kind: kind,
                schemaVersion: schemaVersion,
                appVersion: appVersion,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BackupHistoryTable, BackupHistoryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BackupHistoryTable,
                    BackupHistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupHistoryTable,
      BackupHistoryRow,
      $$BackupHistoryTableFilterComposer,
      $$BackupHistoryTableOrderingComposer,
      $$BackupHistoryTableAnnotationComposer,
      $$BackupHistoryTableCreateCompanionBuilder,
      $$BackupHistoryTableUpdateCompanionBuilder,
      (
        BackupHistoryRow,
        BaseReferences<_$AppDatabase, $BackupHistoryTable, BackupHistoryRow>,
      ),
      BackupHistoryRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required DateTime createdAt,
  required DateTime updatedAt,
  required String id,
  Value<String?> systemKey,
  required String name,
  required TransactionType type,
  required String iconKey,
  required int colorValue,
  Value<int> sortOrder,
  Value<bool> isArchived,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> id,
  Value<String?> systemKey,
  Value<String> name,
  Value<TransactionType> type,
  Value<String> iconKey,
  Value<int> colorValue,
  Value<int> sortOrder,
  Value<bool> isArchived,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'categories__id__reminders__category_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemKey => $composableBuilder(
    column: $table.systemKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemKey => $composableBuilder(
    column: $table.systemKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get systemKey =>
      $composableBuilder(column: $table.systemKey, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool transactionsRefs, bool remindersRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> systemKey = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<TransactionType> type = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                systemKey: systemKey,
                name: name,
                type: type,
                iconKey: iconKey,
                colorValue: colorValue,
                sortOrder: sortOrder,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime createdAt,
                required DateTime updatedAt,
                required String id,
                Value<String?> systemKey = const Value.absent(),
                required String name,
                required TransactionType type,
                required String iconKey,
                required int colorValue,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                systemKey: systemKey,
                name: name,
                type: type,
                iconKey: iconKey,
                colorValue: colorValue,
                sortOrder: sortOrder,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transactionsRefs = false, remindersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (remindersRefs) db.reminders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          CategoryRow,
                          $CategoriesTable,
                          TransactionRow,
                          $TransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedDataByColumns<
                          CategoryRow,
                          $CategoriesTable,
                          ReminderRow,
                          $RemindersTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool transactionsRefs, bool remindersRefs})
    >;
typedef $$PersonsTableCreateCompanionBuilder = PersonsCompanion Function({
  required DateTime createdAt,
  required DateTime updatedAt,
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> description,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$PersonsTableUpdateCompanionBuilder = PersonsCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> description,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$PersonsTableReferences
    extends BaseReferences<_$AppDatabase, $PersonsTable, PersonRow> {
  $$PersonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'persons__id__transactions__person_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MoneyLedgerTable, List<LedgerEntryRow>>
  _moneyLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moneyLedger,
    aliasName: 'persons__id__money_ledger__person_id',
  );

  $$MoneyLedgerTableProcessedTableManager get moneyLedgerRefs {
    final manager = $$MoneyLedgerTableTableManager(
      $_db,
      $_db.moneyLedger,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_moneyLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupMembersCacheTable, List<GroupMemberRow>>
  _groupMembersCacheRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groupMembersCache,
        aliasName: 'persons__id__group_members_cache__person_id',
      );

  $$GroupMembersCacheTableProcessedTableManager get groupMembersCacheRefs {
    final manager = $$GroupMembersCacheTableTableManager(
      $_db,
      $_db.groupMembersCache,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupMembersCacheRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'persons__id__reminders__person_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PersonsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moneyLedgerRefs(
    Expression<bool> Function($$MoneyLedgerTableFilterComposer f) f,
  ) {
    final $$MoneyLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyLedger,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyLedgerTableFilterComposer(
            $db: $db,
            $table: $db.moneyLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupMembersCacheRefs(
    Expression<bool> Function($$GroupMembersCacheTableFilterComposer f) f,
  ) {
    final $$GroupMembersCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembersCache,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupMembersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moneyLedgerRefs<T extends Object>(
    Expression<T> Function($$MoneyLedgerTableAnnotationComposer a) f,
  ) {
    final $$MoneyLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyLedger,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.moneyLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> groupMembersCacheRefs<T extends Object>(
    Expression<T> Function($$GroupMembersCacheTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupMembersCache,
          getReferencedColumn: (t) => t.personId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupMembersCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupMembersCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonsTable,
          PersonRow,
          $$PersonsTableFilterComposer,
          $$PersonsTableOrderingComposer,
          $$PersonsTableAnnotationComposer,
          $$PersonsTableCreateCompanionBuilder,
          $$PersonsTableUpdateCompanionBuilder,
          (PersonRow, $$PersonsTableReferences),
          PersonRow,
          PrefetchHooks Function({
            bool transactionsRefs,
            bool moneyLedgerRefs,
            bool groupMembersCacheRefs,
            bool remindersRefs,
          })
        > {
  $$PersonsTableTableManager(_$AppDatabase db, $PersonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                phone: phone,
                email: email,
                description: description,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime createdAt,
                required DateTime updatedAt,
                required String id,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                phone: phone,
                email: email,
                description: description,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PersonsTable, PersonRow>(table),
                  $$PersonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                transactionsRefs = false,
                moneyLedgerRefs = false,
                groupMembersCacheRefs = false,
                remindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (moneyLedgerRefs) db.moneyLedger,
                    if (groupMembersCacheRefs) db.groupMembersCache,
                    if (remindersRefs) db.reminders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          PersonRow,
                          $PersonsTable,
                          TransactionRow,
                          $TransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
                      if (moneyLedgerRefs)
                        await $_getPrefetchedDataByColumns<
                          PersonRow,
                          $PersonsTable,
                          LedgerEntryRow,
                          $MoneyLedgerTable
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._moneyLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).moneyLedgerRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
                      if (groupMembersCacheRefs)
                        await $_getPrefetchedDataByColumns<
                          PersonRow,
                          $PersonsTable,
                          GroupMemberRow,
                          $GroupMembersCacheTable
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._groupMembersCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMembersCacheRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedDataByColumns<
                          PersonRow,
                          $PersonsTable,
                          ReminderRow,
                          $RemindersTable
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PersonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonsTable,
      PersonRow,
      $$PersonsTableFilterComposer,
      $$PersonsTableOrderingComposer,
      $$PersonsTableAnnotationComposer,
      $$PersonsTableCreateCompanionBuilder,
      $$PersonsTableUpdateCompanionBuilder,
      (PersonRow, $$PersonsTableReferences),
      PersonRow,
      PrefetchHooks Function({
        bool transactionsRefs,
        bool moneyLedgerRefs,
        bool groupMembersCacheRefs,
        bool remindersRefs,
      })
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required DateTime createdAt,
      required DateTime updatedAt,
      required String id,
      required String ownerId,
      required TransactionType type,
      required int amountPaise,
      required String categoryId,
      required DateTime txnDate,
      required PaymentMethod paymentMethod,
      Value<String?> personId,
      Value<String> description,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> ownerId,
      Value<TransactionType> type,
      Value<int> amountPaise,
      Value<String> categoryId,
      Value<DateTime> txnDate,
      Value<PaymentMethod> paymentMethod,
      Value<String?> personId,
      Value<String> description,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PersonsTable _personIdTable(_$AppDatabase db) =>
      db.persons.createAlias('transactions__person_id__persons__id');

  $$PersonsTableProcessedTableManager? get personId {
    final $_column = $_itemColumn<String>('person_id');
    if ($_column == null) return null;
    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<AttachmentRow>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'transactions__id__attachments__transaction_id',
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get txnDate => $composableBuilder(
    column: $table.txnDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get txnDate => $composableBuilder(
    column: $table.txnDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get txnDate =>
      $composableBuilder(column: $table.txnDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (TransactionRow, $$TransactionsTableReferences),
          TransactionRow,
          PrefetchHooks Function({
            bool categoryId,
            bool personId,
            bool attachmentsRefs,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<TransactionType> type = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<DateTime> txnDate = const Value.absent(),
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                ownerId: ownerId,
                type: type,
                amountPaise: amountPaise,
                categoryId: categoryId,
                txnDate: txnDate,
                paymentMethod: paymentMethod,
                personId: personId,
                description: description,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime createdAt,
                required DateTime updatedAt,
                required String id,
                required String ownerId,
                required TransactionType type,
                required int amountPaise,
                required String categoryId,
                required DateTime txnDate,
                required PaymentMethod paymentMethod,
                Value<String?> personId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                ownerId: ownerId,
                type: type,
                amountPaise: amountPaise,
                categoryId: categoryId,
                txnDate: txnDate,
                paymentMethod: paymentMethod,
                personId: personId,
                description: description,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, TransactionRow>(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                personId = false,
                attachmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attachmentsRefs) db.attachments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$TransactionsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$TransactionsTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (personId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.personId,
                            referencedTable: $$TransactionsTableReferences
                                ._personIdTable(db),
                            referencedColumn: $$TransactionsTableReferences
                                ._personIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attachmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          TransactionRow,
                          $TransactionsTable,
                          AttachmentRow,
                          $AttachmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'transaction_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (TransactionRow, $$TransactionsTableReferences),
      TransactionRow,
      PrefetchHooks Function({
        bool categoryId,
        bool personId,
        bool attachmentsRefs,
      })
    >;
typedef $$MoneyLedgerTableCreateCompanionBuilder =
    MoneyLedgerCompanion Function({
      required DateTime createdAt,
      required DateTime updatedAt,
      required String id,
      required String personId,
      required LedgerDirection direction,
      required int principalPaise,
      required DateTime entryDate,
      Value<DateTime?> dueDate,
      required PaymentMethod paymentMethod,
      Value<String> description,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$MoneyLedgerTableUpdateCompanionBuilder =
    MoneyLedgerCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> personId,
      Value<LedgerDirection> direction,
      Value<int> principalPaise,
      Value<DateTime> entryDate,
      Value<DateTime?> dueDate,
      Value<PaymentMethod> paymentMethod,
      Value<String> description,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$MoneyLedgerTableReferences
    extends BaseReferences<_$AppDatabase, $MoneyLedgerTable, LedgerEntryRow> {
  $$MoneyLedgerTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PersonsTable _personIdTable(_$AppDatabase db) =>
      db.persons.createAlias('money_ledger__person_id__persons__id');

  $$PersonsTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MoneySettlementsTable, List<LedgerRepaymentRow>>
  _moneySettlementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moneySettlements,
    aliasName: 'money_ledger__id__money_settlements__ledger_id',
  );

  $$MoneySettlementsTableProcessedTableManager get moneySettlementsRefs {
    final manager = $$MoneySettlementsTableTableManager(
      $_db,
      $_db.moneySettlements,
    ).filter((f) => f.ledgerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _moneySettlementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<AttachmentRow>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'money_ledger__id__attachments__ledger_entry_id',
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.ledgerEntryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'money_ledger__id__reminders__ledger_entry_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.ledgerEntryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MoneyLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $MoneyLedgerTable> {
  $$MoneyLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LedgerDirection, LedgerDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get principalPaise => $composableBuilder(
    column: $table.principalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> moneySettlementsRefs(
    Expression<bool> Function($$MoneySettlementsTableFilterComposer f) f,
  ) {
    final $$MoneySettlementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneySettlements,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneySettlementsTableFilterComposer(
            $db: $db,
            $table: $db.moneySettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.ledgerEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.ledgerEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MoneyLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $MoneyLedgerTable> {
  $$MoneyLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get principalPaise => $composableBuilder(
    column: $table.principalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneyLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoneyLedgerTable> {
  $$MoneyLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LedgerDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get principalPaise => $composableBuilder(
    column: $table.principalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> moneySettlementsRefs<T extends Object>(
    Expression<T> Function($$MoneySettlementsTableAnnotationComposer a) f,
  ) {
    final $$MoneySettlementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneySettlements,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneySettlementsTableAnnotationComposer(
            $db: $db,
            $table: $db.moneySettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.ledgerEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.ledgerEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MoneyLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoneyLedgerTable,
          LedgerEntryRow,
          $$MoneyLedgerTableFilterComposer,
          $$MoneyLedgerTableOrderingComposer,
          $$MoneyLedgerTableAnnotationComposer,
          $$MoneyLedgerTableCreateCompanionBuilder,
          $$MoneyLedgerTableUpdateCompanionBuilder,
          (LedgerEntryRow, $$MoneyLedgerTableReferences),
          LedgerEntryRow,
          PrefetchHooks Function({
            bool personId,
            bool moneySettlementsRefs,
            bool attachmentsRefs,
            bool remindersRefs,
          })
        > {
  $$MoneyLedgerTableTableManager(_$AppDatabase db, $MoneyLedgerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoneyLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoneyLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoneyLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<LedgerDirection> direction = const Value.absent(),
                Value<int> principalPaise = const Value.absent(),
                Value<DateTime> entryDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoneyLedgerCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                personId: personId,
                direction: direction,
                principalPaise: principalPaise,
                entryDate: entryDate,
                dueDate: dueDate,
                paymentMethod: paymentMethod,
                description: description,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime createdAt,
                required DateTime updatedAt,
                required String id,
                required String personId,
                required LedgerDirection direction,
                required int principalPaise,
                required DateTime entryDate,
                Value<DateTime?> dueDate = const Value.absent(),
                required PaymentMethod paymentMethod,
                Value<String> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoneyLedgerCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                personId: personId,
                direction: direction,
                principalPaise: principalPaise,
                entryDate: entryDate,
                dueDate: dueDate,
                paymentMethod: paymentMethod,
                description: description,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MoneyLedgerTable, LedgerEntryRow>(table),
                  $$MoneyLedgerTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                personId = false,
                moneySettlementsRefs = false,
                attachmentsRefs = false,
                remindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (moneySettlementsRefs) db.moneySettlements,
                    if (attachmentsRefs) db.attachments,
                    if (remindersRefs) db.reminders,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (personId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.personId,
                            referencedTable: $$MoneyLedgerTableReferences
                                ._personIdTable(db),
                            referencedColumn: $$MoneyLedgerTableReferences
                                ._personIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (moneySettlementsRefs)
                        await $_getPrefetchedDataByColumns<
                          LedgerEntryRow,
                          $MoneyLedgerTable,
                          LedgerRepaymentRow,
                          $MoneySettlementsTable
                        >(
                          currentTable: table,
                          referencedTable: $$MoneyLedgerTableReferences
                              ._moneySettlementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MoneyLedgerTableReferences(
                                db,
                                table,
                                p0,
                              ).moneySettlementsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'ledger_id',
                          typedResults: items,
                        ),
                      if (attachmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          LedgerEntryRow,
                          $MoneyLedgerTable,
                          AttachmentRow,
                          $AttachmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$MoneyLedgerTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MoneyLedgerTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'ledger_entry_id',
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedDataByColumns<
                          LedgerEntryRow,
                          $MoneyLedgerTable,
                          ReminderRow,
                          $RemindersTable
                        >(
                          currentTable: table,
                          referencedTable: $$MoneyLedgerTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MoneyLedgerTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'ledger_entry_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MoneyLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoneyLedgerTable,
      LedgerEntryRow,
      $$MoneyLedgerTableFilterComposer,
      $$MoneyLedgerTableOrderingComposer,
      $$MoneyLedgerTableAnnotationComposer,
      $$MoneyLedgerTableCreateCompanionBuilder,
      $$MoneyLedgerTableUpdateCompanionBuilder,
      (LedgerEntryRow, $$MoneyLedgerTableReferences),
      LedgerEntryRow,
      PrefetchHooks Function({
        bool personId,
        bool moneySettlementsRefs,
        bool attachmentsRefs,
        bool remindersRefs,
      })
    >;
typedef $$MoneySettlementsTableCreateCompanionBuilder =
    MoneySettlementsCompanion Function({
      required DateTime createdAt,
      required DateTime updatedAt,
      required String id,
      required String ledgerId,
      required int amountPaise,
      required DateTime settledOn,
      required PaymentMethod paymentMethod,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$MoneySettlementsTableUpdateCompanionBuilder =
    MoneySettlementsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> ledgerId,
      Value<int> amountPaise,
      Value<DateTime> settledOn,
      Value<PaymentMethod> paymentMethod,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$MoneySettlementsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MoneySettlementsTable,
          LedgerRepaymentRow
        > {
  $$MoneySettlementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MoneyLedgerTable _ledgerIdTable(_$AppDatabase db) => db.moneyLedger
      .createAlias('money_settlements__ledger_id__money_ledger__id');

  $$MoneyLedgerTableProcessedTableManager get ledgerId {
    final $_column = $_itemColumn<String>('ledger_id')!;

    final manager = $$MoneyLedgerTableTableManager(
      $_db,
      $_db.moneyLedger,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MoneySettlementsTableFilterComposer
    extends Composer<_$AppDatabase, $MoneySettlementsTable> {
  $$MoneySettlementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settledOn => $composableBuilder(
    column: $table.settledOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$MoneyLedgerTableFilterComposer get ledgerId {
    final $$MoneyLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.moneyLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyLedgerTableFilterComposer(
            $db: $db,
            $table: $db.moneyLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneySettlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MoneySettlementsTable> {
  $$MoneySettlementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settledOn => $composableBuilder(
    column: $table.settledOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$MoneyLedgerTableOrderingComposer get ledgerId {
    final $$MoneyLedgerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.moneyLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyLedgerTableOrderingComposer(
            $db: $db,
            $table: $db.moneyLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneySettlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoneySettlementsTable> {
  $$MoneySettlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get settledOn =>
      $composableBuilder(column: $table.settledOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$MoneyLedgerTableAnnotationComposer get ledgerId {
    final $$MoneyLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.moneyLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.moneyLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneySettlementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoneySettlementsTable,
          LedgerRepaymentRow,
          $$MoneySettlementsTableFilterComposer,
          $$MoneySettlementsTableOrderingComposer,
          $$MoneySettlementsTableAnnotationComposer,
          $$MoneySettlementsTableCreateCompanionBuilder,
          $$MoneySettlementsTableUpdateCompanionBuilder,
          (LedgerRepaymentRow, $$MoneySettlementsTableReferences),
          LedgerRepaymentRow,
          PrefetchHooks Function({bool ledgerId})
        > {
  $$MoneySettlementsTableTableManager(
    _$AppDatabase db,
    $MoneySettlementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoneySettlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoneySettlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoneySettlementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> ledgerId = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<DateTime> settledOn = const Value.absent(),
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoneySettlementsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                ledgerId: ledgerId,
                amountPaise: amountPaise,
                settledOn: settledOn,
                paymentMethod: paymentMethod,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime createdAt,
                required DateTime updatedAt,
                required String id,
                required String ledgerId,
                required int amountPaise,
                required DateTime settledOn,
                required PaymentMethod paymentMethod,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoneySettlementsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                ledgerId: ledgerId,
                amountPaise: amountPaise,
                settledOn: settledOn,
                paymentMethod: paymentMethod,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MoneySettlementsTable, LedgerRepaymentRow>(
                    table,
                  ),
                  $$MoneySettlementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ledgerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ledgerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ledgerId,
                        referencedTable: $$MoneySettlementsTableReferences
                            ._ledgerIdTable(db),
                        referencedColumn: $$MoneySettlementsTableReferences
                            ._ledgerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MoneySettlementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoneySettlementsTable,
      LedgerRepaymentRow,
      $$MoneySettlementsTableFilterComposer,
      $$MoneySettlementsTableOrderingComposer,
      $$MoneySettlementsTableAnnotationComposer,
      $$MoneySettlementsTableCreateCompanionBuilder,
      $$MoneySettlementsTableUpdateCompanionBuilder,
      (LedgerRepaymentRow, $$MoneySettlementsTableReferences),
      LedgerRepaymentRow,
      PrefetchHooks Function({bool ledgerId})
    >;
typedef $$GroupsCacheTableCreateCompanionBuilder =
    GroupsCacheCompanion Function({
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> revision,
      Value<SyncState> syncState,
      Value<DateTime?> deletedAt,
      required String id,
      required String name,
      Value<String?> description,
      required GroupType groupType,
      required String createdBy,
      Value<String> currency,
      Value<GroupStatus> status,
      Value<bool> isShared,
      Value<int> rowid,
    });
typedef $$GroupsCacheTableUpdateCompanionBuilder =
    GroupsCacheCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> revision,
      Value<SyncState> syncState,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<GroupType> groupType,
      Value<String> createdBy,
      Value<String> currency,
      Value<GroupStatus> status,
      Value<bool> isShared,
      Value<int> rowid,
    });

final class $$GroupsCacheTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsCacheTable, GroupRow> {
  $$GroupsCacheTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembersCacheTable, List<GroupMemberRow>>
  _groupMembersCacheRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groupMembersCache,
        aliasName: 'groups_cache__id__group_members_cache__group_id',
      );

  $$GroupMembersCacheTableProcessedTableManager get groupMembersCacheRefs {
    final manager = $$GroupMembersCacheTableTableManager(
      $_db,
      $_db.groupMembersCache,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupMembersCacheRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupExpensesCacheTable, List<GroupExpenseRow>>
  _groupExpensesCacheRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groupExpensesCache,
        aliasName: 'groups_cache__id__group_expenses_cache__group_id',
      );

  $$GroupExpensesCacheTableProcessedTableManager get groupExpensesCacheRefs {
    final manager = $$GroupExpensesCacheTableTableManager(
      $_db,
      $_db.groupExpensesCache,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupExpensesCacheRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $GroupSettlementsCacheTable,
    List<GroupSettlementRow>
  >
  _groupSettlementsCacheRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groupSettlementsCache,
        aliasName: 'groups_cache__id__group_settlements_cache__group_id',
      );

  $$GroupSettlementsCacheTableProcessedTableManager
  get groupSettlementsCacheRefs {
    final manager = $$GroupSettlementsCacheTableTableManager(
      $_db,
      $_db.groupSettlementsCache,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupSettlementsCacheRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'groups_cache__id__reminders__group_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsCacheTable> {
  $$GroupsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GroupType, GroupType, String> get groupType =>
      $composableBuilder(
        column: $table.groupType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GroupStatus, GroupStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> groupMembersCacheRefs(
    Expression<bool> Function($$GroupMembersCacheTableFilterComposer f) f,
  ) {
    final $$GroupMembersCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembersCache,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupMembersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupExpensesCacheRefs(
    Expression<bool> Function($$GroupExpensesCacheTableFilterComposer f) f,
  ) {
    final $$GroupExpensesCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupExpensesCache,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupExpensesCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupExpensesCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupSettlementsCacheRefs(
    Expression<bool> Function($$GroupSettlementsCacheTableFilterComposer f) f,
  ) {
    final $$GroupSettlementsCacheTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupSettlementsCache,
          getReferencedColumn: (t) => t.groupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupSettlementsCacheTableFilterComposer(
                $db: $db,
                $table: $db.groupSettlementsCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsCacheTable> {
  $$GroupsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupType => $composableBuilder(
    column: $table.groupType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsCacheTable> {
  $$GroupsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GroupType, String> get groupType =>
      $composableBuilder(column: $table.groupType, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GroupStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  Expression<T> groupMembersCacheRefs<T extends Object>(
    Expression<T> Function($$GroupMembersCacheTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupMembersCache,
          getReferencedColumn: (t) => t.groupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupMembersCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupMembersCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> groupExpensesCacheRefs<T extends Object>(
    Expression<T> Function($$GroupExpensesCacheTableAnnotationComposer a) f,
  ) {
    final $$GroupExpensesCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupExpensesCache,
          getReferencedColumn: (t) => t.groupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupExpensesCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupExpensesCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> groupSettlementsCacheRefs<T extends Object>(
    Expression<T> Function($$GroupSettlementsCacheTableAnnotationComposer a) f,
  ) {
    final $$GroupSettlementsCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupSettlementsCache,
          getReferencedColumn: (t) => t.groupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupSettlementsCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupSettlementsCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupsCacheTable,
          GroupRow,
          $$GroupsCacheTableFilterComposer,
          $$GroupsCacheTableOrderingComposer,
          $$GroupsCacheTableAnnotationComposer,
          $$GroupsCacheTableCreateCompanionBuilder,
          $$GroupsCacheTableUpdateCompanionBuilder,
          (GroupRow, $$GroupsCacheTableReferences),
          GroupRow,
          PrefetchHooks Function({
            bool groupMembersCacheRefs,
            bool groupExpensesCacheRefs,
            bool groupSettlementsCacheRefs,
            bool remindersRefs,
          })
        > {
  $$GroupsCacheTableTableManager(_$AppDatabase db, $GroupsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<GroupType> groupType = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<GroupStatus> status = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCacheCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                syncState: syncState,
                deletedAt: deletedAt,
                id: id,
                name: name,
                description: description,
                groupType: groupType,
                createdBy: createdBy,
                currency: currency,
                status: status,
                isShared: isShared,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> revision = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required GroupType groupType,
                required String createdBy,
                Value<String> currency = const Value.absent(),
                Value<GroupStatus> status = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCacheCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                syncState: syncState,
                deletedAt: deletedAt,
                id: id,
                name: name,
                description: description,
                groupType: groupType,
                createdBy: createdBy,
                currency: currency,
                status: status,
                isShared: isShared,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupsCacheTable, GroupRow>(table),
                  $$GroupsCacheTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupMembersCacheRefs = false,
                groupExpensesCacheRefs = false,
                groupSettlementsCacheRefs = false,
                remindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupMembersCacheRefs) db.groupMembersCache,
                    if (groupExpensesCacheRefs) db.groupExpensesCache,
                    if (groupSettlementsCacheRefs) db.groupSettlementsCache,
                    if (remindersRefs) db.reminders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupMembersCacheRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupRow,
                          $GroupsCacheTable,
                          GroupMemberRow,
                          $GroupMembersCacheTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsCacheTableReferences
                              ._groupMembersCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsCacheTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMembersCacheRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                      if (groupExpensesCacheRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupRow,
                          $GroupsCacheTable,
                          GroupExpenseRow,
                          $GroupExpensesCacheTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsCacheTableReferences
                              ._groupExpensesCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsCacheTableReferences(
                                db,
                                table,
                                p0,
                              ).groupExpensesCacheRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                      if (groupSettlementsCacheRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupRow,
                          $GroupsCacheTable,
                          GroupSettlementRow,
                          $GroupSettlementsCacheTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsCacheTableReferences
                              ._groupSettlementsCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsCacheTableReferences(
                                db,
                                table,
                                p0,
                              ).groupSettlementsCacheRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupRow,
                          $GroupsCacheTable,
                          ReminderRow,
                          $RemindersTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsCacheTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsCacheTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GroupsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupsCacheTable,
      GroupRow,
      $$GroupsCacheTableFilterComposer,
      $$GroupsCacheTableOrderingComposer,
      $$GroupsCacheTableAnnotationComposer,
      $$GroupsCacheTableCreateCompanionBuilder,
      $$GroupsCacheTableUpdateCompanionBuilder,
      (GroupRow, $$GroupsCacheTableReferences),
      GroupRow,
      PrefetchHooks Function({
        bool groupMembersCacheRefs,
        bool groupExpensesCacheRefs,
        bool groupSettlementsCacheRefs,
        bool remindersRefs,
      })
    >;
typedef $$GroupMembersCacheTableCreateCompanionBuilder =
    GroupMembersCacheCompanion Function({
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> revision,
      Value<SyncState> syncState,
      Value<DateTime?> deletedAt,
      required String id,
      required String groupId,
      Value<String?> userId,
      required String displayName,
      Value<String?> phone,
      Value<String?> personId,
      Value<MemberRole> role,
      Value<MemberStatus> status,
      Value<bool> isSelf,
      required DateTime joinedAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$GroupMembersCacheTableUpdateCompanionBuilder =
    GroupMembersCacheCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> revision,
      Value<SyncState> syncState,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> groupId,
      Value<String?> userId,
      Value<String> displayName,
      Value<String?> phone,
      Value<String?> personId,
      Value<MemberRole> role,
      Value<MemberStatus> status,
      Value<bool> isSelf,
      Value<DateTime> joinedAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$GroupMembersCacheTableReferences
    extends
        BaseReferences<_$AppDatabase, $GroupMembersCacheTable, GroupMemberRow> {
  $$GroupMembersCacheTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupsCacheTable _groupIdTable(_$AppDatabase db) => db.groupsCache
      .createAlias('group_members_cache__group_id__groups_cache__id');

  $$GroupsCacheTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsCacheTableTableManager(
      $_db,
      $_db.groupsCache,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PersonsTable _personIdTable(_$AppDatabase db) =>
      db.persons.createAlias('group_members_cache__person_id__persons__id');

  $$PersonsTableProcessedTableManager? get personId {
    final $_column = $_itemColumn<String>('person_id');
    if ($_column == null) return null;
    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GroupExpensesCacheTable, List<GroupExpenseRow>>
  _groupExpensesCacheRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groupExpensesCache,
        aliasName:
            'group_members_cache__id__group_expenses_cache__paid_by_member_id',
      );

  $$GroupExpensesCacheTableProcessedTableManager get groupExpensesCacheRefs {
    final manager = $$GroupExpensesCacheTableTableManager(
      $_db,
      $_db.groupExpensesCache,
    ).filter((f) => f.paidByMemberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupExpensesCacheRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupExpenseSplitsCacheTable, List<GroupSplitRow>>
  _groupExpenseSplitsCacheRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groupExpenseSplitsCache,
        aliasName:
            'group_members_cache__id__group_expense_splits_cache__member_id',
      );

  $$GroupExpenseSplitsCacheTableProcessedTableManager
  get groupExpenseSplitsCacheRefs {
    final manager = $$GroupExpenseSplitsCacheTableTableManager(
      $_db,
      $_db.groupExpenseSplitsCache,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupExpenseSplitsCacheRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $GroupSettlementsCacheTable,
    List<GroupSettlementRow>
  >
  _settlementsPaidTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupSettlementsCache,
    aliasName:
        'group_members_cache__id__group_settlements_cache__from_member_id',
  );

  $$GroupSettlementsCacheTableProcessedTableManager get settlementsPaid {
    final manager = $$GroupSettlementsCacheTableTableManager(
      $_db,
      $_db.groupSettlementsCache,
    ).filter((f) => f.fromMemberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_settlementsPaidTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $GroupSettlementsCacheTable,
    List<GroupSettlementRow>
  >
  _settlementsReceivedTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupSettlementsCache,
    aliasName: 'group_members_cache__id__group_settlements_cache__to_member_id',
  );

  $$GroupSettlementsCacheTableProcessedTableManager get settlementsReceived {
    final manager = $$GroupSettlementsCacheTableTableManager(
      $_db,
      $_db.groupSettlementsCache,
    ).filter((f) => f.toMemberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _settlementsReceivedTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupMembersCacheTableFilterComposer
    extends Composer<_$AppDatabase, $GroupMembersCacheTable> {
  $$GroupMembersCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MemberRole, MemberRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<MemberStatus, MemberStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isSelf => $composableBuilder(
    column: $table.isSelf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsCacheTableFilterComposer get groupId {
    final $$GroupsCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> groupExpensesCacheRefs(
    Expression<bool> Function($$GroupExpensesCacheTableFilterComposer f) f,
  ) {
    final $$GroupExpensesCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupExpensesCache,
      getReferencedColumn: (t) => t.paidByMemberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupExpensesCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupExpensesCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupExpenseSplitsCacheRefs(
    Expression<bool> Function($$GroupExpenseSplitsCacheTableFilterComposer f) f,
  ) {
    final $$GroupExpenseSplitsCacheTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupExpenseSplitsCache,
          getReferencedColumn: (t) => t.memberId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupExpenseSplitsCacheTableFilterComposer(
                $db: $db,
                $table: $db.groupExpenseSplitsCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> settlementsPaid(
    Expression<bool> Function($$GroupSettlementsCacheTableFilterComposer f) f,
  ) {
    final $$GroupSettlementsCacheTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupSettlementsCache,
          getReferencedColumn: (t) => t.fromMemberId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupSettlementsCacheTableFilterComposer(
                $db: $db,
                $table: $db.groupSettlementsCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> settlementsReceived(
    Expression<bool> Function($$GroupSettlementsCacheTableFilterComposer f) f,
  ) {
    final $$GroupSettlementsCacheTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupSettlementsCache,
          getReferencedColumn: (t) => t.toMemberId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupSettlementsCacheTableFilterComposer(
                $db: $db,
                $table: $db.groupSettlementsCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GroupMembersCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupMembersCacheTable> {
  $$GroupMembersCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSelf => $composableBuilder(
    column: $table.isSelf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsCacheTableOrderingComposer get groupId {
    final $$GroupsCacheTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableOrderingComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupMembersCacheTable> {
  $$GroupMembersCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MemberRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MemberStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isSelf =>
      $composableBuilder(column: $table.isSelf, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$GroupsCacheTableAnnotationComposer get groupId {
    final $$GroupsCacheTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableAnnotationComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> groupExpensesCacheRefs<T extends Object>(
    Expression<T> Function($$GroupExpensesCacheTableAnnotationComposer a) f,
  ) {
    final $$GroupExpensesCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupExpensesCache,
          getReferencedColumn: (t) => t.paidByMemberId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupExpensesCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupExpensesCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> groupExpenseSplitsCacheRefs<T extends Object>(
    Expression<T> Function($$GroupExpenseSplitsCacheTableAnnotationComposer a)
    f,
  ) {
    final $$GroupExpenseSplitsCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupExpenseSplitsCache,
          getReferencedColumn: (t) => t.memberId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupExpenseSplitsCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupExpenseSplitsCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> settlementsPaid<T extends Object>(
    Expression<T> Function($$GroupSettlementsCacheTableAnnotationComposer a) f,
  ) {
    final $$GroupSettlementsCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupSettlementsCache,
          getReferencedColumn: (t) => t.fromMemberId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupSettlementsCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupSettlementsCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> settlementsReceived<T extends Object>(
    Expression<T> Function($$GroupSettlementsCacheTableAnnotationComposer a) f,
  ) {
    final $$GroupSettlementsCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupSettlementsCache,
          getReferencedColumn: (t) => t.toMemberId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupSettlementsCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupSettlementsCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GroupMembersCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupMembersCacheTable,
          GroupMemberRow,
          $$GroupMembersCacheTableFilterComposer,
          $$GroupMembersCacheTableOrderingComposer,
          $$GroupMembersCacheTableAnnotationComposer,
          $$GroupMembersCacheTableCreateCompanionBuilder,
          $$GroupMembersCacheTableUpdateCompanionBuilder,
          (GroupMemberRow, $$GroupMembersCacheTableReferences),
          GroupMemberRow,
          PrefetchHooks Function({
            bool groupId,
            bool personId,
            bool groupExpensesCacheRefs,
            bool groupExpenseSplitsCacheRefs,
            bool settlementsPaid,
            bool settlementsReceived,
          })
        > {
  $$GroupMembersCacheTableTableManager(
    _$AppDatabase db,
    $GroupMembersCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMembersCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMembersCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMembersCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<MemberRole> role = const Value.absent(),
                Value<MemberStatus> status = const Value.absent(),
                Value<bool> isSelf = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupMembersCacheCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                syncState: syncState,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                userId: userId,
                displayName: displayName,
                phone: phone,
                personId: personId,
                role: role,
                status: status,
                isSelf: isSelf,
                joinedAt: joinedAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> revision = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String groupId,
                Value<String?> userId = const Value.absent(),
                required String displayName,
                Value<String?> phone = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<MemberRole> role = const Value.absent(),
                Value<MemberStatus> status = const Value.absent(),
                Value<bool> isSelf = const Value.absent(),
                required DateTime joinedAt,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupMembersCacheCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                syncState: syncState,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                userId: userId,
                displayName: displayName,
                phone: phone,
                personId: personId,
                role: role,
                status: status,
                isSelf: isSelf,
                joinedAt: joinedAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupMembersCacheTable, GroupMemberRow>(table),
                  $$GroupMembersCacheTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupId = false,
                personId = false,
                groupExpensesCacheRefs = false,
                groupExpenseSplitsCacheRefs = false,
                settlementsPaid = false,
                settlementsReceived = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupExpensesCacheRefs) db.groupExpensesCache,
                    if (groupExpenseSplitsCacheRefs) db.groupExpenseSplitsCache,
                    if (settlementsPaid) db.groupSettlementsCache,
                    if (settlementsReceived) db.groupSettlementsCache,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (groupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$GroupMembersCacheTableReferences
                                ._groupIdTable(db),
                            referencedColumn: $$GroupMembersCacheTableReferences
                                ._groupIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (personId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.personId,
                            referencedTable: $$GroupMembersCacheTableReferences
                                ._personIdTable(db),
                            referencedColumn: $$GroupMembersCacheTableReferences
                                ._personIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupExpensesCacheRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupMemberRow,
                          $GroupMembersCacheTable,
                          GroupExpenseRow,
                          $GroupExpensesCacheTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupMembersCacheTableReferences
                              ._groupExpensesCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupMembersCacheTableReferences(
                                db,
                                table,
                                p0,
                              ).groupExpensesCacheRefs,
                          currentColumn: 'id',
                          referencedColumn: 'paid_by_member_id',
                          typedResults: items,
                        ),
                      if (groupExpenseSplitsCacheRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupMemberRow,
                          $GroupMembersCacheTable,
                          GroupSplitRow,
                          $GroupExpenseSplitsCacheTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupMembersCacheTableReferences
                              ._groupExpenseSplitsCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupMembersCacheTableReferences(
                                db,
                                table,
                                p0,
                              ).groupExpenseSplitsCacheRefs,
                          currentColumn: 'id',
                          referencedColumn: 'member_id',
                          typedResults: items,
                        ),
                      if (settlementsPaid)
                        await $_getPrefetchedDataByColumns<
                          GroupMemberRow,
                          $GroupMembersCacheTable,
                          GroupSettlementRow,
                          $GroupSettlementsCacheTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupMembersCacheTableReferences
                              ._settlementsPaidTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupMembersCacheTableReferences(
                                db,
                                table,
                                p0,
                              ).settlementsPaid,
                          currentColumn: 'id',
                          referencedColumn: 'from_member_id',
                          typedResults: items,
                        ),
                      if (settlementsReceived)
                        await $_getPrefetchedDataByColumns<
                          GroupMemberRow,
                          $GroupMembersCacheTable,
                          GroupSettlementRow,
                          $GroupSettlementsCacheTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupMembersCacheTableReferences
                              ._settlementsReceivedTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupMembersCacheTableReferences(
                                db,
                                table,
                                p0,
                              ).settlementsReceived,
                          currentColumn: 'id',
                          referencedColumn: 'to_member_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GroupMembersCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupMembersCacheTable,
      GroupMemberRow,
      $$GroupMembersCacheTableFilterComposer,
      $$GroupMembersCacheTableOrderingComposer,
      $$GroupMembersCacheTableAnnotationComposer,
      $$GroupMembersCacheTableCreateCompanionBuilder,
      $$GroupMembersCacheTableUpdateCompanionBuilder,
      (GroupMemberRow, $$GroupMembersCacheTableReferences),
      GroupMemberRow,
      PrefetchHooks Function({
        bool groupId,
        bool personId,
        bool groupExpensesCacheRefs,
        bool groupExpenseSplitsCacheRefs,
        bool settlementsPaid,
        bool settlementsReceived,
      })
    >;
typedef $$GroupExpensesCacheTableCreateCompanionBuilder =
    GroupExpensesCacheCompanion Function({
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> revision,
      Value<SyncState> syncState,
      Value<DateTime?> deletedAt,
      required String id,
      required String groupId,
      required String description,
      required String categoryKey,
      required int amountPaise,
      required String paidByMemberId,
      required DateTime expenseDate,
      required SplitMethod splitMethod,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$GroupExpensesCacheTableUpdateCompanionBuilder =
    GroupExpensesCacheCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> revision,
      Value<SyncState> syncState,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> groupId,
      Value<String> description,
      Value<String> categoryKey,
      Value<int> amountPaise,
      Value<String> paidByMemberId,
      Value<DateTime> expenseDate,
      Value<SplitMethod> splitMethod,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$GroupExpensesCacheTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GroupExpensesCacheTable,
          GroupExpenseRow
        > {
  $$GroupExpensesCacheTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupsCacheTable _groupIdTable(_$AppDatabase db) => db.groupsCache
      .createAlias('group_expenses_cache__group_id__groups_cache__id');

  $$GroupsCacheTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsCacheTableTableManager(
      $_db,
      $_db.groupsCache,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupMembersCacheTable _paidByMemberIdTable(_$AppDatabase db) =>
      db.groupMembersCache.createAlias(
        'group_expenses_cache__paid_by_member_id__group_members_cache__id',
      );

  $$GroupMembersCacheTableProcessedTableManager get paidByMemberId {
    final $_column = $_itemColumn<String>('paid_by_member_id')!;

    final manager = $$GroupMembersCacheTableTableManager(
      $_db,
      $_db.groupMembersCache,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paidByMemberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GroupExpenseSplitsCacheTable, List<GroupSplitRow>>
  _groupExpenseSplitsCacheRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groupExpenseSplitsCache,
        aliasName:
            'group_expenses_cache__id__group_expense_splits_cache__expense_id',
      );

  $$GroupExpenseSplitsCacheTableProcessedTableManager
  get groupExpenseSplitsCacheRefs {
    final manager = $$GroupExpenseSplitsCacheTableTableManager(
      $_db,
      $_db.groupExpenseSplitsCache,
    ).filter((f) => f.expenseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupExpenseSplitsCacheRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<AttachmentRow>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'group_expenses_cache__id__attachments__group_expense_id',
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.groupExpenseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupExpensesCacheTableFilterComposer
    extends Composer<_$AppDatabase, $GroupExpensesCacheTable> {
  $$GroupExpensesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SplitMethod, SplitMethod, String>
  get splitMethod => $composableBuilder(
    column: $table.splitMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsCacheTableFilterComposer get groupId {
    final $$GroupsCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupMembersCacheTableFilterComposer get paidByMemberId {
    final $$GroupMembersCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidByMemberId,
      referencedTable: $db.groupMembersCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupMembersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> groupExpenseSplitsCacheRefs(
    Expression<bool> Function($$GroupExpenseSplitsCacheTableFilterComposer f) f,
  ) {
    final $$GroupExpenseSplitsCacheTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupExpenseSplitsCache,
          getReferencedColumn: (t) => t.expenseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupExpenseSplitsCacheTableFilterComposer(
                $db: $db,
                $table: $db.groupExpenseSplitsCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.groupExpenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupExpensesCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupExpensesCacheTable> {
  $$GroupExpensesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get splitMethod => $composableBuilder(
    column: $table.splitMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsCacheTableOrderingComposer get groupId {
    final $$GroupsCacheTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableOrderingComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupMembersCacheTableOrderingComposer get paidByMemberId {
    final $$GroupMembersCacheTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidByMemberId,
      referencedTable: $db.groupMembersCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersCacheTableOrderingComposer(
            $db: $db,
            $table: $db.groupMembersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupExpensesCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupExpensesCacheTable> {
  $$GroupExpensesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SplitMethod, String> get splitMethod =>
      $composableBuilder(
        column: $table.splitMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$GroupsCacheTableAnnotationComposer get groupId {
    final $$GroupsCacheTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableAnnotationComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupMembersCacheTableAnnotationComposer get paidByMemberId {
    final $$GroupMembersCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.paidByMemberId,
          referencedTable: $db.groupMembersCache,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupMembersCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupMembersCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> groupExpenseSplitsCacheRefs<T extends Object>(
    Expression<T> Function($$GroupExpenseSplitsCacheTableAnnotationComposer a)
    f,
  ) {
    final $$GroupExpenseSplitsCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groupExpenseSplitsCache,
          getReferencedColumn: (t) => t.expenseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupExpenseSplitsCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupExpenseSplitsCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.groupExpenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupExpensesCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupExpensesCacheTable,
          GroupExpenseRow,
          $$GroupExpensesCacheTableFilterComposer,
          $$GroupExpensesCacheTableOrderingComposer,
          $$GroupExpensesCacheTableAnnotationComposer,
          $$GroupExpensesCacheTableCreateCompanionBuilder,
          $$GroupExpensesCacheTableUpdateCompanionBuilder,
          (GroupExpenseRow, $$GroupExpensesCacheTableReferences),
          GroupExpenseRow,
          PrefetchHooks Function({
            bool groupId,
            bool paidByMemberId,
            bool groupExpenseSplitsCacheRefs,
            bool attachmentsRefs,
          })
        > {
  $$GroupExpensesCacheTableTableManager(
    _$AppDatabase db,
    $GroupExpensesCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupExpensesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupExpensesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupExpensesCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> paidByMemberId = const Value.absent(),
                Value<DateTime> expenseDate = const Value.absent(),
                Value<SplitMethod> splitMethod = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupExpensesCacheCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                syncState: syncState,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                description: description,
                categoryKey: categoryKey,
                amountPaise: amountPaise,
                paidByMemberId: paidByMemberId,
                expenseDate: expenseDate,
                splitMethod: splitMethod,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> revision = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String groupId,
                required String description,
                required String categoryKey,
                required int amountPaise,
                required String paidByMemberId,
                required DateTime expenseDate,
                required SplitMethod splitMethod,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupExpensesCacheCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                syncState: syncState,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                description: description,
                categoryKey: categoryKey,
                amountPaise: amountPaise,
                paidByMemberId: paidByMemberId,
                expenseDate: expenseDate,
                splitMethod: splitMethod,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupExpensesCacheTable, GroupExpenseRow>(table),
                  $$GroupExpensesCacheTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupId = false,
                paidByMemberId = false,
                groupExpenseSplitsCacheRefs = false,
                attachmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupExpenseSplitsCacheRefs) db.groupExpenseSplitsCache,
                    if (attachmentsRefs) db.attachments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (groupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$GroupExpensesCacheTableReferences
                                ._groupIdTable(db),
                            referencedColumn:
                                $$GroupExpensesCacheTableReferences
                                    ._groupIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (paidByMemberId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.paidByMemberId,
                            referencedTable: $$GroupExpensesCacheTableReferences
                                ._paidByMemberIdTable(db),
                            referencedColumn:
                                $$GroupExpensesCacheTableReferences
                                    ._paidByMemberIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupExpenseSplitsCacheRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupExpenseRow,
                          $GroupExpensesCacheTable,
                          GroupSplitRow,
                          $GroupExpenseSplitsCacheTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupExpensesCacheTableReferences
                              ._groupExpenseSplitsCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupExpensesCacheTableReferences(
                                db,
                                table,
                                p0,
                              ).groupExpenseSplitsCacheRefs,
                          currentColumn: 'id',
                          referencedColumn: 'expense_id',
                          typedResults: items,
                        ),
                      if (attachmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupExpenseRow,
                          $GroupExpensesCacheTable,
                          AttachmentRow,
                          $AttachmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupExpensesCacheTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupExpensesCacheTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_expense_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GroupExpensesCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupExpensesCacheTable,
      GroupExpenseRow,
      $$GroupExpensesCacheTableFilterComposer,
      $$GroupExpensesCacheTableOrderingComposer,
      $$GroupExpensesCacheTableAnnotationComposer,
      $$GroupExpensesCacheTableCreateCompanionBuilder,
      $$GroupExpensesCacheTableUpdateCompanionBuilder,
      (GroupExpenseRow, $$GroupExpensesCacheTableReferences),
      GroupExpenseRow,
      PrefetchHooks Function({
        bool groupId,
        bool paidByMemberId,
        bool groupExpenseSplitsCacheRefs,
        bool attachmentsRefs,
      })
    >;
typedef $$GroupExpenseSplitsCacheTableCreateCompanionBuilder =
    GroupExpenseSplitsCacheCompanion Function({
      required String id,
      required String expenseId,
      required String memberId,
      required int sharePaise,
      Value<int?> inputValue,
      Value<int> rowid,
    });
typedef $$GroupExpenseSplitsCacheTableUpdateCompanionBuilder =
    GroupExpenseSplitsCacheCompanion Function({
      Value<String> id,
      Value<String> expenseId,
      Value<String> memberId,
      Value<int> sharePaise,
      Value<int?> inputValue,
      Value<int> rowid,
    });

final class $$GroupExpenseSplitsCacheTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GroupExpenseSplitsCacheTable,
          GroupSplitRow
        > {
  $$GroupExpenseSplitsCacheTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupExpensesCacheTable _expenseIdTable(_$AppDatabase db) =>
      db.groupExpensesCache.createAlias(
        'group_expense_splits_cache__expense_id__group_expenses_cache__id',
      );

  $$GroupExpensesCacheTableProcessedTableManager get expenseId {
    final $_column = $_itemColumn<String>('expense_id')!;

    final manager = $$GroupExpensesCacheTableTableManager(
      $_db,
      $_db.groupExpensesCache,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupMembersCacheTable _memberIdTable(_$AppDatabase db) =>
      db.groupMembersCache.createAlias(
        'group_expense_splits_cache__member_id__group_members_cache__id',
      );

  $$GroupMembersCacheTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<String>('member_id')!;

    final manager = $$GroupMembersCacheTableTableManager(
      $_db,
      $_db.groupMembersCache,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupExpenseSplitsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $GroupExpenseSplitsCacheTable> {
  $$GroupExpenseSplitsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sharePaise => $composableBuilder(
    column: $table.sharePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inputValue => $composableBuilder(
    column: $table.inputValue,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupExpensesCacheTableFilterComposer get expenseId {
    final $$GroupExpensesCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.groupExpensesCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupExpensesCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupExpensesCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupMembersCacheTableFilterComposer get memberId {
    final $$GroupMembersCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.groupMembersCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupMembersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupExpenseSplitsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupExpenseSplitsCacheTable> {
  $$GroupExpenseSplitsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sharePaise => $composableBuilder(
    column: $table.sharePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inputValue => $composableBuilder(
    column: $table.inputValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupExpensesCacheTableOrderingComposer get expenseId {
    final $$GroupExpensesCacheTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.groupExpensesCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupExpensesCacheTableOrderingComposer(
            $db: $db,
            $table: $db.groupExpensesCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupMembersCacheTableOrderingComposer get memberId {
    final $$GroupMembersCacheTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.groupMembersCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersCacheTableOrderingComposer(
            $db: $db,
            $table: $db.groupMembersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupExpenseSplitsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupExpenseSplitsCacheTable> {
  $$GroupExpenseSplitsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sharePaise => $composableBuilder(
    column: $table.sharePaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get inputValue => $composableBuilder(
    column: $table.inputValue,
    builder: (column) => column,
  );

  $$GroupExpensesCacheTableAnnotationComposer get expenseId {
    final $$GroupExpensesCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.expenseId,
          referencedTable: $db.groupExpensesCache,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupExpensesCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupExpensesCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$GroupMembersCacheTableAnnotationComposer get memberId {
    final $$GroupMembersCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.memberId,
          referencedTable: $db.groupMembersCache,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupMembersCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupMembersCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GroupExpenseSplitsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupExpenseSplitsCacheTable,
          GroupSplitRow,
          $$GroupExpenseSplitsCacheTableFilterComposer,
          $$GroupExpenseSplitsCacheTableOrderingComposer,
          $$GroupExpenseSplitsCacheTableAnnotationComposer,
          $$GroupExpenseSplitsCacheTableCreateCompanionBuilder,
          $$GroupExpenseSplitsCacheTableUpdateCompanionBuilder,
          (GroupSplitRow, $$GroupExpenseSplitsCacheTableReferences),
          GroupSplitRow,
          PrefetchHooks Function({bool expenseId, bool memberId})
        > {
  $$GroupExpenseSplitsCacheTableTableManager(
    _$AppDatabase db,
    $GroupExpenseSplitsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupExpenseSplitsCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$GroupExpenseSplitsCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GroupExpenseSplitsCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> expenseId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<int> sharePaise = const Value.absent(),
                Value<int?> inputValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupExpenseSplitsCacheCompanion(
                id: id,
                expenseId: expenseId,
                memberId: memberId,
                sharePaise: sharePaise,
                inputValue: inputValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String expenseId,
                required String memberId,
                required int sharePaise,
                Value<int?> inputValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupExpenseSplitsCacheCompanion.insert(
                id: id,
                expenseId: expenseId,
                memberId: memberId,
                sharePaise: sharePaise,
                inputValue: inputValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupExpenseSplitsCacheTable, GroupSplitRow>(
                    table,
                  ),
                  $$GroupExpenseSplitsCacheTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expenseId = false, memberId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (expenseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.expenseId,
                        referencedTable:
                            $$GroupExpenseSplitsCacheTableReferences
                                ._expenseIdTable(db),
                        referencedColumn:
                            $$GroupExpenseSplitsCacheTableReferences
                                ._expenseIdTable(db)
                                .id,
                      ) as T;
                    }
                    if (memberId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.memberId,
                        referencedTable:
                            $$GroupExpenseSplitsCacheTableReferences
                                ._memberIdTable(db),
                        referencedColumn:
                            $$GroupExpenseSplitsCacheTableReferences
                                ._memberIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroupExpenseSplitsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupExpenseSplitsCacheTable,
      GroupSplitRow,
      $$GroupExpenseSplitsCacheTableFilterComposer,
      $$GroupExpenseSplitsCacheTableOrderingComposer,
      $$GroupExpenseSplitsCacheTableAnnotationComposer,
      $$GroupExpenseSplitsCacheTableCreateCompanionBuilder,
      $$GroupExpenseSplitsCacheTableUpdateCompanionBuilder,
      (GroupSplitRow, $$GroupExpenseSplitsCacheTableReferences),
      GroupSplitRow,
      PrefetchHooks Function({bool expenseId, bool memberId})
    >;
typedef $$GroupSettlementsCacheTableCreateCompanionBuilder =
    GroupSettlementsCacheCompanion Function({
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> revision,
      Value<SyncState> syncState,
      Value<DateTime?> deletedAt,
      required String id,
      required String groupId,
      required String fromMemberId,
      required String toMemberId,
      required int amountPaise,
      required DateTime settledOn,
      required PaymentMethod paymentMethod,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$GroupSettlementsCacheTableUpdateCompanionBuilder =
    GroupSettlementsCacheCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> revision,
      Value<SyncState> syncState,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> groupId,
      Value<String> fromMemberId,
      Value<String> toMemberId,
      Value<int> amountPaise,
      Value<DateTime> settledOn,
      Value<PaymentMethod> paymentMethod,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$GroupSettlementsCacheTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GroupSettlementsCacheTable,
          GroupSettlementRow
        > {
  $$GroupSettlementsCacheTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupsCacheTable _groupIdTable(_$AppDatabase db) => db.groupsCache
      .createAlias('group_settlements_cache__group_id__groups_cache__id');

  $$GroupsCacheTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsCacheTableTableManager(
      $_db,
      $_db.groupsCache,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupMembersCacheTable _fromMemberIdTable(_$AppDatabase db) =>
      db.groupMembersCache.createAlias(
        'group_settlements_cache__from_member_id__group_members_cache__id',
      );

  $$GroupMembersCacheTableProcessedTableManager get fromMemberId {
    final $_column = $_itemColumn<String>('from_member_id')!;

    final manager = $$GroupMembersCacheTableTableManager(
      $_db,
      $_db.groupMembersCache,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromMemberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupMembersCacheTable _toMemberIdTable(_$AppDatabase db) =>
      db.groupMembersCache.createAlias(
        'group_settlements_cache__to_member_id__group_members_cache__id',
      );

  $$GroupMembersCacheTableProcessedTableManager get toMemberId {
    final $_column = $_itemColumn<String>('to_member_id')!;

    final manager = $$GroupMembersCacheTableTableManager(
      $_db,
      $_db.groupMembersCache,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toMemberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupSettlementsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $GroupSettlementsCacheTable> {
  $$GroupSettlementsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settledOn => $composableBuilder(
    column: $table.settledOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsCacheTableFilterComposer get groupId {
    final $$GroupsCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupMembersCacheTableFilterComposer get fromMemberId {
    final $$GroupMembersCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromMemberId,
      referencedTable: $db.groupMembersCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupMembersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupMembersCacheTableFilterComposer get toMemberId {
    final $$GroupMembersCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toMemberId,
      referencedTable: $db.groupMembersCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupMembersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupSettlementsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupSettlementsCacheTable> {
  $$GroupSettlementsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settledOn => $composableBuilder(
    column: $table.settledOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsCacheTableOrderingComposer get groupId {
    final $$GroupsCacheTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableOrderingComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupMembersCacheTableOrderingComposer get fromMemberId {
    final $$GroupMembersCacheTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromMemberId,
      referencedTable: $db.groupMembersCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersCacheTableOrderingComposer(
            $db: $db,
            $table: $db.groupMembersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupMembersCacheTableOrderingComposer get toMemberId {
    final $$GroupMembersCacheTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toMemberId,
      referencedTable: $db.groupMembersCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersCacheTableOrderingComposer(
            $db: $db,
            $table: $db.groupMembersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupSettlementsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupSettlementsCacheTable> {
  $$GroupSettlementsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get settledOn =>
      $composableBuilder(column: $table.settledOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$GroupsCacheTableAnnotationComposer get groupId {
    final $$GroupsCacheTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableAnnotationComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupMembersCacheTableAnnotationComposer get fromMemberId {
    final $$GroupMembersCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.fromMemberId,
          referencedTable: $db.groupMembersCache,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupMembersCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupMembersCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$GroupMembersCacheTableAnnotationComposer get toMemberId {
    final $$GroupMembersCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.toMemberId,
          referencedTable: $db.groupMembersCache,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupMembersCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupMembersCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GroupSettlementsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupSettlementsCacheTable,
          GroupSettlementRow,
          $$GroupSettlementsCacheTableFilterComposer,
          $$GroupSettlementsCacheTableOrderingComposer,
          $$GroupSettlementsCacheTableAnnotationComposer,
          $$GroupSettlementsCacheTableCreateCompanionBuilder,
          $$GroupSettlementsCacheTableUpdateCompanionBuilder,
          (GroupSettlementRow, $$GroupSettlementsCacheTableReferences),
          GroupSettlementRow,
          PrefetchHooks Function({
            bool groupId,
            bool fromMemberId,
            bool toMemberId,
          })
        > {
  $$GroupSettlementsCacheTableTableManager(
    _$AppDatabase db,
    $GroupSettlementsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupSettlementsCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$GroupSettlementsCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GroupSettlementsCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> fromMemberId = const Value.absent(),
                Value<String> toMemberId = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<DateTime> settledOn = const Value.absent(),
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupSettlementsCacheCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                syncState: syncState,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                fromMemberId: fromMemberId,
                toMemberId: toMemberId,
                amountPaise: amountPaise,
                settledOn: settledOn,
                paymentMethod: paymentMethod,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> revision = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String groupId,
                required String fromMemberId,
                required String toMemberId,
                required int amountPaise,
                required DateTime settledOn,
                required PaymentMethod paymentMethod,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupSettlementsCacheCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                syncState: syncState,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                fromMemberId: fromMemberId,
                toMemberId: toMemberId,
                amountPaise: amountPaise,
                settledOn: settledOn,
                paymentMethod: paymentMethod,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupSettlementsCacheTable, GroupSettlementRow>(
                    table,
                  ),
                  $$GroupSettlementsCacheTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({groupId = false, fromMemberId = false, toMemberId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (groupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable:
                                $$GroupSettlementsCacheTableReferences
                                    ._groupIdTable(db),
                            referencedColumn:
                                $$GroupSettlementsCacheTableReferences
                                    ._groupIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (fromMemberId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fromMemberId,
                            referencedTable:
                                $$GroupSettlementsCacheTableReferences
                                    ._fromMemberIdTable(db),
                            referencedColumn:
                                $$GroupSettlementsCacheTableReferences
                                    ._fromMemberIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (toMemberId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.toMemberId,
                            referencedTable:
                                $$GroupSettlementsCacheTableReferences
                                    ._toMemberIdTable(db),
                            referencedColumn:
                                $$GroupSettlementsCacheTableReferences
                                    ._toMemberIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$GroupSettlementsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupSettlementsCacheTable,
      GroupSettlementRow,
      $$GroupSettlementsCacheTableFilterComposer,
      $$GroupSettlementsCacheTableOrderingComposer,
      $$GroupSettlementsCacheTableAnnotationComposer,
      $$GroupSettlementsCacheTableCreateCompanionBuilder,
      $$GroupSettlementsCacheTableUpdateCompanionBuilder,
      (GroupSettlementRow, $$GroupSettlementsCacheTableReferences),
      GroupSettlementRow,
      PrefetchHooks Function({bool groupId, bool fromMemberId, bool toMemberId})
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      Value<String?> transactionId,
      Value<String?> ledgerEntryId,
      Value<String?> groupExpenseId,
      required String storedName,
      required String originalName,
      required String mimeType,
      required int sizeBytes,
      required String sha256,
      Value<String?> remotePath,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String?> transactionId,
      Value<String?> ledgerEntryId,
      Value<String?> groupExpenseId,
      Value<String> storedName,
      Value<String> originalName,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<String> sha256,
      Value<String?> remotePath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) => db
      .transactions
      .createAlias('attachments__transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager? get transactionId {
    final $_column = $_itemColumn<String>('transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MoneyLedgerTable _ledgerEntryIdTable(_$AppDatabase db) => db
      .moneyLedger
      .createAlias('attachments__ledger_entry_id__money_ledger__id');

  $$MoneyLedgerTableProcessedTableManager? get ledgerEntryId {
    final $_column = $_itemColumn<String>('ledger_entry_id');
    if ($_column == null) return null;
    final manager = $$MoneyLedgerTableTableManager(
      $_db,
      $_db.moneyLedger,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupExpensesCacheTable _groupExpenseIdTable(_$AppDatabase db) => db
      .groupExpensesCache
      .createAlias('attachments__group_expense_id__group_expenses_cache__id');

  $$GroupExpensesCacheTableProcessedTableManager? get groupExpenseId {
    final $_column = $_itemColumn<String>('group_expense_id');
    if ($_column == null) return null;
    final manager = $$GroupExpensesCacheTableTableManager(
      $_db,
      $_db.groupExpensesCache,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupExpenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storedName => $composableBuilder(
    column: $table.storedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoneyLedgerTableFilterComposer get ledgerEntryId {
    final $$MoneyLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerEntryId,
      referencedTable: $db.moneyLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyLedgerTableFilterComposer(
            $db: $db,
            $table: $db.moneyLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupExpensesCacheTableFilterComposer get groupExpenseId {
    final $$GroupExpensesCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupExpenseId,
      referencedTable: $db.groupExpensesCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupExpensesCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupExpensesCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storedName => $composableBuilder(
    column: $table.storedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoneyLedgerTableOrderingComposer get ledgerEntryId {
    final $$MoneyLedgerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerEntryId,
      referencedTable: $db.moneyLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyLedgerTableOrderingComposer(
            $db: $db,
            $table: $db.moneyLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupExpensesCacheTableOrderingComposer get groupExpenseId {
    final $$GroupExpensesCacheTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupExpenseId,
      referencedTable: $db.groupExpensesCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupExpensesCacheTableOrderingComposer(
            $db: $db,
            $table: $db.groupExpensesCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storedName => $composableBuilder(
    column: $table.storedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoneyLedgerTableAnnotationComposer get ledgerEntryId {
    final $$MoneyLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerEntryId,
      referencedTable: $db.moneyLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.moneyLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupExpensesCacheTableAnnotationComposer get groupExpenseId {
    final $$GroupExpensesCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupExpenseId,
          referencedTable: $db.groupExpensesCache,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupExpensesCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.groupExpensesCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          AttachmentRow,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (AttachmentRow, $$AttachmentsTableReferences),
          AttachmentRow,
          PrefetchHooks Function({
            bool transactionId,
            bool ledgerEntryId,
            bool groupExpenseId,
          })
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> transactionId = const Value.absent(),
                Value<String?> ledgerEntryId = const Value.absent(),
                Value<String?> groupExpenseId = const Value.absent(),
                Value<String> storedName = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String?> remotePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                transactionId: transactionId,
                ledgerEntryId: ledgerEntryId,
                groupExpenseId: groupExpenseId,
                storedName: storedName,
                originalName: originalName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                sha256: sha256,
                remotePath: remotePath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> transactionId = const Value.absent(),
                Value<String?> ledgerEntryId = const Value.absent(),
                Value<String?> groupExpenseId = const Value.absent(),
                required String storedName,
                required String originalName,
                required String mimeType,
                required int sizeBytes,
                required String sha256,
                Value<String?> remotePath = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                transactionId: transactionId,
                ledgerEntryId: ledgerEntryId,
                groupExpenseId: groupExpenseId,
                storedName: storedName,
                originalName: originalName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                sha256: sha256,
                remotePath: remotePath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttachmentsTable, AttachmentRow>(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                transactionId = false,
                ledgerEntryId = false,
                groupExpenseId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (transactionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.transactionId,
                            referencedTable: $$AttachmentsTableReferences
                                ._transactionIdTable(db),
                            referencedColumn: $$AttachmentsTableReferences
                                ._transactionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (ledgerEntryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.ledgerEntryId,
                            referencedTable: $$AttachmentsTableReferences
                                ._ledgerEntryIdTable(db),
                            referencedColumn: $$AttachmentsTableReferences
                                ._ledgerEntryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (groupExpenseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupExpenseId,
                            referencedTable: $$AttachmentsTableReferences
                                ._groupExpenseIdTable(db),
                            referencedColumn: $$AttachmentsTableReferences
                                ._groupExpenseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      AttachmentRow,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (AttachmentRow, $$AttachmentsTableReferences),
      AttachmentRow,
      PrefetchHooks Function({
        bool transactionId,
        bool ledgerEntryId,
        bool groupExpenseId,
      })
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required DateTime createdAt,
  required DateTime updatedAt,
  required String id,
  required ReminderKind kind,
  required String title,
  Value<String?> note,
  required DateTime dueAt,
  Value<ReminderRepeat> repeat,
  Value<String?> personId,
  Value<String?> ledgerEntryId,
  Value<String?> groupId,
  Value<int?> amountPaise,
  Value<String?> categoryId,
  Value<int?> anchorDay,
  Value<int?> totalOccurrences,
  Value<int> completedOccurrences,
  required int notificationId,
  Value<ReminderStatus> status,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> id,
  Value<ReminderKind> kind,
  Value<String> title,
  Value<String?> note,
  Value<DateTime> dueAt,
  Value<ReminderRepeat> repeat,
  Value<String?> personId,
  Value<String?> ledgerEntryId,
  Value<String?> groupId,
  Value<int?> amountPaise,
  Value<String?> categoryId,
  Value<int?> anchorDay,
  Value<int?> totalOccurrences,
  Value<int> completedOccurrences,
  Value<int> notificationId,
  Value<ReminderStatus> status,
  Value<int> rowid,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PersonsTable _personIdTable(_$AppDatabase db) =>
      db.persons.createAlias('reminders__person_id__persons__id');

  $$PersonsTableProcessedTableManager? get personId {
    final $_column = $_itemColumn<String>('person_id');
    if ($_column == null) return null;
    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MoneyLedgerTable _ledgerEntryIdTable(_$AppDatabase db) => db
      .moneyLedger
      .createAlias('reminders__ledger_entry_id__money_ledger__id');

  $$MoneyLedgerTableProcessedTableManager? get ledgerEntryId {
    final $_column = $_itemColumn<String>('ledger_entry_id');
    if ($_column == null) return null;
    final manager = $$MoneyLedgerTableTableManager(
      $_db,
      $_db.moneyLedger,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupsCacheTable _groupIdTable(_$AppDatabase db) =>
      db.groupsCache.createAlias('reminders__group_id__groups_cache__id');

  $$GroupsCacheTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<String>('group_id');
    if ($_column == null) return null;
    final manager = $$GroupsCacheTableTableManager(
      $_db,
      $_db.groupsCache,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('reminders__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderKind, ReminderKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderRepeat, ReminderRepeat, String>
  get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anchorDay => $composableBuilder(
    column: $table.anchorDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalOccurrences => $composableBuilder(
    column: $table.totalOccurrences,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedOccurrences => $composableBuilder(
    column: $table.completedOccurrences,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderStatus, ReminderStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoneyLedgerTableFilterComposer get ledgerEntryId {
    final $$MoneyLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerEntryId,
      referencedTable: $db.moneyLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyLedgerTableFilterComposer(
            $db: $db,
            $table: $db.moneyLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsCacheTableFilterComposer get groupId {
    final $$GroupsCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableFilterComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorDay => $composableBuilder(
    column: $table.anchorDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalOccurrences => $composableBuilder(
    column: $table.totalOccurrences,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedOccurrences => $composableBuilder(
    column: $table.completedOccurrences,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoneyLedgerTableOrderingComposer get ledgerEntryId {
    final $$MoneyLedgerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerEntryId,
      referencedTable: $db.moneyLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyLedgerTableOrderingComposer(
            $db: $db,
            $table: $db.moneyLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsCacheTableOrderingComposer get groupId {
    final $$GroupsCacheTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableOrderingComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderRepeat, String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anchorDay =>
      $composableBuilder(column: $table.anchorDay, builder: (column) => column);

  GeneratedColumn<int> get totalOccurrences => $composableBuilder(
    column: $table.totalOccurrences,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedOccurrences => $composableBuilder(
    column: $table.completedOccurrences,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReminderStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoneyLedgerTableAnnotationComposer get ledgerEntryId {
    final $$MoneyLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerEntryId,
      referencedTable: $db.moneyLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.moneyLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsCacheTableAnnotationComposer get groupId {
    final $$GroupsCacheTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupsCache,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsCacheTableAnnotationComposer(
            $db: $db,
            $table: $db.groupsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (ReminderRow, $$RemindersTableReferences),
          ReminderRow,
          PrefetchHooks Function({
            bool personId,
            bool ledgerEntryId,
            bool groupId,
            bool categoryId,
          })
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<ReminderKind> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<ReminderRepeat> repeat = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<String?> ledgerEntryId = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int?> amountPaise = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int?> anchorDay = const Value.absent(),
                Value<int?> totalOccurrences = const Value.absent(),
                Value<int> completedOccurrences = const Value.absent(),
                Value<int> notificationId = const Value.absent(),
                Value<ReminderStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                kind: kind,
                title: title,
                note: note,
                dueAt: dueAt,
                repeat: repeat,
                personId: personId,
                ledgerEntryId: ledgerEntryId,
                groupId: groupId,
                amountPaise: amountPaise,
                categoryId: categoryId,
                anchorDay: anchorDay,
                totalOccurrences: totalOccurrences,
                completedOccurrences: completedOccurrences,
                notificationId: notificationId,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime createdAt,
                required DateTime updatedAt,
                required String id,
                required ReminderKind kind,
                required String title,
                Value<String?> note = const Value.absent(),
                required DateTime dueAt,
                Value<ReminderRepeat> repeat = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<String?> ledgerEntryId = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int?> amountPaise = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int?> anchorDay = const Value.absent(),
                Value<int?> totalOccurrences = const Value.absent(),
                Value<int> completedOccurrences = const Value.absent(),
                required int notificationId,
                Value<ReminderStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                kind: kind,
                title: title,
                note: note,
                dueAt: dueAt,
                repeat: repeat,
                personId: personId,
                ledgerEntryId: ledgerEntryId,
                groupId: groupId,
                amountPaise: amountPaise,
                categoryId: categoryId,
                anchorDay: anchorDay,
                totalOccurrences: totalOccurrences,
                completedOccurrences: completedOccurrences,
                notificationId: notificationId,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemindersTable, ReminderRow>(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                personId = false,
                ledgerEntryId = false,
                groupId = false,
                categoryId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (personId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.personId,
                            referencedTable: $$RemindersTableReferences
                                ._personIdTable(db),
                            referencedColumn: $$RemindersTableReferences
                                ._personIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (ledgerEntryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.ledgerEntryId,
                            referencedTable: $$RemindersTableReferences
                                ._ledgerEntryIdTable(db),
                            referencedColumn: $$RemindersTableReferences
                                ._ledgerEntryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (groupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$RemindersTableReferences
                                ._groupIdTable(db),
                            referencedColumn: $$RemindersTableReferences
                                ._groupIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$RemindersTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$RemindersTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (ReminderRow, $$RemindersTableReferences),
      ReminderRow,
      PrefetchHooks Function({
        bool personId,
        bool ledgerEntryId,
        bool groupId,
        bool categoryId,
      })
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  required String opId,
  required String groupId,
  required String entityType,
  required String entityId,
  required String opType,
  required String payload,
  required int baseRevision,
  Value<OutboxStatus> status,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<String?> lastError,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<String> opId,
  Value<String> groupId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> opType,
  Value<String> payload,
  Value<int> baseRevision,
  Value<OutboxStatus> status,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<String?> lastError,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OutboxStatus, OutboxStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<OutboxStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          OutboxRow,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            OutboxRow,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, OutboxRow>,
          ),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> baseRevision = const Value.absent(),
                Value<OutboxStatus> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                opId: opId,
                groupId: groupId,
                entityType: entityType,
                entityId: entityId,
                opType: opType,
                payload: payload,
                baseRevision: baseRevision,
                status: status,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String groupId,
                required String entityType,
                required String entityId,
                required String opType,
                required String payload,
                required int baseRevision,
                Value<OutboxStatus> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                opId: opId,
                groupId: groupId,
                entityType: entityType,
                entityId: entityId,
                opType: opType,
                payload: payload,
                baseRevision: baseRevision,
                status: status,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOutboxTable, OutboxRow>(table),
                  BaseReferences<_$AppDatabase, $SyncOutboxTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      OutboxRow,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$AppDatabase, $SyncOutboxTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$SyncInboxTableCreateCompanionBuilder = SyncInboxCompanion Function({
  Value<int> seq,
  required String groupId,
  required String entityType,
  required String entityId,
  required String opType,
  required String payload,
  required int remoteRevision,
  required DateTime receivedAt,
  Value<DateTime?> appliedAt,
  Value<String?> error,
});
typedef $$SyncInboxTableUpdateCompanionBuilder = SyncInboxCompanion Function({
  Value<int> seq,
  Value<String> groupId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> opType,
  Value<String> payload,
  Value<int> remoteRevision,
  Value<DateTime> receivedAt,
  Value<DateTime?> appliedAt,
  Value<String?> error,
});

class $$SyncInboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncInboxTable> {
  $$SyncInboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncInboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncInboxTable> {
  $$SyncInboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncInboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncInboxTable> {
  $$SyncInboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$SyncInboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncInboxTable,
          InboxRow,
          $$SyncInboxTableFilterComposer,
          $$SyncInboxTableOrderingComposer,
          $$SyncInboxTableAnnotationComposer,
          $$SyncInboxTableCreateCompanionBuilder,
          $$SyncInboxTableUpdateCompanionBuilder,
          (InboxRow, BaseReferences<_$AppDatabase, $SyncInboxTable, InboxRow>),
          InboxRow,
          PrefetchHooks Function()
        > {
  $$SyncInboxTableTableManager(_$AppDatabase db, $SyncInboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncInboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncInboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncInboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> remoteRevision = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<DateTime?> appliedAt = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => SyncInboxCompanion(
                seq: seq,
                groupId: groupId,
                entityType: entityType,
                entityId: entityId,
                opType: opType,
                payload: payload,
                remoteRevision: remoteRevision,
                receivedAt: receivedAt,
                appliedAt: appliedAt,
                error: error,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String groupId,
                required String entityType,
                required String entityId,
                required String opType,
                required String payload,
                required int remoteRevision,
                required DateTime receivedAt,
                Value<DateTime?> appliedAt = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => SyncInboxCompanion.insert(
                seq: seq,
                groupId: groupId,
                entityType: entityType,
                entityId: entityId,
                opType: opType,
                payload: payload,
                remoteRevision: remoteRevision,
                receivedAt: receivedAt,
                appliedAt: appliedAt,
                error: error,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncInboxTable, InboxRow>(table),
                  BaseReferences<_$AppDatabase, $SyncInboxTable, InboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncInboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncInboxTable,
      InboxRow,
      $$SyncInboxTableFilterComposer,
      $$SyncInboxTableOrderingComposer,
      $$SyncInboxTableAnnotationComposer,
      $$SyncInboxTableCreateCompanionBuilder,
      $$SyncInboxTableUpdateCompanionBuilder,
      (InboxRow, BaseReferences<_$AppDatabase, $SyncInboxTable, InboxRow>),
      InboxRow,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      required String groupId,
      required String entityType,
      required String entityId,
      Value<String?> opId,
      required String localPayload,
      Value<String?> remotePayload,
      required int remoteRevision,
      required DateTime detectedAt,
      Value<DateTime?> resolvedAt,
      Value<String?> resolution,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<String> groupId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String?> opId,
      Value<String> localPayload,
      Value<String?> remotePayload,
      Value<int> remoteRevision,
      Value<DateTime> detectedAt,
      Value<DateTime?> resolvedAt,
      Value<String?> resolution,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remotePayload => $composableBuilder(
    column: $table.remotePayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remotePayload => $composableBuilder(
    column: $table.remotePayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remotePayload => $composableBuilder(
    column: $table.remotePayload,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          ConflictRow,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            ConflictRow,
            BaseReferences<_$AppDatabase, $SyncConflictsTable, ConflictRow>,
          ),
          ConflictRow,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String?> opId = const Value.absent(),
                Value<String> localPayload = const Value.absent(),
                Value<String?> remotePayload = const Value.absent(),
                Value<int> remoteRevision = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                groupId: groupId,
                entityType: entityType,
                entityId: entityId,
                opId: opId,
                localPayload: localPayload,
                remotePayload: remotePayload,
                remoteRevision: remoteRevision,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                resolution: resolution,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String groupId,
                required String entityType,
                required String entityId,
                Value<String?> opId = const Value.absent(),
                required String localPayload,
                Value<String?> remotePayload = const Value.absent(),
                required int remoteRevision,
                required DateTime detectedAt,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                groupId: groupId,
                entityType: entityType,
                entityId: entityId,
                opId: opId,
                localPayload: localPayload,
                remotePayload: remotePayload,
                remoteRevision: remoteRevision,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                resolution: resolution,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncConflictsTable, ConflictRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncConflictsTable,
                    ConflictRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      ConflictRow,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        ConflictRow,
        BaseReferences<_$AppDatabase, $SyncConflictsTable, ConflictRow>,
      ),
      ConflictRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalUserProfileTableTableManager get localUserProfile =>
      $$LocalUserProfileTableTableManager(_db, _db.localUserProfile);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$BackupHistoryTableTableManager get backupHistory =>
      $$BackupHistoryTableTableManager(_db, _db.backupHistory);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$PersonsTableTableManager get persons =>
      $$PersonsTableTableManager(_db, _db.persons);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$MoneyLedgerTableTableManager get moneyLedger =>
      $$MoneyLedgerTableTableManager(_db, _db.moneyLedger);
  $$MoneySettlementsTableTableManager get moneySettlements =>
      $$MoneySettlementsTableTableManager(_db, _db.moneySettlements);
  $$GroupsCacheTableTableManager get groupsCache =>
      $$GroupsCacheTableTableManager(_db, _db.groupsCache);
  $$GroupMembersCacheTableTableManager get groupMembersCache =>
      $$GroupMembersCacheTableTableManager(_db, _db.groupMembersCache);
  $$GroupExpensesCacheTableTableManager get groupExpensesCache =>
      $$GroupExpensesCacheTableTableManager(_db, _db.groupExpensesCache);
  $$GroupExpenseSplitsCacheTableTableManager get groupExpenseSplitsCache =>
      $$GroupExpenseSplitsCacheTableTableManager(
        _db,
        _db.groupExpenseSplitsCache,
      );
  $$GroupSettlementsCacheTableTableManager get groupSettlementsCache =>
      $$GroupSettlementsCacheTableTableManager(_db, _db.groupSettlementsCache);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncInboxTableTableManager get syncInbox =>
      $$SyncInboxTableTableManager(_db, _db.syncInbox);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
}
