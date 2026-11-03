import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Cài đặt G1: giao diện, ngôn ngữ, ngày đầu tuần (AC-48).
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
        ],
      ),
    );
  }
}
