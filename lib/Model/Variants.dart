import 'package:admin_eshop/Helper/String.dart';

class Product_Varient {
  String? id;
  String? productId;
  String? attribute_value_ids;
  String? price;
  String? disPrice;
  String? type;
  String? attr_name;
  String? varient_value;
  String? availability;
  String? cartCount;
  String? stock;
  String? stockType;
  String? sku;
  String? stockStatus = '1';
  List<String>? images;
  List<String>? imagesUrl;
  List<String>? imageRelativePath;
  Product_Varient(
      {this.id,
      this.productId,
      this.attr_name,
      this.varient_value,
      this.price,
      this.disPrice,
      this.attribute_value_ids,
      this.availability,
      this.cartCount,
      this.stock,
      this.imageRelativePath,
      this.images,
      this.imagesUrl,
      this.stockType,
      this.sku,
      this.stockStatus = '1',});
  factory Product_Varient.fromJson(Map<String, dynamic> json) {
    final List<String> images = List<String>.from(json[IMAGES]);
    final List<String> variantRelativePath =
        List<String>.from(json["variant_relative_path"]);
    return Product_Varient(
        id: json[ID],
        attribute_value_ids: json['attribute_value_ids'],
        productId: json['product_id'],
        attr_name: json['attr_name'],
        varient_value: json['variant_values'],
        disPrice: json['special_price'],
        price: json['price'],
        availability: json['availability'].toString(),
        cartCount: json['cart_count'],
        stock: json['stock'],
        stockType: json['status'],
        imageRelativePath: variantRelativePath,
        sku: json['sku'],
        images: images,);
  }
  Product_Varient fromVariation(
      String id,
      String att,
      String disPrice,
      String price,
      String stockType,
      List<String> images,
      List<String> imagesUrl,
      String sku,
      String stock,
      String totalStock,
      String stkStatus,) {
    return Product_Varient(
        id: id,
        attr_name: att,
        disPrice: disPrice,
        price: price,
        images: images,
        imagesUrl: imagesUrl,
        sku: sku,
        stockType: stockType,
        stock: totalStock,
        stockStatus: stkStatus,);
  }
}
