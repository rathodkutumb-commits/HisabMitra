import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';

typedef PickedContact = ({String name, String? phone});

/// Opens the Android system contact picker. No READ_CONTACTS permission is
/// requested: the OS grants one-time access to the chosen contact only.
class ContactPicker {
  const ContactPicker();

  static const _channel = MethodChannel('hisabmitra/contacts');

  Future<PickedContact?> pick() async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'pickContact',
      );
      if (result == null) return null;
      final name = (result['name'] as String?)?.trim();
      if (name == null || name.isEmpty) return null;
      return (name: name, phone: result['phone'] as String?);
    } on MissingPluginException {
      throw const NotConfiguredFailure();
    } on PlatformException {
      throw const PermissionFailure();
    }
  }
}

final contactPickerProvider = Provider<ContactPicker>(
  (ref) => const ContactPicker(),
);
