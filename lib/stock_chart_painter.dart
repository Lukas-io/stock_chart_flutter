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
    double height = size.height * 5;

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

// Iterate over each data point to draw lines between them
    for (int i = 0; i < dates.length - 1; i++) {
      double x1 =
          ((dates[i].millisecondsSinceEpoch - minDate.millisecondsSinceEpoch) /
                  (maxDate.millisecondsSinceEpoch -
                      minDate.millisecondsSinceEpoch)) *
              size.width;
      double y1 = height -
          (prices[i] / prices.reduce((a, b) => a > b ? a : b)) * height;

      double x2 = ((dates[i + 1].millisecondsSinceEpoch -
                  minDate.millisecondsSinceEpoch) /
              (maxDate.millisecondsSinceEpoch -
                  minDate.millisecondsSinceEpoch)) *
          size.width;
      double y2 = height -
          (prices[i + 1] / prices.reduce((a, b) => a > b ? a : b)) * height;

      // Draw a line between each pair of consecutive data points
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), chartPaint);
    }

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

    // Define colors for the gradient
    Color startColor = paintColor.withOpacity(0.5); // Adjust opacity as needed
    Color endColor =
        Colors.transparent; // Fully transparent color at the bottom

    // Create a gradient shader
    final Shader gradientShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [startColor, endColor],
    ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    Path gradientPath = Path();
    gradientPath.moveTo(0, size.height); // Start at the bottom-left corner

    // Iterate over each data point to define the path
    for (int i = 0; i < dates.length; i++) {
      double x =
          ((dates[i].millisecondsSinceEpoch - minDate.millisecondsSinceEpoch) /
                  (maxDate.millisecondsSinceEpoch -
                      minDate.millisecondsSinceEpoch)) *
              size.width;
      double y = height -
          (prices[i] / prices.reduce((a, b) => a > b ? a : b)) * height;
      gradientPath.lineTo(x, y);
// Add line segments to the path
    }
    // Draw the filled area below the line chart using the gradient shader
    canvas.drawPath(
        gradientPath,
        Paint()
          ..shader = gradientShader
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // No need to repaint since the chart is static
  }
}
