import '../../../Helper/String.dart';

class AttributeSetModel {
  String? id;
  String? name;
  String? status;
  AttributeSetModel({
    this.id,
    this.name,
    this.status,
  });
  factory AttributeSetModel.fromJson(Map<String, dynamic> json) {
    return AttributeSetModel(
      id: json[ID],
      name: json["name"],
      status: json["status"],
    );
  }
}
