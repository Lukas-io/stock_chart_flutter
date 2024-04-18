import 'package:flutter/material.dart';
import 'package:stock_chart_flutter/price_history_model.dart';

class StockPriceChartPainter extends CustomPainter {
  final List<StockData> stockPriceHistory;

  final Paint gridPaint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 1;

  StockPriceChartPainter(this.stockPriceHistory);

  @override
  void paint(Canvas canvas, Size size) {
    Color paintColor =
        stockPriceHistory.first.price > stockPriceHistory.last.price
            ? Colors.red
            : Colors.green;

    // Draw chart axes
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height),
        gridPaint); // X-axis
    canvas.drawLine(
        Offset(0, size.height), const Offset(0, 0), gridPaint); // Y-axis
    // Draw data points

    List<DateTime> dates = [];
    List<double> prices = [];
    double height = size.height;

    for (var data in stockPriceHistory) {
      dates.add(data.dateTime);
      prices.add(data.price);
    }

    DateTime minDate = dates
        .reduce((value, element) => value.isBefore(element) ? value : element);
    DateTime maxDate = dates
        .reduce((value, element) => value.isAfter(element) ? value : element);

    Paint chartPaint = Paint()
      ..color = paintColor
      ..strokeWidth = 2; // Adjust the thickness of the lines as needed

    // Define colors for the gradient
    Color startColor = paintColor.withOpacity(0.3); // Adjust opacity as needed
    Color endColor =
        Colors.transparent; // Fully transparent color at the bottom

    // Calculate the minimum and maximum y-axis values
    double minValue = prices.reduce((a, b) => a < b ? a : b) + 1;
    double maxValue = prices.reduce((a, b) => a > b ? a : b);

    // Define the range for the y-axis (20% to 85%)
    double minY = (0.2 * (maxValue - minValue)) + minValue;
    double maxY = (0.85 * (maxValue - minValue)) + minValue;

    // Create a gradient shader
    final Shader gradientShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [startColor, endColor],
    ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    // Create a path for the line chart
    Path chartPath = Path();

    // Move to the first data point
    double x = ((dates.first.millisecondsSinceEpoch -
                minDate.millisecondsSinceEpoch) /
            (maxDate.millisecondsSinceEpoch - minDate.millisecondsSinceEpoch)) *
        size.width;
    double y = size.height -
        ((prices.first - minValue) / (maxValue - minValue)) * size.height;
    chartPath.moveTo(x, y);
    chartPath.moveTo(x, y);

    // Draw lines between each pair of consecutive data points
    for (int i = 0; i < dates.length - 1; i++) {
      double x1 =
          ((dates[i].millisecondsSinceEpoch - minDate.millisecondsSinceEpoch) /
                  (maxDate.millisecondsSinceEpoch -
                      minDate.millisecondsSinceEpoch)) *
              size.width;
      double y1 = size.height -
          ((prices[i] - minValue) / (maxValue - minValue)) * size.height;

      double x2 = ((dates[i + 1].millisecondsSinceEpoch -
                  minDate.millisecondsSinceEpoch) /
              (maxDate.millisecondsSinceEpoch -
                  minDate.millisecondsSinceEpoch)) *
          size.width;
      double y2 = size.height -
          ((prices[i + 1] - minValue) / (maxValue - minValue)) * size.height;

      // Draw a line between each pair of consecutive data points
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), chartPaint);

      // Add points to the path for the gradient area
      chartPath.lineTo(x2, y2);
    }

    // Draw a filled area below the line chart using the gradient shader
    chartPath.lineTo(size.width, height);
    chartPath.lineTo(0, height);
    chartPath.close();
    canvas.drawPath(
        chartPath,
        Paint()
          ..shader = gradientShader
          ..style = PaintingStyle.fill);

// Draw dashed line from end of last data point to beginning of screen
    double lastX = ((dates.last.millisecondsSinceEpoch -
                minDate.millisecondsSinceEpoch) /
            (maxDate.millisecondsSinceEpoch - minDate.millisecondsSinceEpoch)) *
        size.width;
    double lastY = height -
        (prices.last / prices.reduce((a, b) => a > b ? a : b)) * height;

    Paint dashedLinePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint transparentDashedLinePaint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double dashPosition = lastX;
    int dashLength = 5;
    double stopDashPosition = lastX - dashLength;
    bool dash = true;
    while (dashPosition > 0) {
      if (dash) {
        canvas.drawLine(Offset(dashPosition, lastY),
            Offset(stopDashPosition, lastY), dashedLinePaint);
      } else {
        canvas.drawLine(Offset(dashPosition, lastY),
            Offset(stopDashPosition, lastY), transparentDashedLinePaint);
      }

      dashPosition -= dashLength;
      stopDashPosition -= dashLength;

      dash = !dash;
    }
    canvas.drawCircle(Offset(lastX, lastY), 5, Paint()..color = paintColor);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // No need to repaint since the chart is static
  }
}
