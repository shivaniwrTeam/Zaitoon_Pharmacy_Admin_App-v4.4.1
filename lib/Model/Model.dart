import 'package:intl/intl.dart';
import '../Helper/String.dart';

class Model {
  String? id;
  String? type;
  String? typeId;
  String? image;
  String? fromTime;
  String? lastTime;
  String? title;
  String? desc;
  String? status;
  String? email;
  String? date;
  String? msg;
  String? uid;
  var list;
  String? name;
  String? banner;
  List<attachment>? attach;
  Model(
      {this.id,
      this.type,
      this.typeId,
      this.image,
      this.name,
      this.banner,
      this.list,
      this.title,
      this.fromTime,
      this.desc,
      this.email,
      this.status,
      this.lastTime,
      this.msg,
      this.attach,
      this.uid,
      this.date,});
  factory Model.fromTicket(Map<String, dynamic> parsedJson) {
    String date = parsedJson[DATE_CREATED];
    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    return Model(
        id: parsedJson[ID],
        title: parsedJson[SUB],
        desc: parsedJson[DESC],
        typeId: parsedJson[TICKET_TYPE],
        email: parsedJson[EMAIL],
        status: parsedJson[STATUS],
        date: date,
        type: parsedJson[TIC_TYPE],);
  }
  factory Model.fromSupport(Map<String, dynamic> parsedJson) {
    return Model(
      id: parsedJson[ID],
      title: parsedJson[TITLE],
    );
  }
  factory Model.fromChat(Map<String, dynamic> parsedJson) {
    List<attachment> attachList;
    final listContent = parsedJson["attachments"] as List?;
    if (listContent == null || listContent.isEmpty) {
      attachList = [];
    } else {
      attachList = listContent.map((data) => attachment.setJson(data)).toList();
    }
    String date = parsedJson[DATE_CREATED];
    date = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(date));
    return Model(
        id: parsedJson[ID],
        title: parsedJson[TITLE],
        msg: parsedJson[MESSAGE],
        uid: parsedJson[USER_ID],
        name: parsedJson[NAME],
        date: date,
        attach: attachList,);
  }
}

class attachment {
  String? media;
  String? type;
  attachment({this.media, this.type});
  factory attachment.setJson(Map<String, dynamic> parsedJson) {
    return attachment(
      media: parsedJson[MEDIA],
      type: parsedJson[ICON],
    );
  }
}
