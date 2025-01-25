import '../../Helper/String.dart';

class TaxesModel {
  String? id;
  String? title;
  String? percentage;
  String? status;
  TaxesModel({
    this.id,
    this.title,
    this.percentage,
    this.status,
  });
  factory TaxesModel.fromJson(Map<String, dynamic> json) {
    return TaxesModel(
      id: json[ID],
      title: json['title'],
      percentage: json['percentage'],
      status: json[STATUS],
    );
  }
  @override
  String toString() {
    return title!;
  }

  String userAsString() {
    return '#$id $title';
  }
}
