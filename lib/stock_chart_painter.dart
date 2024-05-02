import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stock_chart_flutter/price_history_model.dart';

class StockPriceChartPainter extends CustomPainter {
  final List<StockData> stockPriceHistory;
  final Offset? pricePoint;

  StockPriceChartPainter(this.stockPriceHistory, this.pricePoint);

  @override
  void paint(Canvas canvas, Size size) {
    List<DateTime> dates = [];
    List<double> prices = [];
    List<Offset> chartAxis = [];
    Offset? placedPoint;
    int? chartIndex;

    for (var data in stockPriceHistory) {
      dates.add(data.dateTime);
      prices.add(data.price);
    }

    DateTime minDate = dates
        .reduce((value, element) => value.isBefore(element) ? value : element);
    DateTime maxDate = dates
        .reduce((value, element) => value.isAfter(element) ? value : element);

    // Calculate the minimum and maximum y-axis values
    double minValue = prices.reduce((a, b) => a < b ? a : b);
    double maxValue = prices.reduce((a, b) => a > b ? a : b);
    if (minValue == maxValue) {
      minValue /= 2;
      maxValue *= 1.5;
    }

    // Calculate the y-coordinate for the bottom of the gradient

    // Create a path for the line chart
    Path chartPath = Path();

    //To create a more custom feel for the linear gradient under the chart
    Path onChartPath1 = Path();
    Path onChartPath2 = Path();

    // Move to the first data point
    double x = ((dates.first.millisecondsSinceEpoch -
                minDate.millisecondsSinceEpoch) /
            (maxDate.millisecondsSinceEpoch - minDate.millisecondsSinceEpoch)) *
        size.width;
    double y = size.height -
        ((prices.first - minValue) / (maxValue - minValue)) * size.height;
    chartPath.moveTo(x, y);
    onChartPath1.moveTo(x, y);

    // Store Chart Axis
    for (int i = 0; i < dates.length; i++) {
      double x1 =
          ((dates[i].millisecondsSinceEpoch - minDate.millisecondsSinceEpoch) /
                  (maxDate.millisecondsSinceEpoch -
                      minDate.millisecondsSinceEpoch)) *
              size.width;
      double y1 = size.height -
          ((prices[i] - minValue) / (maxValue - minValue)) * size.height;

      chartAxis.add(Offset(x1, y1));
    }
    chartIndex = chartAxis.length - 1;

    if (pricePoint != null) {
      for (int i = 0; i < chartAxis.length - 1; i++) {
        double horizontalAxis1 = chartAxis[i].dx;
        double horizontalAxis2 = chartAxis[i + 1].dx;
        if (pricePoint!.dx >= horizontalAxis1 &&
            pricePoint!.dx <= horizontalAxis2) {
          double difference1 = horizontalAxis1 - pricePoint!.dx;
          double difference2 = horizontalAxis2 - pricePoint!.dx;

          if (difference1.abs() <= difference2.abs()) {
            placedPoint = chartAxis[i];
            chartIndex = i;
          } else {
            placedPoint = chartAxis[i + 1];
            chartIndex = i + 1;
          }
        }
      }
    }

    bool changes =
        (prices[chartIndex!] - prices.first) / prices.first * 100 < 0;

    Color pressedPaintColor = changes ? Colors.red : Colors.green;
    Color paintColor = prices.first > prices.last ? Colors.red : Colors.green;

    Paint chartPaint = Paint()
      ..color = paintColor.withOpacity(0.4)
      ..strokeWidth = 1.5;
    Paint pressedChartPaint = Paint()
      ..color = pressedPaintColor
      ..strokeWidth = 2; // Adjust the thickness of the lines as needed

    // Draw lines between each pair of consecutive data points
    for (int i = 0; i < chartAxis.length - 1; i++) {
      double x1 = chartAxis[i].dx;
      double y1 = chartAxis[i].dy;
      double x2 = chartAxis[i + 1].dx;
      double y2 = chartAxis[i + 1].dy;

      // Draw a line between each pair of consecutive data points
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2),
          chartIndex <= i ? chartPaint : pressedChartPaint);

      // Add points to the path for the gradient area
      chartPath.lineTo(x2, y2);
      if (i == chartIndex - 1) {
        onChartPath2.moveTo(x2, y2);
      }
      if (i < chartIndex) {
        onChartPath1.lineTo(x2, y2);
      } else {
        onChartPath2.lineTo(x2, y2);
      }
    }

    double gradientBottomY =
        size.height + (0.3 * size.height); // Adjust the percentage as needed

    if (pricePoint != null) {
      // Define colors for the gradient
      Color startColor1 =
          pressedPaintColor.withOpacity(0.2); // Adjust opacity as needed
      Color endColor1 = pressedPaintColor.withOpacity(0.01);
      Color startColor2 =
          paintColor.withOpacity(0.05); // Adjust opacity as needed
      Color endColor2 =
          paintColor.withOpacity(0.01); // Fully transparent color at the bottom

      // Create a gradient shader
      Shader gradientShader1 = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [startColor1, endColor1],
      ).createShader(Rect.fromLTRB(0, 0, size.width, gradientBottomY));
      Shader gradientShader2 = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [startColor2, endColor2],
      ).createShader(Rect.fromLTRB(0, 0, size.width, gradientBottomY));

      onChartPath1.lineTo(chartAxis[chartIndex].dx, gradientBottomY);
      onChartPath1.lineTo(0, gradientBottomY);
      onChartPath1.close();
      canvas.drawPath(
          onChartPath1,
          Paint()
            ..shader = gradientShader1
            ..style = PaintingStyle.fill);
      onChartPath2.lineTo(size.width, gradientBottomY);
      onChartPath2.lineTo(chartAxis[chartIndex].dx, gradientBottomY);
      onChartPath2.close();
      canvas.drawPath(
          onChartPath2,
          Paint()
            ..shader = gradientShader2
            ..style = PaintingStyle.fill);
    } else {
      // Define colors for the gradient
      Color startColor =
          paintColor.withOpacity(0.2); // Adjust opacity as needed
      Color endColor =
          paintColor.withOpacity(0.01); // Fully transparent color at the bottom

      // Create a gradient shader
      Shader gradientShader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [startColor, endColor],
      ).createShader(Rect.fromLTRB(0, 0, size.width, gradientBottomY));

      chartPath.lineTo(size.width, gradientBottomY);
      chartPath.lineTo(0, gradientBottomY);
      chartPath.close();
      canvas.drawPath(
          chartPath,
          Paint()
            ..shader = gradientShader
            ..style = PaintingStyle.fill);
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

    int dashLength = 5;

    if (pricePoint != null) {
      double startPosition = 10;
      double stopDashPosition = startPosition + dashLength.toDouble();
      double pointDx = placedPoint?.dx ?? size.width;

      bool dash = true;
      while (startPosition < size.height + 50) {
        if (dash) {
          canvas.drawLine(Offset(pointDx, startPosition),
              Offset(pointDx, stopDashPosition), dashedLinePaint);
        } else {
          canvas.drawLine(Offset(pointDx, startPosition),
              Offset(pointDx, stopDashPosition), transparentDashedLinePaint);
        }

        startPosition += dashLength;
        stopDashPosition += dashLength;

        dash = !dash;
      }
      canvas.drawCircle(placedPoint ?? Offset(lastX, lastY), 5,
          Paint()..color = pressedPaintColor);
    } else {
      double dashPosition = lastX;
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
    List<String> monthNames = [
      'Empty',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    TextPainter pricePainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    pricePainter.text = TextSpan(
      text: prices[chartIndex].toString(),
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );

    pricePainter.layout();

    TextPainter percentagePainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    double percentage =
        (prices[chartIndex] - prices.first) / prices.first * 100;
    Color percentageColor = percentage >= 0 ? Colors.green : Colors.red;
    percentagePainter.text = TextSpan(
      text: '${percentage.toStringAsFixed(2)}%',
      style: TextStyle(color: percentageColor, fontSize: 16),
    );
    percentagePainter.layout();

    TextPainter datePainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    String displayDate =
        '${dates[chartIndex].day} ${monthNames[dates[chartIndex].month]} ${dates[chartIndex].year}';
    datePainter.text = TextSpan(
      text: displayDate,
      style: const TextStyle(color: Colors.black, fontSize: 14),
    );

    datePainter.layout();

    double labelRectWidth = pricePainter.width + percentagePainter.width + 36;
    double labelRectHeight = pricePainter.height + datePainter.height + 12;
    if (pricePoint != null) {
      double boundedLabelRectDx = 0;
      bool bounded = false;
      if (chartAxis[chartIndex].dx <= labelRectWidth / 2) {
        bounded = true;
        boundedLabelRectDx = 0;
      } else if (chartAxis[chartIndex].dx >= size.width - labelRectWidth / 2) {
        bounded = true;
        boundedLabelRectDx = size.width - labelRectWidth;
      }

      Rect labelRect = Rect.fromLTWH(
          bounded
              ? boundedLabelRectDx
              : chartAxis[chartIndex].dx - labelRectWidth / 2,
          -40,
          labelRectWidth,
          labelRectHeight
          // Add padding above and below the text
          );
      // Draw grey background behind the text labels
      const radius = Radius.circular(4); // Adjust the radius as needed
      final roundedRect = RRect.fromRectAndCorners(labelRect,
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius);

      final backgroundPaint = Paint()
        ..color = Colors.grey.withOpacity(0.5) // Color of the rectangle
        ..style = PaintingStyle.fill;

      canvas.drawRRect(roundedRect, backgroundPaint);
      pricePainter.paint(
          canvas,
          Offset(
              bounded
                  ? boundedLabelRectDx +
                      labelRectWidth / 4 -
                      pricePainter.width / 2
                  : chartAxis[chartIndex].dx -
                      pricePainter.width / 2 -
                      labelRectWidth / 4,
              -36));

      percentagePainter.paint(
          canvas,
          Offset(
              bounded
                  ? boundedLabelRectDx +
                      labelRectWidth / 4 +
                      pricePainter.width / 2 +
                      12
                  : chartAxis[chartIndex].dx +
                      pricePainter.width / 2 -
                      labelRectWidth / 4 +
                      12,
              -36));

      datePainter.paint(
          canvas,
          Offset(
              bounded
                  ? boundedLabelRectDx +
                      labelRectWidth / 2 -
                      datePainter.width / 2
                  : chartAxis[chartIndex].dx - datePainter.width / 2,
              -36 + percentagePainter.height + 2));
    }

    if (pricePoint == null) {
      // Draw y-axis labels with divisions
      TextPainter yLabelPainter = TextPainter(
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      );

      double difference = maxValue - minValue;
      String standardForm = difference.toStringAsExponential();

      int? secondSignificantNumber = int.tryParse(standardForm[2]);
      bool rounded = secondSignificantNumber != null
          ? secondSignificantNumber >= 5
              ? true
              : false
          : false;

      // Rounding the number up (works with decimals also). To get the first significant value.
      double significantValue = rounded
          ? double.parse(standardForm[0]) + 1
          : double.parse(standardForm[0]);
      // print(rounded);
      List<String> parts = standardForm.split('e');
      int power = int.parse(parts[1]);
      double differenceDivision = significantValue * pow(10, power);
      int significantDifferenceNumber =
          int.parse(differenceDivision.toStringAsExponential()[0]);
      int yDivisions = significantDifferenceNumber % 3 == 0 ? 3 : 2;
      double yDivisionInterval = differenceDivision / yDivisions;
      bool muchDifference =
          int.parse(differenceDivision.toStringAsExponential()[0]) > yDivisions
              ? true
              : false;

      int differenceLength = findDifferenceLength(minValue, maxValue);

      double roundedMinValue = muchDifference
          ? double.parse(minValue.toStringAsPrecision(differenceLength + 1))
          : double.parse(minValue.toStringAsPrecision(differenceLength + 2));

      int fixedDecimalPoint =
          getFixedDecimalPoints(yDivisions, differenceDivision, power);

      for (int i = 0; i <= yDivisions; i++) {
        double labelValue = roundedMinValue + (i * yDivisionInterval);
        yLabelPainter.text = TextSpan(
          text: !muchDifference && differenceDivision < 1
              ? labelValue.toStringAsFixed(fixedDecimalPoint + 1)
              : labelValue.toStringAsFixed(fixedDecimalPoint),
          style: const TextStyle(color: Colors.black, fontSize: 12),
        );
        yLabelPainter.layout();
        double y = size.height -
            ((labelValue - minValue) / (maxValue - minValue)) * size.height -
            (yLabelPainter.height / 2);

        // Draw grey background behind the text labels
        Rect labelRect = Rect.fromLTWH(
          7, // Add some padding to the left side of the text
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
        yLabelPainter.paint(canvas, Offset(10, y));
      }
    }
    // Define the number of divisions for the x-axis
    int xDivisions = 6;
    double xDivisionInterval =
        (maxDate.millisecondsSinceEpoch - minDate.millisecondsSinceEpoch) /
            xDivisions;

    // Draw x-axis labels with divisions
    TextPainter xLabelPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    List<DateTime> datesPlotted = [];
    for (int i = 1; i <= xDivisions; i++) {
      DateTime divisionDate = DateTime.fromMillisecondsSinceEpoch(
          minDate.millisecondsSinceEpoch + (i * xDivisionInterval).toInt());
      String xDate;

      if (datesPlotted.isNotEmpty) {
        if (datesPlotted.last.year == divisionDate.year) {
          if (datesPlotted.last.month == divisionDate.month) {
            xDate = divisionDate.day.toString();
          } else {
            xDate = monthNames[divisionDate.month];
          }
        } else {
          xDate = divisionDate.year.toString();
        }
      } else {
        if (dates.last.year - dates.first.year <= 4) {
          if (dates.last.month - dates.first.month < 3) {
            xDate = divisionDate.day.toString();
          } else {
            xDate = monthNames[divisionDate.month];
          }
        } else {
          xDate = divisionDate.year.toString();
        }
      }

      datesPlotted.add(divisionDate);

      xLabelPainter.text = TextSpan(
        text: xDate,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      xLabelPainter.layout();
      double x =
          (i * (size.width * 0.9 / xDivisions)) - (xLabelPainter.width / 2);
      xLabelPainter.paint(canvas, Offset(x, size.height * 1.35));
    }

    if (pricePoint == null) {
      TextPainter percentagePainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      double percent = (prices.last - prices.first) / prices.first * 100;
      Color percentColor = percent >= 0 ? Colors.green : Colors.red;
      percentagePainter.text = TextSpan(
        text: '${percent.toStringAsFixed(2)}%',
        style: TextStyle(color: percentColor, fontSize: 16),
      );
      percentagePainter.layout();

      percentagePainter.paint(
          canvas,
          Offset(
              size.width / 2 - percentagePainter.width / 2, size.height * 1.2));
    }
  }

  int findDifferenceLength(double min, double max) {
    int count = 0;
    String strMin = min.toString();
    String strMax = max.toString();

    while (strMin[count] == strMax[count]) {
      count++;
    }

    count = count == 0 ? 1 : count;

    return count;
  }

  int getFixedDecimalPoints(int yDivisions, double difference, int power) {
    //FOR DIFFERENCE GREATER THAN 1.
    if (power < 0) {
      return power.abs();
    }
    int points = 0;

    double division = difference / yDivisions;
    String strDivision = division.toString();

    if (strDivision.contains('.')) {
      List<String> strDivisions = strDivision.split('.');

      while (strDivisions[1][points] != '0') {
        points++;
        if (strDivisions[1].length >= points) break;
      }
    }

    return points;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // No need to repaint since the chart is static
  }
}
