import '../../Helper/String.dart';

class CategoryModel {
  String? id;
  String? name;
  List<CategoryModel>? children;
  CategoryModel({
    this.id,
    this.name,
    this.children,
  });
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json[ID],
      name: json["name"],
      children: List<CategoryModel>.from(
        json["children"].map(
          (x) => CategoryModel.fromJson(x),
        ),
      ),
    );
  }
}
