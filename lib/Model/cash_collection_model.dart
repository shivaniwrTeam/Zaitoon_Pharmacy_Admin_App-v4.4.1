class CashCollectionModel {
  String? id;
  String? name;
  String? mobile;
  String? orderId;
  String? cashReceived;
  String? type;
  String? amount;
  String? message;
  String? transactionDate;
  String? date;
  CashCollectionModel({
    this.id,
    this.name,
    this.mobile,
    this.orderId,
    this.cashReceived,
    this.type,
    this.amount,
    this.message,
    this.transactionDate,
    this.date,
  });
  factory CashCollectionModel.fromJson(Map<String, dynamic> json) =>
      CashCollectionModel(
        id: json["id"],
        name: json["name"],
        mobile: json["mobile"],
        orderId: json["order_id"] ?? "",
        cashReceived: json["cash_received"],
        type: json["type"],
        amount: json["amount"],
        message: json["message"],
        transactionDate: json["transaction_date"],
        date: json["date"],
      );
}
