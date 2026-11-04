import 'package:flutter/material.dart';

/// Một cột của biểu đồ.
class BarData {
  const BarData({required this.value, this.ghost, this.target});

  final double value;

  /// Cột mờ phía sau, ví dụ tổng số mục khi [value] là số mục đã xong.
  final double? ghost;

  /// Vạch mục tiêu của riêng cột này.
  final double? target;
}

/// Biểu đồ cột tự vẽ, không cần thư viện ngoài (D-008). Chỉ vẽ hình: chữ
/// (nhãn trục, bảng thay thế) do màn hình chứa nó dựng bằng widget thường để
/// co theo cỡ chữ hệ thống và đọc được bằng TalkBack (AC-29, AC-50).
class BarChart extends StatelessWidget {
  const BarChart({
    super.key,
    required this.bars,
    required this.semanticsLabel,
    this.height = 140,
  });

  final List<BarData> bars;

  /// Mô tả tóm tắt cho trình đọc màn hình; chi tiết nằm ở bảng thay thế.
  final String semanticsLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsLabel,
      image: true,
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _BarPainter(
            bars: bars,
            barColor: scheme.primary,
            ghostColor: scheme.primaryContainer,
            targetColor: scheme.tertiary,
            axisColor: scheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.bars,
    required this.barColor,
    required this.ghostColor,
    required this.targetColor,
    required this.axisColor,
  });

  final List<BarData> bars;
  final Color barColor;
  final Color ghostColor;
  final Color targetColor;
  final Color axisColor;

  /// Giá trị lớn nhất để chia tỉ lệ trục dọc.
  static double maxOf(List<BarData> bars) {
    var m = 0.0;
    for (final b in bars) {
      for (final v in [b.value, b.ghost ?? 0, b.target ?? 0]) {
        if (v > m) m = v;
      }
    }
    return m;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 0.5),
      Offset(size.width, size.height - 0.5),
      axis,
    );
    if (bars.isEmpty) return;
    final max = maxOf(bars);
    if (max <= 0) return;

    final slot = size.width / bars.length;
    final gap = slot > 6 ? slot * 0.2 : 0.0;
    final barW = slot - gap;
    double y(double v) => size.height - (v / max) * (size.height - 2);

    final ghost = Paint()..color = ghostColor;
    final fill = Paint()..color = barColor;
    final line = Paint()
      ..color = targetColor
      ..strokeWidth = 2;
    for (final (i, b) in bars.indexed) {
      final x = i * slot + gap / 2;
      if (b.ghost != null && b.ghost! > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(x, y(b.ghost!), x + barW, size.height),
            const Radius.circular(2),
          ),
          ghost,
        );
      }
      if (b.value > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(x, y(b.value), x + barW, size.height),
            const Radius.circular(2),
          ),
          fill,
        );
      }
      final t = b.target;
      if (t != null && t > 0) {
        // Vạch mục tiêu kéo hết ô của cột để các cột liền nhau nối thành đường.
        canvas.drawLine(
          Offset(i * slot, y(t)),
          Offset((i + 1) * slot, y(t)),
          line,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.bars != bars ||
      old.barColor != barColor ||
      old.ghostColor != ghostColor ||
      old.targetColor != targetColor;
}

/// Giá trị lớn nhất của các cột, dùng cho nhãn trục dọc.
double barChartMax(List<BarData> bars) => _BarPainter.maxOf(bars);
