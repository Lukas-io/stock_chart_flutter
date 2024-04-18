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

  List<StockData>? stockPriceHistory;
  List<StockData>? stockData;
  @override
  Widget build(BuildContext context) {
    if (data != null) {
      stockData = PriceHistory.fromJson(data!).stockPriceHistory;

      if (stockPriceHistory == null) {
        stockPriceHistory = stockData;
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Stock Price History'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width - 20, 200.0),
              painter: StockPriceChartPainter(stockPriceHistory!),
            ),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        dateRange('5D');
                      });
                    },
                    child: const Text(
                      '5D',
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            )
          ],
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  void dateRange(String range) {
    List<DateTime> dates = [];

    for (var data in stockPriceHistory!) {
      dates.add(data.dateTime);
    }
    print(dates.length);

    // DateTime maxDate = dates
    //     .reduce((value, element) => value.isAfter(element) ? value : element);
    //

    DateTime beginDate = dates.first;
    DateTime endDate = dates.last;

    switch (range) {
      case '5D':
        beginDate = endDate.subtract(const Duration(days: 50));
        break;
    }
    updateDataRange(dates, beginDate);
  }

  void updateDataRange(List<DateTime> dates, DateTime startDate) {
    for (int i = 0; i < dates.length; i++) {
      if (startDate.isAtSameMomentAs(dates[i]) ||
          startDate.isBefore(dates[i])) {
        print(stockPriceHistory?.length);
        stockPriceHistory = stockPriceHistory?.sublist(i);
        break;
      }
    }
  }
}
