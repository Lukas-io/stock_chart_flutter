class StockPrice {
  final String StockCode;
}

class PriceHistory {
  final bool status;
  final String message;
  final List stockPriceHistory;

  PriceHistory({
    required this.stockPriceHistory,
    required this.status,
    required this.message,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
        stockPriceHistory: json['data']['stock_price_history'],
        status: json['status'],
        message: json['message']);
  }
}
