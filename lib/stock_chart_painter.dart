import 'package:flutter/material.dart';
import 'package:stock_chart_flutter/price_history_model.dart';

class StockPriceChartPainter extends CustomPainter {
  final List<StockData> stockPriceHistory;

  final Paint gridPaint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 0.4;

  StockPriceChartPainter(this.stockPriceHistory);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw chart axes
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height),
        gridPaint); // X-axis
    canvas.drawLine(Offset(0, size.height), Offset(0, 0), gridPaint); // Y-axis
    // Draw data points

    List<double> prices = [];
    for (var data in stockPriceHistory) {
      prices.add(data.price);
    }
    for (int i = 0; i < prices.length; i++) {
      double x = (i / (prices.length - 1)) * size.width; // X-coordinate
      double y = size.height -
          (prices[i] / prices.reduce((a, b) => a > b ? a : b)) *
              size.height; // Y-coordinate
      canvas.drawCircle(Offset(x, y), 2,
          Paint()..color = Colors.blue); // Draw a circle at each data point
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // No need to repaint since the chart is static
  }
}
