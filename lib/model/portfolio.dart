class PortfolioItem {
  final String coinId;
  final String coinName;
  final String coinSymbol;
  final String coinImage;
  final double amount; // Amount of coins owned
  final double purchasePrice; // Price per coin when purchased
  final DateTime purchaseDate;

  PortfolioItem({
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.coinImage,
    required this.amount,
    required this.purchasePrice,
    required this.purchaseDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'coinId': coinId,
      'coinName': coinName,
      'coinSymbol': coinSymbol,
      'coinImage': coinImage,
      'amount': amount,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      coinId: json['coinId'],
      coinName: json['coinName'],
      coinSymbol: json['coinSymbol'],
      coinImage: json['coinImage'],
      amount: json['amount'],
      purchasePrice: json['purchasePrice'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
    );
  }
}
