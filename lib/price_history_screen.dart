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
    super.initState();
    loadJsonFromAssets();
  }

  List<StockData>? stockPriceHistory;
  List<StockData>? stockData;
  bool updated = false;
  String selectedRange = '1M';
  Offset? onPress1;
  Offset? onPress2;
  List<Offset?> pointersLocation = [null, null];
//add ux
  @override
  Widget build(BuildContext context) {
    if (data != null) {
      stockData = PriceHistory.fromJson(data!).stockPriceHistory;
      dateRange(selectedRange);

      if (!updated) {
        stockPriceHistory = stockData;
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Stock Price History'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Listener(
              onPointerDown: (details) {
                if (details.device == 0) {
                  pointersLocation[0] = details.localPosition;
                }
                if (details.device == 1) {
                  pointersLocation[1] = details.localPosition;
                }
                setState(() {});
              },
              onPointerMove: (details) {
                if (details.device == 0) {
                  pointersLocation[0] = details.localPosition;
                }
                if (details.device == 1) {
                  pointersLocation[1] = details.localPosition;
                }

                onPress1 = pointersLocation[0];
                onPress2 = pointersLocation[1];
                setState(() {});
              },
              onPointerUp: (details) {
                if (details.device == 0) {
                  pointersLocation[0] = null;
                  onPress1 = null;
                }
                if (details.device == 1) {
                  pointersLocation[1] = null;
                  onPress2 = null;
                }
                setState(() {});
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 40.0),
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width - 5, 200.0),
                  painter: StockPriceChartPainter(
                      stockPriceHistory!, onPress1, onPress2),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 50.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  rangeButton(
                    '5D',
                  ),
                  rangeButton('2W'),
                  rangeButton('1M'),
                  rangeButton('3M'),
                  rangeButton('6M'),
                  rangeButton('YTD'),
                  rangeButton('1Y'),
                  rangeButton('5Y'),
                  rangeButton('All'),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  GestureDetector rangeButton(String range) {
    bool selected = selectedRange == range;
    // if (selected)
    return GestureDetector(
        onTap: () {
          setState(() {
            selectedRange = range;
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.withOpacity(selected ? 0.5 : 0)),
          child: Text(
            range,
            style: const TextStyle(color: Colors.black),
          ),
        ));
  }

  void dateRange(String range) {
    List<DateTime> dates = [];

    for (var data in stockData!) {
      dates.add(data.dateTime);
    }

    DateTime beginDate = dates.first;
    DateTime endDate = dates.last;

    switch (range) {
      case '5D':
        beginDate = endDate.subtract(const Duration(days: 5));

        break;
      case '2W':
        beginDate = endDate.subtract(const Duration(days: 14));
        break;
      case '1M':
        beginDate = endDate.subtract(const Duration(days: 30));
        break;
      case '3M':
        beginDate = endDate.subtract(const Duration(days: 91));
        break;
      case '6M':
        beginDate = endDate.subtract(const Duration(days: 183));
        break;
      case 'YTD':
        DateTime jan1 = DateTime(endDate.year, 1, 1);
        int daysFromJan1 = endDate.difference(jan1).inDays;
        beginDate = endDate.subtract(Duration(days: daysFromJan1));

        break;
      case '1Y':
        beginDate = endDate.subtract(const Duration(days: 365));
        break;
      case '5Y':
        beginDate = endDate.subtract(const Duration(days: 1825));
        break;
      case 'All':
      default:
        break;
    }

    for (int i = 0; i < dates.length - 1; i++) {
      if (beginDate.isAtSameMomentAs(dates[i]) ||
          beginDate.isBefore(dates[i])) {
        stockPriceHistory = stockData?.sublist(i);

        updated = true;
        break;
      }
    }
  }
}
