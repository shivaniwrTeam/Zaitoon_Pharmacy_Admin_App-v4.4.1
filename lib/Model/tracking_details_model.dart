class TrackingDetails {
  String? id;
  String? userId;
  String? userName;
  String? orderId;
  String? orderItemId;
  String? productName;
  String? price;
  String? discountedPrice;
  String? quantity;
  String? subTotal;
  String? status;
  String? remarks;
  TrackingDetails({
    this.id,
    this.userId,
    this.userName,
    this.orderId,
    this.orderItemId,
    this.productName,
    this.price,
    this.discountedPrice,
    this.quantity,
    this.subTotal,
    this.status,
    this.remarks,
  });
  factory TrackingDetails.fromJson(Map<String, dynamic> json) =>
      TrackingDetails(
        id: json["id"],
        userId: json["user_id"],
        userName: json["user_name"],
        orderId: json["order_id"],
        orderItemId: json["order_item_id"],
        productName: json["product_name"],
        price: json["price"],
        discountedPrice: json["discounted_price"],
        quantity: json["quantity"],
        subTotal: json["sub_total"],
        status: json["status"],
        remarks: json["remarks"],
      );
}
