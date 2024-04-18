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

    List<DateTime> dates = [];
    List<double> prices = [];

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
    Color startColor = paintColor.withOpacity(0.2); // Adjust opacity as needed
    Color endColor =
        paintColor.withOpacity(0.01); // Fully transparent color at the bottom

    // Calculate the minimum and maximum y-axis values
    double minValue = prices.reduce((a, b) => a < b ? a : b);
    double maxValue = prices.reduce((a, b) => a > b ? a : b);

    // Calculate the y-coordinate for the bottom of the gradient
    double gradientBottomY =
        size.height + (0.1 * size.height); // Adjust the percentage as needed

    // Create a gradient shader
    final Shader gradientShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [startColor, endColor],
    ).createShader(Rect.fromLTRB(0, 0, size.width, gradientBottomY));

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

// Draw dashed line from end of last data point to beginning of screen
    double lastX = ((dates.last.millisecondsSinceEpoch -
                minDate.millisecondsSinceEpoch) /
            (maxDate.millisecondsSinceEpoch - minDate.millisecondsSinceEpoch)) *
        size.width;
    double lastY = size.height -
        ((prices.last - minValue) / (maxValue - minValue)) * size.height;

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

    // Draw a filled area below the line chart using the gradient shader
    chartPath.lineTo(size.width, gradientBottomY);
    chartPath.lineTo(0, gradientBottomY);
    chartPath.close();
    canvas.drawPath(
        chartPath,
        Paint()
          ..shader = gradientShader
          ..style = PaintingStyle.fill);

    // Define the number of divisions for the y-axis
    int yDivisions = 4;
    double yDivisionInterval = (minValue - maxValue) / yDivisions;

    // Draw y-axis labels with divisions
    TextPainter yLabelPainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );
    for (int i = 0; i <= yDivisions; i++) {
      double labelValue = minValue - (i * yDivisionInterval);
      yLabelPainter.text = TextSpan(
        text: labelValue.toStringAsFixed(2),
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      yLabelPainter.layout();
      double y = size.height -
          (i * (size.height / yDivisions)) -
          (yLabelPainter.height / 2);
      yLabelPainter.paint(canvas, Offset(10, y));

      // Draw grey background behind the text labels
      Rect labelRect = Rect.fromLTWH(
        8, // Add some padding to the left side of the text
        y - 2, // Align vertically with the center of the text
        yLabelPainter.width + 6, // Add padding to both sides of the text
        yLabelPainter.height + 4, // Add padding above and below the text
      );
      const radius = Radius.circular(8); // Adjust the radius as needed
      final roundedRect = RRect.fromRectAndCorners(labelRect,
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius);

      final paint = Paint()
        ..color = Colors.grey.withOpacity(0.5) // Color of the rectangle
        ..style = PaintingStyle.fill;

      canvas.drawRRect(roundedRect, paint);
    }

    // Define the number of divisions for the x-axis
    int xDivisions = 5;
    double xDivisionInterval =
        (maxDate.millisecondsSinceEpoch - minDate.millisecondsSinceEpoch) /
            xDivisions;

    // Draw x-axis labels with divisions
    TextPainter xLabelPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    for (int i = 0; i <= xDivisions; i++) {
      DateTime divisionDate = DateTime.fromMillisecondsSinceEpoch(
          minDate.millisecondsSinceEpoch + (i * xDivisionInterval).toInt());
      xLabelPainter.text = TextSpan(
        text: divisionDate.toString(),
        style: const TextStyle(color: Colors.black, fontSize: 10),
      );
      xLabelPainter.layout();
      double x = (i * (size.width / xDivisions)) - (xLabelPainter.width / 2);
      xLabelPainter.paint(canvas, Offset(x, size.height + 4));

      // Draw grey background behind the text labels
      Rect labelRect = Rect.fromLTWH(
        x - 2, // Align horizontally with the center of the text
        size.height + 4, // Add some padding below the text
        xLabelPainter.width + 4, // Add padding to both sides of the text
        xLabelPainter.height + 4, // Add padding above and below the text
      );
      canvas.drawRect(labelRect, Paint()..color = Colors.grey.withOpacity(0.5));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // No need to repaint since the chart is static
  }
}
