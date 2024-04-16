class StockData {
  final String stockCode;
  final DateTime dateTime;
  final double price;

  StockData(
      {required this.stockCode, required this.dateTime, required this.price});

  factory StockData.fromJson(Map<String, dynamic> json) {
    String dateString = json['Date'];
    // List<String> dateParts = dateString.split('-');
    // int year = int.parse(dateParts[0]);
    // int month = int.parse(dateParts[1]);
    // int day = int.parse(dateParts[2]);
    // DateTime parsedDate = DateTime(year, month, day);
    DateTime dateTime = DateTime.parse(dateString);

    return StockData(
      stockCode: json['StockCode'],
      dateTime: dateTime,
      price: double.parse(
        json['Price'],
      ),
    );
  }
}

class PriceHistory {
  final bool status;
  final String message;
  final List<StockData> stockPriceHistory;

  PriceHistory({
    required this.stockPriceHistory,
    required this.status,
    required this.message,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    List<StockData> stockPriceHistory = [];

    if (json['data']['stock_price_history'] != null) {
      json['data']['stock_price_history'].forEach((priceHistory) {
        stockPriceHistory.add(StockData.fromJson(priceHistory));
      });
    }

    return PriceHistory(
        stockPriceHistory: stockPriceHistory,
        status: json['status'],
        message: json['message']);
  }
}
