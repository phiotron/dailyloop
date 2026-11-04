import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'bar_chart.dart';

/// Biểu đồ cột kèm nhãn đầu, cuối và bảng thay thế đọc được bằng trình đọc
/// màn hình (AC-29). Nhãn và bảng là widget chữ thường nên co theo cỡ chữ
/// hệ thống (AC-50).
class ChartSection extends StatelessWidget {
  const ChartSection({
    super.key,
    required this.bars,
    required this.labels,
    required this.rows,
    required this.valueHeader,
    required this.maxText,
    this.firstLabel,
    this.lastLabel,
  });

  final List<BarData> bars;

  /// Nhãn của từng cột, dùng ở bảng thay thế.
  final List<String> labels;

  /// Giá trị bằng chữ của từng cột, ví dụ "6 ly" hoặc "3 trên 5".
  final List<String> rows;
  final String valueHeader;

  /// Giá trị lớn nhất bằng chữ, hiện ở góc trên trái.
  final String maxText;
  final String? firstLabel;
  final String? lastLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(maxText, style: small),
        const SizedBox(height: 4),
        BarChart(
          bars: bars,
          semanticsLabel: l.chartSummary(bars.length, maxText),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(firstLabel ?? labels.first, style: small)),
            Flexible(
              child: Text(
                lastLabel ?? labels.last,
                style: small,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(l.chartTable),
          children: [
            for (final (i, label) in labels.indexed)
              MergeSemantics(
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  trailing: Text(rows[i]),
                  subtitle: i == 0 ? Text(valueHeader) : null,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
