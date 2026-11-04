import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../backup/data_actions.dart';
import '../lock/app_lock.dart';
import '../lock/pin_dialogs.dart';

/// Cài đặt: giao diện, ngôn ngữ, ngày đầu tuần (AC-48), khóa PIN (F-12) và
/// dữ liệu: sao lưu, khôi phục, CSV, xóa hết (F-11, AC-52).
/// Mỗi lựa chọn một dòng riêng để cỡ chữ 200% không bị cắt (AC-50).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final repo = ref.watch(settingsRepositoryProvider);
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final localeCode = ref.watch(localeCodeProvider).value ?? '';
    final weekStart = ref.watch(weekStartProvider).value ?? DateTime.monday;
    final pinOn = ref.watch(pinEnabledProvider).value ?? false;
    final titleStyle = Theme.of(context).textTheme.titleSmall
        ?.copyWith(color: Theme.of(context).colorScheme.primary);

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Semantics(header: true, child: Text(text, style: titleStyle)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          header(l.theme),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (v) => repo.setThemeMode(v!),
            child: Column(
              children: [
                RadioListTile(
                  value: ThemeMode.system,
                  title: Text(l.themeSystem),
                ),
                RadioListTile(
                  value: ThemeMode.light,
                  title: Text(l.themeLight),
                ),
                RadioListTile(value: ThemeMode.dark, title: Text(l.themeDark)),
              ],
            ),
          ),
          header(l.language),
          RadioGroup<String>(
            groupValue: localeCode,
            onChanged: (v) => repo.setLocaleCode(v!.isEmpty ? null : v),
            child: Column(
              children: [
                RadioListTile(value: '', title: Text(l.languageSystem)),
                const RadioListTile(value: 'vi', title: Text('Tiếng Việt')),
                const RadioListTile(value: 'en', title: Text('English')),
              ],
            ),
          ),
          header(l.weekStart),
          RadioGroup<int>(
            groupValue: weekStart,
            onChanged: (v) => repo.setWeekStart(v!),
            child: Column(
              children: [
                RadioListTile(value: DateTime.monday, title: Text(l.monday)),
                RadioListTile(value: DateTime.sunday, title: Text(l.sunday)),
              ],
            ),
          ),
          header(l.securitySection),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l.pinLock),
            subtitle: Text(pinOn ? l.pinLockHintOn : l.pinLockHintOff),
            trailing: Switch(
              value: pinOn,
              onChanged: (on) =>
                  on ? setupPin(context, ref) : disablePin(context, ref),
            ),
            onTap: () =>
                pinOn ? disablePin(context, ref) : setupPin(context, ref),
          ),
          if (pinOn)
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: Text(l.pinChange),
              onTap: () => changePin(context, ref),
            ),
          header(l.dataSection),
          Builder(
            builder: (context) => ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l.backupExport),
              subtitle: Text(l.backupExportHint),
              onTap: () => exportBackupFile(context, ref),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l.backupRestore),
            subtitle: Text(l.backupRestoreHint),
            onTap: () => restoreFromFile(context, ref),
          ),
          Builder(
            builder: (context) => ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: Text(l.csvExport),
              subtitle: Text(l.csvExportHint),
              onTap: () => exportCsvFile(context, ref),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l.deleteAll,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: Text(l.deleteAllHint),
            onTap: () =>
                deleteEverything(context, ref, onReset: () => context.go('/')),
          ),
        ],
      ),
    );
  }
}
