import '../../../Helper/String.dart';

class AttributeValueModel {
  String? id;
  String? value;
  String? attributeId;
  String? attributeName;
  String? status;
  AttributeValueModel(
      {this.id, this.value, this.status, this.attributeId, this.attributeName,});
  factory AttributeValueModel.fromJson(Map<String, dynamic> json) {
    return AttributeValueModel(
      id: json[ID],
      value: json["value"],
      status: json[STATUS],
      attributeId: json["attribute_id"],
      attributeName: json["attribute_name"],
    );
  }
}
