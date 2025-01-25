import '../../Helper/String.dart';

class ZipCodeModel {
  String? id;
  String? zipcode;
  String? dateCreated;
  String? img;
  String? status;
  String? balance;
  String? mobile;
  String? city;
  String? area;
  String? street;
  ZipCodeModel({
    this.id,
    this.zipcode,
    this.dateCreated,
  });
  factory ZipCodeModel.fromJson(Map<String, dynamic> json) {
    return ZipCodeModel(
      id: json[ID],
      zipcode: json["zipcode"],
      dateCreated: json['date_created'],
    );
  }
}
