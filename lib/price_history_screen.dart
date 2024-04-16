import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_chart_flutter/price_history_model.dart';
import 'package:stock_chart_flutter/stock_chart_painter.dart';

class StockPriceHistoryScreen extends StatefulWidget {
  const StockPriceHistoryScreen({super.key});

  @override
  State<StockPriceHistoryScreen> createState() =>
      _StockPriceHistoryScreenState();
}

class _StockPriceHistoryScreenState extends State<StockPriceHistoryScreen> {
  Map<String, dynamic>? data;

  Future<void> loadJsonFromAssets() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    setState(() {
      data = jsonDecode(jsonString);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadJsonFromAssets();
  }

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      List<StockData> stockPriceHistory =
          PriceHistory.fromJson(data!).stockPriceHistory;

      return Scaffold(
        appBar: AppBar(
          title: Text('Stock Price History'),
        ),
        body: Center(
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width - 20, 200.0),
            painter: StockPriceChartPainter(stockPriceHistory),
          ),
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
