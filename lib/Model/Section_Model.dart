import 'package:admin_eshop/Helper/Constant.dart';
import 'package:admin_eshop/Helper/String.dart';

class SectionModel {
  String? id;
  String? title;
  String? varientId;
  String? qty;
  String? productId;
  String? perItemTotal;
  String? perItemPrice;
  String? style;
  List<Product>? productList;
  List<Filter>? filterList;
  List<String>? selectedId = [];
  int? offset;
  int? totalItem;
  SectionModel(
      {this.id,
      this.title,
      this.productList,
      this.varientId,
      this.qty,
      this.productId,
      this.perItemTotal,
      this.perItemPrice,
      this.style,
      this.totalItem,
      this.offset,
      this.selectedId,
      this.filterList,});
  factory SectionModel.fromJson(Map<String, dynamic> parsedJson) {
    final List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => Product.fromJson(data))
        .toList();
    final flist = parsedJson[FILTERS] as List?;
    List<Filter> filterList = [];
    if (flist == null || flist.isEmpty) {
      filterList = [];
    } else {
      filterList = flist.map((data) => Filter.fromJson(data)).toList();
    }
    final List<String> selected = [];
    return SectionModel(
        id: parsedJson[ID],
        title: parsedJson[TITLE],
        style: parsedJson[STYLE],
        productList: productList,
        offset: 0,
        totalItem: 0,
        filterList: filterList,
        selectedId: selected,);
  }
  factory SectionModel.fromCart(Map<String, dynamic> parsedJson) {
    final List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => Product.fromJson(data))
        .toList();
    return SectionModel(
        id: parsedJson[ID],
        varientId: parsedJson[PRODUCT_VARIENT_ID],
        qty: parsedJson[QTY],
        perItemTotal: "0",
        perItemPrice: "0",
        productList: productList,);
  }
  factory SectionModel.fromFav(Map<String, dynamic> parsedJson) {
    final List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => Product.fromJson(data))
        .toList();
    return SectionModel(
        id: parsedJson[ID],
        productId: parsedJson[PRODUCT_ID],
        productList: productList,);
  }
}

class Product {
  String? id;
  String? name;
  String? desc;
  String? image;
  String? catName;
  String? type;
  String? rating;
  String? productIdentity;
  String? noOfRating;
  String? attrIds;
  String? tax;
  String? taxId;
  String? relativeImagePath;
  String? categoryId;
  String? sku;
  String? shortDescription;
  String? stock;
  List<String>? otherImage;
  List<String>? showOtherImage;
  List<Product_Varient>? prVarientList;
  List<Attribute>? attributeList;
  List<String>? selectedId = [];
  List<String>? tagList = [];
  List<Map>? deliverableCities;
  String? isFav;
  String? isReturnable;
  String? isCancelable;
  String? isPurchased;
  String? taxincludedInPrice;
  String? isCODAllow;
  String? availability;
  String? madein;
  String? indicator;
  String? stockType;
  String? cancleTill;
  String? total;
  String? banner;
  String? totalAllow;
  String? video;
  String? videoType;
  String? warranty;
  String? minimumOrderQuantity;
  String? quantityStepSize;
  String? madeIn;
  String? deliverableType;
  String? deliverableZipcodesIds;
  String? deliverableZipcodes;
  String? cancelableTill;
  String? description;
  String? gurantee;
  String? brand;
  String? downloadAllow;
  String? downloadType;
  String? downloadLink;
  bool? isFavLoading = false;
  bool? isFromProd = false;
  int? offset;
  int? totalItem;
  int? selVarient;
  List<Product>? subList;
  List<Filter>? filterList;
  Product(
      {this.id,
      this.name,
      this.desc,
      this.image,
      this.catName,
      this.type,
      this.productIdentity,
      this.otherImage,
      this.prVarientList,
      this.relativeImagePath,
      this.sku,
      this.attributeList,
      this.isFav,
      this.isCancelable,
      this.isReturnable,
      this.isCODAllow,
      this.isPurchased,
      this.availability,
      this.noOfRating,
      this.attrIds,
      this.selectedId,
      this.rating,
      this.isFavLoading,
      this.indicator,
      this.madein,
      this.tax,
      this.taxId,
      this.shortDescription,
      this.total,
      this.categoryId,
      this.subList,
      this.filterList,
      this.stockType,
      this.isFromProd,
      this.showOtherImage,
      this.cancleTill,
      this.totalItem,
      this.offset,
      this.totalAllow,
      this.minimumOrderQuantity,
      this.quantityStepSize,
      this.madeIn,
      this.banner,
      this.selVarient,
      this.video,
      this.videoType,
      this.tagList,
      this.warranty,
      this.taxincludedInPrice,
      this.stock,
      this.description,
      this.deliverableType,
      this.deliverableZipcodesIds,
      this.deliverableZipcodes,
      this.cancelableTill,
      this.gurantee,
      this.brand,
      this.downloadLink,
      this.deliverableCities,
      this.downloadAllow,
      this.downloadType,});
  factory Product.fromJson(Map<String, dynamic> json) {
    final vList = json[PRODUCT_VARIENT] as List?;
    List<Product_Varient> varientList = [];
    if (vList == null || vList.isEmpty) {
      varientList = [];
    } else {
      varientList = (json[PRODUCT_VARIENT] as List)
          .map((data) => Product_Varient.fromJson(data))
          .toList();
    }
    List<Attribute> attList = [];
    if (attList.isEmpty) {
      attList = [];
    } else {
      attList = (json[ATTRIBUTES] as List)
          .map((data) => Attribute.fromJson(data))
          .toList();
    }
    final flist = json[FILTERS] as List?;
    List<Filter> filterList = [];
    if (flist == null || flist.isEmpty) {
      filterList = [];
    } else {
      filterList = flist.map((data) => Filter.fromJson(data)).toList();
    }
    List<String> otherImage = [];
    if (otherImage.isEmpty) {
      otherImage = [];
    } else {
      otherImage = List<String>.from(json["other_images_relative_path"]);
    }
    final List<String> showOtherimage = List<String>.from(json["other_images"]);
    final List<String> selected = [];
    final List<String> tags = List<String>.from(json['tags']);
    final List<Map> deliverableCities_ = json["deliverable_cities"] is String
        ? []
        : (List<Map>.from(json["deliverable_cities"]));
    return Product(
      id: json[ID],
      name: json[NAME],
      desc: json[DESC],
      image: json[IMAGE],
      catName: json[CAT_NAME],
      rating: json[RATING],
      noOfRating: json[NO_OF_RATE],
      stock: json[STOCK],
      productIdentity: json["product_identity"],
      type: json[TYPE],
      relativeImagePath: json["relative_path"],
      isFav: json[FAV].toString(),
      isCancelable: json[ISCANCLEABLE],
      availability: json[AVAILABILITY].toString(),
      isPurchased: json[ISPURCHASED].toString(),
      isReturnable: json[ISRETURNABLE],
      otherImage: otherImage,
      showOtherImage: showOtherimage,
      prVarientList: varientList,
      sku: json["sku"],
      attributeList: attList,
      filterList: filterList,
      isFavLoading: false,
      selVarient: 0,
      attrIds: json[ATTR_VALUE],
      madein: json[MADEIN],
      indicator: json[INDICATOR].toString(),
      stockType: json[STOCKTYPE].toString(),
      tax: json[TAX_PER],
      total: json[TOTAL] ?? "0",
      categoryId: json[CATID],
      selectedId: selected,
      totalAllow: json[TOTALALOOW],
      cancleTill: json[CANCLE_TILL],
      shortDescription: json['short_description'],
      tagList: tags,
      minimumOrderQuantity: json['minimum_order_quantity'],
      quantityStepSize: json['quantity_step_size'],
      madeIn: json['made_in'],
      warranty: json['warranty_period'],
      gurantee: json['guarantee_period'],
      isCODAllow: json["cod_allowed"],
      taxincludedInPrice: json['is_prices_inclusive_tax'],
      videoType: json['video_type'],
      video: json["video_relative_path"],
      taxId: json['tax_id'],
      deliverableType: cityWiseDelivery
          ? json['deliverable_city_type']
          : json['deliverable_type'],
      deliverableZipcodesIds: json['deliverable_zipcodes_ids'],
      deliverableZipcodes: json['deliverable_zipcodes'],
      description: json['description'],
      cancelableTill: json['cancelable_till'],
      brand: json['brand'],
      downloadAllow: json['download_allowed'],
      downloadType: json['download_type'],
      downloadLink: json['download_link'],
      deliverableCities: deliverableCities_,
    );
  }
  factory Product.fromCat(Map<String, dynamic> parsedJson) {
    return Product(
      id: parsedJson[ID],
      name: parsedJson[NAME],
      image: parsedJson[IMAGE],
      banner: parsedJson[BANNER],
      isFromProd: false,
      offset: 0,
      totalItem: 0,
      tax: parsedJson[TAX],
      subList: createSubList(parsedJson["children"]),
    );
  }
  static List<Product>? createSubList(List? parsedJson) {
    if (parsedJson == null || parsedJson.isEmpty) return null;
    return parsedJson.map((data) => Product.fromCat(data)).toList();
  }
}

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
    List<String> images = [];
    if (images.isEmpty) {
      images = [];
    } else {
      images = List<String>.from(json[IMAGES]);
    }
    List<String> variantRelativePath = [];
    if (variantRelativePath.isEmpty) {
      variantRelativePath = [];
    } else {
      variantRelativePath = List<String>.from(json["variant_relative_path"]);
    }
    return Product_Varient(
        id: json[ID],
        attribute_value_ids: json[ATTRIBUTE_VALUE_ID],
        productId: json[PRODUCT_ID],
        attr_name: json[ATTR_NAME],
        varient_value: json[VARIENT_VALUE],
        disPrice: json[DIS_PRICE],
        price: json[PRICE],
        availability: json[AVAILABILITY].toString(),
        cartCount: json[CART_COUNT],
        stock: json[STOCK],
        stockType: json['status'],
        imageRelativePath: variantRelativePath,
        sku: json['sku'],
        images: images,);
  }
}

class Attribute {
  String? id;
  String? value;
  String? name;
  String? sType;
  String? sValue;
  Attribute({this.id, this.value, this.name, this.sType, this.sValue});
  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
        id: json[IDS],
        name: json[NAME],
        value: json[VALUE],
        sType: json[STYPE],
        sValue: json[SVALUE],);
  }
}

class Filter {
  String? attributeValues;
  String? attributeValId;
  String? name;
  Filter({this.attributeValues, this.attributeValId, this.name});
  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      attributeValId: json[ATT_VAL_ID],
      name: json[NAME],
      attributeValues: json[ATT_VAL],
    );
  }
}
