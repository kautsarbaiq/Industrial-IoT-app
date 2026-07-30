import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// A tiny, axis-less line chart for inline trends (e.g. machine OEE history).
class TrendSparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;
  final bool fill;

  const TrendSparkline({
    super.key,
    required this.data,
    required this.color,
    this.height = 40,
    this.fill = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height);
    final minY = (data.reduce((a, b) => a < b ? a : b)) - 4;
    final maxY = (data.reduce((a, b) => a > b ? a : b)) + 4;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < data.length; i++)
                  FlSpot(i.toDouble(), data[i]),
              ],
              isCurved: true,
              curveSmoothness: 0.3,
              color: color,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: fill,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withOpacity(0.22), color.withOpacity(0.0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
