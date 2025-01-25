import '../../Helper/String.dart';

class Brand {
  String? id;
  String? name;
  String? image;
  String? relativePath;
  Brand({this.id, this.name, this.image, this.relativePath});
  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
        id: json[ID],
        name: json["name"],
        image: json["image"],
        relativePath: json["relative_path"],);
  }
}
