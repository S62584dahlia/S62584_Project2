/*
Name:Nur Siti Dahlia S62584
Program: code for a pie chart for status activities progress
*/

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'model/activity.dart';

class StatusChart extends StatelessWidget {
  final List<Activity> activities;

  const StatusChart({Key? key, required this.activities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, int> statusCount = {
      'Complete': 0,
      'Not Started': 0,
      'In Progress': 0,
      'Cancel/Removed': 0,
    };

    for (var activity in activities) {
      String status = activity.status;
      if (statusCount.containsKey(status)) {
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: CustomPaint(
                painter: PieChartPainter(statusCount),
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 20,
              alignment: WrapAlignment.center,
              children: _buildStatusLabels(statusCount),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatusLabels(Map<String, int> statusCount) {
  List<Widget> labels = [];

  for (var entry in statusCount.entries) {
    labels.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12, 
              height: 12, 
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PieChartPainter(statusCount)._getStatusColor(entry.key),
              ),
              margin: EdgeInsets.only(right: 10.0),
            ),
            Text(
              '${entry.key} (${entry.value})',
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
  return labels;
}
}


class PieChartPainter extends CustomPainter {
  final Map<String, int> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(centerX, centerY);

    double total = data.values.fold(0, (previous, current) => previous + current);

    double startRadian = -math.pi / 2; 

    data.forEach((status, count) {
      final sweepRadian = (count / total) * 2 * math.pi;
      final percentage = (count / total) * 100;

      if (percentage > 0) {
        final paint = Paint()..color = _getStatusColor(status);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
          startRadian,
          sweepRadian,
          true,
          paint,
        );

        final double radians = startRadian + (sweepRadian / 2);
        final double x = centerX + (radius / 1.4) * math.cos(radians);
        final double y = centerY + (radius / 1.4) * math.sin(radians);

        final percentageText = '${percentage.toStringAsFixed(2)}%';
        final textStyle = TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold);

        final textSpan = TextSpan(text: percentageText, style: textStyle);
        final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout();

        textPainter.paint(canvas, Offset(x - (textPainter.width / 2), y - (textPainter.height / 2)));
      }

      startRadian += sweepRadian;
    });
  }

  List<String> getStatusLabels() {
    return data.keys.toList();
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Complete':
        return Colors.green;
      case 'Not Started':
        return Colors.red;
      case 'In Progress':
        return Colors.orange;
      case 'Cancel/Removed':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}
