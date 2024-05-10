import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stock_chart_flutter/price_history_model.dart';

class StockPriceChartPainter extends CustomPainter {
  final List<StockData> stockPriceHistory;
  final Offset? pricePoint1;
  final Offset? pricePoint2;

  StockPriceChartPainter(
      this.stockPriceHistory, this.pricePoint1, this.pricePoint2);

  @override
  void paint(Canvas canvas, Size size) {
    Offset? pricePoint1 = this.pricePoint1;
    Offset? pricePoint2 = this.pricePoint2;

    if (pricePoint1 == null && pricePoint2 != null) {
      pricePoint1 = pricePoint2;
      pricePoint2 = null;
    }

    List<DateTime> dates = [];
    List<double> prices = [];
    List<Offset> chartAxis = [];
    Offset? placedPoint1;
    int chartIndex1;
    Offset? placedPoint2;
    int chartIndex2;
    double canvasCenterDx = size.width / 2;
    Color riseColor = Colors.green;
    Color riseColorShade700 = Colors.green.shade700;
    Color fallColor = Colors.red;
    Color noChangeColor = Colors.grey;
    Color normalTextColor = Colors.black87;

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
    chartIndex1 = chartAxis.length - 1;
    chartIndex2 = chartAxis.length - 1;

    if (pricePoint1 != null) {
      for (int i = 0; i < chartAxis.length - 1; i++) {
        double horizontalAxis1 = chartAxis[i].dx;
        double horizontalAxis2 = chartAxis[i + 1].dx;
        if (pricePoint1.dx >= horizontalAxis1 &&
            pricePoint1.dx <= horizontalAxis2) {
          double difference1 = horizontalAxis1 - pricePoint1.dx;
          double difference2 = horizontalAxis2 - pricePoint1.dx;

          if (difference1.abs() <= difference2.abs()) {
            placedPoint1 = chartAxis[i];
            chartIndex1 = i;
          } else {
            placedPoint1 = chartAxis[i + 1];
            chartIndex1 = i + 1;
          }
        }
      }
    }
    if (pricePoint2 != null) {
      for (int i = 0; i < chartAxis.length - 1; i++) {
        double horizontalAxis1 = chartAxis[i].dx;
        double horizontalAxis2 = chartAxis[i + 1].dx;
        if (pricePoint2.dx >= horizontalAxis1 &&
            pricePoint2.dx <= horizontalAxis2) {
          double difference1 = horizontalAxis1 - pricePoint2.dx;
          double difference2 = horizontalAxis2 - pricePoint2.dx;

          if (difference1.abs() <= difference2.abs()) {
            placedPoint2 = chartAxis[i];
            chartIndex2 = i;
          } else {
            placedPoint2 = chartAxis[i + 1];
            chartIndex2 = i + 1;
          }
        }
      }
    }

    int firstPoint = chartIndex1 <= chartIndex2 ? chartIndex1 : chartIndex2;
    int secondPoint = chartIndex1 >= chartIndex2 ? chartIndex1 : chartIndex2;
    // To remove the second point if it is the same as the first.
    pricePoint2 = chartIndex1 == chartIndex2 ? null : pricePoint2;

    bool changes1 =
        (prices[chartIndex1] - prices.first) / prices.first * 100 < 0;
    bool changes2 =
        (prices[secondPoint] - prices[firstPoint]) / prices[firstPoint] * 100 <
            0;

    Color pressedPaintColor1 = changes1 ? fallColor : riseColor;
    Color pressedPaintColor2 = changes2 ? fallColor : riseColor;
    Color paintColor = prices.first > prices.last ? fallColor : riseColor;

    // To get grey if there is no price change
    pressedPaintColor1 = prices[chartIndex1] == prices.first
        ? noChangeColor
        : pressedPaintColor1;
    pressedPaintColor2 = prices[secondPoint] == prices[firstPoint]
        ? noChangeColor
        : pressedPaintColor2;
    paintColor = prices.first == prices.last ? noChangeColor : paintColor;

    Paint chartPaint = Paint()
      ..color = paintColor.withOpacity(0.4)
      ..strokeWidth = 1.5;
    Paint pressedChartPaint1 = Paint()
      ..color = pressedPaintColor1
      ..strokeWidth = 2;
    Paint pressedChartPaint2 = Paint()
      ..color = pressedPaintColor2
      ..strokeWidth = 2;

    double gradientBottomY = size.height + (0.3 * size.height);

    // Draw lines between each pair of consecutive data points
    for (int i = 0; i < chartAxis.length - 1; i++) {
      double x1 = chartAxis[i].dx;
      double y1 = chartAxis[i].dy;
      double x2 = chartAxis[i + 1].dx;
      double y2 = chartAxis[i + 1].dy;
      // Add points to the path for the gradient area
      chartPath.lineTo(x2, y2);
      if (pricePoint1 != null && pricePoint2 != null) {
        // Draw a line between each pair of consecutive data points
        canvas.drawLine(
            Offset(x1, y1),
            Offset(x2, y2),
            i >= firstPoint && i < secondPoint
                ? pressedChartPaint2
                : chartPaint);

        bool closedPath1 = false;

        if (i == 0 && firstPoint != 0) {
          onChartPath2.moveTo(0, gradientBottomY);
          onChartPath2.lineTo(x1, y1);
          onChartPath2.lineTo(x2, y2);
        } else if (i < firstPoint) {
          onChartPath2.lineTo(x2, y2);
        } else if (i == firstPoint) {
          onChartPath2.lineTo(x1, gradientBottomY);
          onChartPath1.moveTo(x1, gradientBottomY);
          onChartPath1.lineTo(x1, y1);
          onChartPath1.lineTo(x2, y2);
        } else if (i > firstPoint && i < secondPoint) {
          onChartPath1.lineTo(x2, y2);
        } else if (i == secondPoint) {
          onChartPath1.lineTo(x1, gradientBottomY);
          closedPath1 = true;

          onChartPath2.moveTo(x1, gradientBottomY);
          onChartPath2.lineTo(x1, y1);
          onChartPath2.lineTo(x2, y2);

          // This is not the presumable solution but fixes the bug.
          if (i == chartAxis.length - 2) {
            onChartPath2.lineTo(x2, gradientBottomY);
          }
        } else if (i > secondPoint) {
          onChartPath2.lineTo(x2, y2);

          // Don't remove. fixes bugg
          if (i == chartAxis.length - 2) {
            onChartPath2.lineTo(x2, gradientBottomY);
          }
        }
        if (i == chartAxis.length - 2 && !closedPath1) {
          onChartPath1.lineTo(x2, gradientBottomY);
        }
      } else {
        // Draw a line between each pair of consecutive data points
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2),
            chartIndex1 <= i ? chartPaint : pressedChartPaint1);

        if (i == chartIndex1 - 1) {
          onChartPath2.moveTo(x2, y2);
        }
        if (i < chartIndex1) {
          onChartPath1.lineTo(x2, y2);
        } else {
          onChartPath2.lineTo(x2, y2);
        }
      }
    }

    // Adjust the percentage as needed

    if (pricePoint1 != null && pricePoint2 != null) {
      // Define colors for the gradient
      Color startColor1 =
          pressedPaintColor2.withOpacity(0.2); // Adjust opacity as needed
      Color endColor1 = pressedPaintColor2.withOpacity(0.01);
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

      onChartPath1.close();
      canvas.drawPath(
          onChartPath1,
          Paint()
            ..shader = gradientShader1
            ..style = PaintingStyle.fill);
      onChartPath2.close();
      canvas.drawPath(
          onChartPath2,
          Paint()
            ..shader = gradientShader2
            ..style = PaintingStyle.fill);
    } else if (pricePoint1 != null) {
      // Define colors for the gradient
      Color startColor1 =
          pressedPaintColor1.withOpacity(0.2); // Adjust opacity as needed
      Color endColor1 = pressedPaintColor1.withOpacity(0.01);
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

      onChartPath1.lineTo(chartAxis[chartIndex1].dx, gradientBottomY);
      onChartPath1.lineTo(0, gradientBottomY);
      onChartPath1.close();
      canvas.drawPath(
          onChartPath1,
          Paint()
            ..shader = gradientShader1
            ..style = PaintingStyle.fill);
      onChartPath2.lineTo(size.width, gradientBottomY);
      onChartPath2.lineTo(chartAxis[chartIndex1].dx, gradientBottomY);
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
    if (pricePoint2 != null) {
      double startPosition = 10;
      double stopDashPosition = startPosition + dashLength.toDouble();
      double pointDx = placedPoint2?.dx ?? size.width;

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
      canvas.drawCircle(
          placedPoint2 ?? Offset(lastX, lastY), 5, pressedChartPaint2);
    }

    if (pricePoint1 != null) {
      double startPosition = 10;
      double stopDashPosition = startPosition + dashLength.toDouble();
      double pointDx = placedPoint1?.dx ?? size.width;

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
      if (pricePoint2 != null) {
        canvas.drawCircle(placedPoint1 ?? Offset(lastX, lastY), 5,
            Paint()..color = pressedPaintColor2);
      } else {
        canvas.drawCircle(placedPoint1 ?? Offset(lastX, lastY), 5,
            Paint()..color = pressedPaintColor1);
      }
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

    //------------------- POINT 1 -------------------//

    TextPainter pricePainter1 = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    pricePainter1.text = TextSpan(
      text: prices[chartIndex1].toString(),
      style: TextStyle(color: normalTextColor, fontSize: 16),
    );

    pricePainter1.layout();

    TextPainter percentagePainter1 = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    double percentage1 =
        (prices[chartIndex1] - prices.first) / prices.first * 100;
    Color percentageColor1 = percentage1 > 0 ? riseColorShade700 : fallColor;
    percentageColor1 = percentage1 == 0 ? noChangeColor : percentageColor1;
    percentagePainter1.text = TextSpan(
      text: percentage1 > 0
          ? '+${percentage1.toStringAsFixed(2)}%'
          : '${percentage1.toStringAsFixed(2)}%',
      style: TextStyle(color: percentageColor1, fontSize: 16),
    );
    percentagePainter1.layout();

    TextPainter datePainter1 = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    String displayDate1 =
        '${dates[chartIndex1].day} ${monthNames[dates[chartIndex1].month]} ${dates[chartIndex1].year}';
    datePainter1.text = TextSpan(
      text: displayDate1,
      style: TextStyle(color: normalTextColor, fontSize: 14),
    );

    datePainter1.layout();

    double labelRectWidth1 = pricePainter1.width + percentagePainter1.width;
    double labelRectHeight = pricePainter1.height + datePainter1.height;
    if (pricePoint2 != null) {
      labelRectWidth1 = pricePainter1.width >= datePainter1.width
          ? pricePainter1.width
          : datePainter1.width;
    }

    int paddingLabelWidth = 12;
    int paddingLabelHeight = 12;
    // Adding Padding to the shape
    labelRectWidth1 += paddingLabelWidth;
    labelRectHeight += paddingLabelHeight;

    double boundedLabelRectDx1 = 0;
    bool bounded1 = false;
    if (chartAxis[chartIndex1].dx <= labelRectWidth1 / 2) {
      bounded1 = true;
      boundedLabelRectDx1 = 0;
    } else if (chartAxis[chartIndex1].dx >= size.width - labelRectWidth1 / 2) {
      bounded1 = true;
      boundedLabelRectDx1 = size.width - labelRectWidth1;
    }

    Rect labelRect1 = Rect.fromLTWH(
        bounded1
            ? boundedLabelRectDx1
            : chartAxis[chartIndex1].dx - labelRectWidth1 / 2,
        -40,
        labelRectWidth1,
        labelRectHeight);
    // Draw grey background behind the text labels
    const radius = Radius.circular(4);
    const radiusZero = Radius.zero; // Adjust the radius as needed

    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2) // Color of the rectangle
      ..style = PaintingStyle.fill;

    //------------------- POINT 2 -------------------//

    TextPainter pricePainter2 = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    pricePainter2.text = TextSpan(
      text: prices[chartIndex2].toString(),
      style: TextStyle(color: normalTextColor, fontSize: 16),
    );

    pricePainter2.layout();

    TextPainter percentagePainter2 = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    double percentage2 =
        (prices[chartIndex2] - prices.first) / prices.first * 100;
    Color percentageColor2 = percentage2 > 0 ? riseColorShade700 : fallColor;
    percentageColor2 = percentage2 == 0 ? noChangeColor : percentageColor2;
    percentagePainter2.text = TextSpan(
      text: percentage2 > 0
          ? '+${percentage2.toStringAsFixed(2)}%'
          : '${percentage2.toStringAsFixed(2)}%',
      style: TextStyle(color: percentageColor2, fontSize: 16),
    );
    percentagePainter2.layout();

    TextPainter datePainter2 = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    String displayDate2 =
        '${dates[chartIndex2].day} ${monthNames[dates[chartIndex2].month]} ${dates[chartIndex2].year}';
    datePainter2.text = TextSpan(
      text: displayDate2,
      style: TextStyle(color: normalTextColor, fontSize: 14),
    );

    datePainter2.layout();

    double labelRectWidth2 = pricePainter2.width + percentagePainter2.width;

    if (pricePoint1 != null) {
      labelRectWidth2 = pricePainter2.width >= datePainter2.width
          ? pricePainter2.width
          : datePainter2.width;
    }

    // Adding Padding to the shape
    labelRectWidth2 += paddingLabelWidth;

    double boundedLabelRectDx2 = 0;
    bool bounded2 = false;
    if (chartAxis[chartIndex2].dx <= labelRectWidth2 / 2) {
      bounded2 = true;
      boundedLabelRectDx2 = 0;
    } else if (chartAxis[chartIndex2].dx >= size.width - labelRectWidth2 / 2) {
      bounded2 = true;
      boundedLabelRectDx2 = size.width - labelRectWidth2;
    }

    Rect labelRect2 = Rect.fromLTWH(
        bounded2
            ? boundedLabelRectDx2
            : chartAxis[chartIndex2].dx - labelRectWidth2 / 2,
        -40,
        labelRectWidth2,
        labelRectHeight);

    //------------------- POINT 3 -------------------//

    double price1 =
        chartIndex1 <= chartIndex2 ? prices[chartIndex1] : prices[chartIndex2];
    double price2 =
        chartIndex1 <= chartIndex2 ? prices[chartIndex2] : prices[chartIndex1];
    List<String> price2ListString = price2.toString().split('.');
    List<String> price1ListString = price1.toString().split('.');
    int fixedDecimalPoint;

    if (price1ListString.length > 1 && price2ListString.length > 1) {
      fixedDecimalPoint =
          price1ListString[1].length >= price2ListString[1].length
              ? price1ListString[1].length
              : price2ListString[1].length;
    } else if (price1ListString.length > 1) {
      fixedDecimalPoint = price1ListString.length;
    } else if (price2ListString.length > 1) {
      fixedDecimalPoint = price2ListString.length;
    } else {
      fixedDecimalPoint = 0;
    }

    Color priceColor = price2 > price1 ? riseColor : fallColor;
    priceColor = price2 == price1 ? noChangeColor : priceColor;

    String pointDifference =
        (price2 - price1).toStringAsFixed(fixedDecimalPoint);
    String pointPercentage =
        '${((price2 - price1) / price1 * 100).toStringAsFixed(2)}%';

    TextPainter priceDifferencePainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    priceDifferencePainter.text = TextSpan(
      text: pointDifference,
      style: TextStyle(color: priceColor, fontSize: 14),
    );

    priceDifferencePainter.layout();

    TextPainter percentageDifferencePainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    percentageDifferencePainter.text = TextSpan(
      text: pointPercentage[0] == '-' ? pointPercentage : '+$pointPercentage',
      style: TextStyle(color: priceColor, fontSize: 14),
    );

    percentageDifferencePainter.layout();

    double labelDifferenceRectMinWidth =
        priceDifferencePainter.width >= percentageDifferencePainter.width
            ? priceDifferencePainter.width + 30
            : percentageDifferencePainter.width + 30;

    double firstRectDx = labelRect1.center.dx <= labelRect2.center.dx
        ? labelRect1.centerRight.dx
        : labelRect2.centerRight.dx;

    double secondRectDx = labelRect1.center.dx >= labelRect2.center.dx
        ? labelRect1.centerLeft.dx
        : labelRect2.centerLeft.dx;
    double labelDifferenceRectMaxWidth = secondRectDx - firstRectDx;

    double labelDifferenceRectWidth =
        labelDifferenceRectMaxWidth >= labelDifferenceRectMinWidth
            ? labelDifferenceRectMaxWidth
            : labelDifferenceRectMinWidth;

    int chartIndex = chartIndex1 < chartIndex2 ? chartIndex1 : chartIndex2;

    double labelDiffernceDx = labelDifferenceRectWidth ==
            labelDifferenceRectMinWidth
        ? (chartAxis[chartIndex1].dx - chartAxis[chartIndex2].dx).abs() / 2 +
            chartAxis[chartIndex].dx
        : (firstRectDx - secondRectDx).abs() / 2 + firstRectDx;

    bool swappable = true;
    if (labelDifferenceRectWidth == labelDifferenceRectMinWidth &&
        pricePoint2 != null &&
        pricePoint1 != null) {
      if (labelDiffernceDx <= labelRectWidth1 + labelDifferenceRectWidth / 2 &&
          chartIndex == chartIndex1) {
        labelDiffernceDx = labelRectWidth1 + labelDifferenceRectWidth / 2;

        swappable = false;
      } else if (labelDiffernceDx >=
              size.width - labelRectWidth1 - labelDifferenceRectWidth / 2 &&
          chartIndex != chartIndex1) {
        labelDiffernceDx =
            size.width - labelRectWidth1 - labelDifferenceRectWidth / 2;
        swappable = false;
      } else if (labelDiffernceDx <=
              labelRectWidth2 + labelDifferenceRectWidth / 2 &&
          chartIndex == chartIndex2) {
        labelDiffernceDx = labelRectWidth2 + labelDifferenceRectWidth / 2;
        swappable = false;
      } else if (labelDiffernceDx >=
              size.width - labelRectWidth2 - labelDifferenceRectWidth / 2 &&
          chartIndex != chartIndex2) {
        labelDiffernceDx =
            size.width - labelRectWidth2 - labelDifferenceRectWidth / 2;
        swappable = false;
      }
    }
    Rect labelDifferenceRect = Rect.fromLTWH(
        labelDiffernceDx - labelDifferenceRectWidth / 2,
        -40,
        labelDifferenceRectWidth,
        labelRectHeight);

    final labelDifferencePaint = Paint()
      ..color = priceColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    //------------------- PAINTING EACH POINT -------------------//

    if (pricePoint1 != null && pricePoint2 != null) {
      canvas.drawRect(labelDifferenceRect, labelDifferencePaint);

      percentageDifferencePainter.paint(
          canvas,
          Offset(
              labelDiffernceDx - percentageDifferencePainter.width / 2, -20));

      priceDifferencePainter.paint(canvas,
          Offset(labelDiffernceDx - priceDifferencePainter.width / 2, -36));
    }

    bool trueRight1 = chartAxis[chartIndex1].dx > chartAxis[chartIndex2].dx;
    bool trueRight2 = chartAxis[chartIndex2].dx > chartAxis[chartIndex1].dx;

    if (pricePoint1 != null) {
      bool differenceOverlap1 =
          labelDifferenceRectWidth == labelDifferenceRectMinWidth;

      bool onRight1 = chartAxis[chartIndex1].dx - labelDiffernceDx >= 0;
      if (!swappable) {
        onRight1 = trueRight1;
      }
      double pricePainter1Dx;
      double datePainter1Dx;

      if (differenceOverlap1 && pricePoint2 != null) {
        pricePainter1Dx = onRight1
            ? labelDiffernceDx +
                labelDifferenceRectWidth / 2 +
                labelRectWidth1 / 2 -
                pricePainter1.width / 2
            : labelDiffernceDx -
                labelDifferenceRectWidth / 2 -
                labelRectWidth1 / 2 -
                pricePainter1.width / 2;
        datePainter1Dx = onRight1
            ? labelDiffernceDx +
                labelDifferenceRectWidth / 2 +
                labelRectWidth1 / 2 -
                datePainter1.width / 2
            : labelDiffernceDx -
                labelDifferenceRectWidth / 2 -
                labelRectWidth1 / 2 -
                datePainter1.width / 2;

        labelRect1 = Rect.fromLTWH(
            onRight1
                ? labelDiffernceDx + labelDifferenceRectWidth / 2
                : labelDiffernceDx -
                    labelRectWidth1 -
                    labelDifferenceRectWidth / 2,
            -40,
            labelRectWidth1,
            labelRectHeight);
      } else {
        pricePainter1Dx = bounded1
            ? boundedLabelRectDx1 +
                labelRectWidth1 / 2 -
                pricePainter1.width / 2
            : chartAxis[chartIndex1].dx - pricePainter1.width / 2;
        datePainter1Dx = bounded1
            ? boundedLabelRectDx1 + labelRectWidth1 / 2 - datePainter1.width / 2
            : chartAxis[chartIndex1].dx - datePainter1.width / 2;
      }
      final RRect roundedRect1;
      if (pricePoint2 != null) {
        roundedRect1 = RRect.fromRectAndCorners(labelRect1,
            topLeft: !trueRight1 ? radius : radiusZero,
            topRight: trueRight1 ? radius : radiusZero,
            bottomLeft: !trueRight1 ? radius : radiusZero,
            bottomRight: trueRight1 ? radius : radiusZero);
      } else {
        roundedRect1 = RRect.fromRectAndCorners(labelRect1,
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: radius);
      }
      canvas.drawRRect(roundedRect1, backgroundPaint);
      if (pricePoint2 == null) {
        pricePainter1.paint(
            canvas,
            Offset(
                bounded1
                    ? boundedLabelRectDx1 + paddingLabelWidth / 4
                    : chartAxis[chartIndex1].dx -
                        labelRect1.width / 2 +
                        paddingLabelWidth / 4,
                -36));

        percentagePainter1.paint(
            canvas,
            Offset(
                bounded1
                    ? boundedLabelRectDx1 +
                        labelRect1.width -
                        paddingLabelWidth / 4 -
                        percentagePainter1.width
                    : chartAxis[chartIndex1].dx +
                        labelRect1.width / 2 -
                        paddingLabelWidth / 4 -
                        percentagePainter1.width,
                -36));
      } else {
        pricePainter1.paint(canvas, Offset(pricePainter1Dx, -36));
      }
      datePainter1.paint(
          canvas, Offset(datePainter1Dx, -36 + percentagePainter1.height + 2));
    }
    if (pricePoint2 != null) {
      bool differenceOverlap2 =
          labelDifferenceRectWidth == labelDifferenceRectMinWidth;

      bool onRight2 = chartAxis[chartIndex2].dx - labelDiffernceDx >= 0;
      if (!swappable) {
        onRight2 = trueRight2;
      }
      double datePainter2Dx;
      double pricePainter2Dx;

      if (differenceOverlap2 && pricePoint1 != null) {
        pricePainter2Dx = onRight2
            ? labelDiffernceDx +
                labelDifferenceRectWidth / 2 +
                labelRectWidth2 / 2 -
                pricePainter2.width / 2
            : labelDiffernceDx -
                labelDifferenceRectWidth / 2 -
                labelRectWidth2 / 2 -
                pricePainter2.width / 2;
        datePainter2Dx = onRight2
            ? labelDiffernceDx +
                labelDifferenceRectWidth / 2 +
                labelRectWidth2 / 2 -
                datePainter2.width / 2
            : labelDiffernceDx -
                labelDifferenceRectWidth / 2 -
                labelRectWidth2 / 2 -
                datePainter2.width / 2;

        labelRect2 = Rect.fromLTWH(
            onRight2
                ? labelDiffernceDx + labelDifferenceRectWidth / 2
                : labelDiffernceDx -
                    labelRectWidth2 -
                    labelDifferenceRectWidth / 2,
            -40,
            labelRectWidth2,
            labelRectHeight);
      } else {
        datePainter2Dx = bounded2
            ? boundedLabelRectDx2 + labelRectWidth2 / 2 - datePainter2.width / 2
            : chartAxis[chartIndex2].dx - datePainter2.width / 2;
        pricePainter2Dx = bounded2
            ? boundedLabelRectDx2 +
                labelRectWidth2 / 2 -
                pricePainter2.width / 2
            : chartAxis[chartIndex2].dx - pricePainter2.width / 2;
      }

      final RRect roundedRect2;
      if (pricePoint1 != null) {
        roundedRect2 = RRect.fromRectAndCorners(labelRect2,
            topLeft: !trueRight2 ? radius : radiusZero,
            topRight: trueRight2 ? radius : radiusZero,
            bottomLeft: !trueRight2 ? radius : radiusZero,
            bottomRight: trueRight2 ? radius : radiusZero);
      } else {
        roundedRect2 = RRect.fromRectAndCorners(labelRect2,
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: radius);
      }

      canvas.drawRRect(roundedRect2, backgroundPaint);

      if (pricePoint1 == null) {
        pricePainter2.paint(
            canvas,
            Offset(
                bounded2
                    ? boundedLabelRectDx2 +
                        labelRectWidth2 / 4 -
                        pricePainter2.width / 2
                    : chartAxis[chartIndex2].dx -
                        pricePainter2.width / 2 -
                        labelRectWidth2 / 4,
                -36));
        percentagePainter2.paint(
            canvas,
            Offset(
                bounded2
                    ? boundedLabelRectDx2 +
                        labelRectWidth2 / 4 +
                        pricePainter2.width / 2 +
                        12
                    : chartAxis[chartIndex2].dx +
                        pricePainter2.width / 2 -
                        labelRectWidth2 / 4 +
                        12,
                -36));
      } else {
        pricePainter2.paint(canvas, Offset(pricePainter2Dx, -36));
      }

      datePainter2.paint(
          canvas, Offset(datePainter2Dx, -36 + percentagePainter2.height + 2));
    }

    if (pricePoint1 == null) {
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
          style: TextStyle(color: normalTextColor, fontSize: 12),
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
        style: TextStyle(color: normalTextColor, fontSize: 12),
      );
      xLabelPainter.layout();
      double x =
          (i * (size.width * 0.9 / xDivisions)) - (xLabelPainter.width / 2);
      xLabelPainter.paint(canvas, Offset(x, size.height * 1.35));
    }

    if (pricePoint1 == null) {
      TextPainter percentagePainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      double percent = (prices.last - prices.first) / prices.first * 100;
      Color percentColor = percent > 0 ? riseColorShade700 : fallColor;
      percentColor = percent == 0 ? noChangeColor : percentColor;
      percentagePainter.text = TextSpan(
        text: percent > 0
            ? '+${percent.toStringAsFixed(2)}%'
            : '${percent.toStringAsFixed(2)}%',
        style: TextStyle(color: percentColor, fontSize: 16),
      );
      percentagePainter.layout();

      percentagePainter.paint(
          canvas,
          Offset(
              canvasCenterDx - percentagePainter.width / 2, size.height * 1.2));
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
