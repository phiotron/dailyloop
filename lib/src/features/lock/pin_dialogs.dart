import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import 'app_lock.dart';
import 'pin_pad.dart';

/// Đặt mã PIN: nhập hai lần cho khớp, có cảnh báo quên mã (AC-45).
/// Trả về true nếu đã đặt.
Future<bool> setupPin(BuildContext context, WidgetRef ref) async {
  final pin = await showDialog<String>(
    context: context,
    builder: (context) => const Dialog.fullscreen(child: _PinSetup()),
  );
  if (pin == null) return false;
  await ref.read(pinServiceProvider).setPin(pin);
  ref.invalidate(pinEnabledProvider);
  return true;
}

/// Đổi mã PIN: nhập mã hiện tại rồi đặt mã mới.
Future<void> changePin(BuildContext context, WidgetRef ref) async {
  if (!await _checkCurrent(context)) return;
  if (!context.mounted) return;
  await setupPin(context, ref);
}

/// Tắt khóa PIN, phải nhập đúng mã đang dùng.
Future<void> disablePin(BuildContext context, WidgetRef ref) async {
  if (!await _checkCurrent(context)) return;
  await ref.read(pinServiceProvider).disable();
  ref.invalidate(pinEnabledProvider);
}

Future<bool> _checkCurrent(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => const Dialog.fullscreen(child: _PinCheck()),
    ) ??
    false;

class _PinSetup extends StatefulWidget {
  const _PinSetup();

  @override
  State<_PinSetup> createState() => _PinSetupState();
}

class _PinSetupState extends State<_PinSetup> {
  String? _first;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.pinLock)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: PinPad(
            title: _first == null ? l.newPin : l.confirmPin,
            message: l.pinWarning,
            error: _error,
            onCompleted: (pin) async {
              if (_first == null) {
                setState(() {
                  _first = pin;
                  _error = null;
                });
              } else if (pin == _first) {
                Navigator.pop(context, pin);
              } else {
                setState(() {
                  _first = null;
                  _error = l.pinMismatch;
                });
              }
            },
          ),
        ),
      ),
    );
  }
}

class _PinCheck extends ConsumerStatefulWidget {
  const _PinCheck();

  @override
  ConsumerState<_PinCheck> createState() => _PinCheckState();
}

class _PinCheckState extends ConsumerState<_PinCheck> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.pinLock)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: PinPad(
            title: l.enterCurrentPin,
            error: _error,
            onCompleted: (pin) async {
              final ok = await ref.read(pinServiceProvider).verify(pin);
              if (!context.mounted) return;
              if (ok) {
                Navigator.pop(context, true);
              } else {
                setState(() => _error = l.wrongPin);
              }
            },
          ),
        ),
      ),
    );
  }
}
