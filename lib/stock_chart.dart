import 'package:flutter/material.dart';

class StockPriceChart extends StatelessWidget {
  final List<double> prices; // List of stock prices
  final double width;
  final double height;

  StockPriceChart({
    @required this.prices,
    this.width = 300,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: StockPriceChartPainter(prices),
    );
  }
}

class StockPriceChartPainter extends CustomPainter {
  final List<double> prices;
  final Paint gridPaint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 1;

  StockPriceChartPainter(this.prices);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw chart axes
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height),
        gridPaint); // X-axis
    canvas.drawLine(Offset(0, size.height), Offset(0, 0), gridPaint); // Y-axis

    // Draw data points
    for (int i = 0; i < prices.length; i++) {
      double x = (i / (prices.length - 1)) * size.width; // X-coordinate
      double y = size.height -
          (prices[i] / prices.reduce((a, b) => a > b ? a : b)) *
              size.height; // Y-coordinate
      canvas.drawCircle(Offset(x, y), 4,
          Paint()..color = Colors.blue); // Draw a circle at each data point
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // No need to repaint since the chart is static
  }
}
