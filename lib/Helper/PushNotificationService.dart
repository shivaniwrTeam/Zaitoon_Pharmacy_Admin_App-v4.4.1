import 'dart:convert';
import 'dart:io';
import 'package:admin_eshop/Screens/OrderList.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../Screens/Chat.dart';
import '../main.dart';
import 'Constant.dart';
import 'Session.dart';
import 'String.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

class PushNotificationService {
  final BuildContext? context;
  PushNotificationService({this.context});
  Future initialise() async {
    iOSPermission();
    messaging.getToken().then((token) async {
      CUR_USERID = await getPrefrence(ID);
      if (CUR_USERID != null && CUR_USERID != "") _registerToken(token);
    });
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) => onSelectNotification,
    );
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        final data = message.notification!;
        final title = data.title.toString();
        final body = data.body.toString();
        final image = message.data['image'] ?? '';
        final type = message.data['type'] ?? '';
        var id = '';
        id = message.data['type_id'] ?? '';
        if (type == "ticket_message") {
          if (CUR_TICK_ID == id) {
            if (chatstreamdata != null) {
              var parsedJson = json.decode(message.data['chat']);
              parsedJson = parsedJson[0];
              final Map<String, dynamic> sendata = {
                "id": parsedJson[ID],
                "title": parsedJson[TITLE],
                "message": parsedJson[MESSAGE],
                "user_id": parsedJson[USER_ID],
                "name": parsedJson[NAME],
                "date_created": parsedJson[DATE_CREATED],
                "attachments": parsedJson["attachments"],
              };
              final chat = {};
              chat["data"] = sendata;
              if (parsedJson[USER_ID] != CUR_USERID) {
                chatstreamdata!.sink.add(jsonEncode(chat));
              }
            }
          } else {
            if (image != null && image != 'null' && image != '') {
              generateImageNotication(title, body, image, type, id);
            } else {
              generateSimpleNotication(title, body, type, id);
            }
          }
        } else if (image != null && image != 'null' && image != '') {
          generateImageNotication(title, body, image, type, id);
        } else {
          generateSimpleNotication(title, body, type, id);
        }
      },
    );
    messaging.getInitialMessage().then(
      (RemoteMessage? message) async {
        final bool back = await getPrefrenceBool(ISFROMBACK);
        if (message != null && back) {
          final type = message.data['type'] ?? '';
          var id = '';
          id = message.data['type_id'] ?? '';
          getStatics(type, id);
          setPrefrenceBool(ISFROMBACK, false);
        }
      },
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        final type = message.data['type'] ?? '';
        var id = '';
        id = message.data['type_id'] ?? '';
        if (type == "ticket_message") {
          Navigator.push(
            context!,
            CupertinoPageRoute(
              builder: (context) => Chat(
                id: id,
                status: "",
              ),
            ),
          );
        } else {
          Navigator.push(
            context!,
            CupertinoPageRoute(
              builder: (context) => const OrderList(),
            ),
          );
        }
        setPrefrenceBool(ISFROMBACK, false);
      },
    );
  }

  Future<void> getStatics(String type, String id) async {
    CUR_USERID = await getPrefrence(ID);
    final parameter = {USER_ID: CUR_USERID};
    final Response response =
        await post(getStaticsApi, body: parameter, headers: headers)
            .timeout(const Duration(seconds: timeOut));
    if (response.statusCode == 200) {
      final getdata = json.decode(response.body);
      final bool error = getdata["error"];
      if (!error) {
        CUR_CURRENCY = getdata["currency_symbol"];
        readOrder =
            getdata["permissions"]["orders"]["read"] == "on" ? true : false;
        editOrder =
            getdata["permissions"]["orders"]["update"] == "on" ? true : false;
        deleteOrder =
            getdata["permissions"]["orders"]["delete"] == "on" ? true : false;
        readProduct =
            getdata["permissions"]["product"]["read"] == "on" ? true : false;
        editProduct =
            getdata["permissions"]["product"]["update"] == "on" ? true : false;
        deletProduct =
            getdata["permissions"]["product"]["delete"] == "on" ? true : false;
        ticketRead = getdata["permissions"]["support_tickets"]["read"] == "on"
            ? true
            : false;
        ticketWrite =
            getdata["permissions"]["support_tickets"]["update"] == "on"
                ? true
                : false;
        readCust =
            getdata["permissions"]["customers"]["read"] == "on" ? true : false;
        readDel = getdata["permissions"]["delivery_boy"]["read"] == "on"
            ? true
            : false;
        if (type == "ticket_message") {
          Navigator.push(
            context!,
            CupertinoPageRoute(
              builder: (context) => Chat(
                id: id,
                status: "",
              ),
            ),
          );
        } else {
          Navigator.push(
            context!,
            CupertinoPageRoute(
              builder: (context) => const OrderList(),
            ),
          );
        }
      }
    }
  }

  Future<void> iOSPermission() async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _registerToken(String? token) async {
    final parameter = {USER_ID: CUR_USERID, FCM_ID: token};
    final Response response =
        await post(updateFcmApi, body: parameter, headers: headers).timeout(
      const Duration(seconds: timeOut),
    );
    json.decode(response.body);
  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      final List<String> pay = payload.split(",");
      if (pay[0] == "ticket_message") {
        Navigator.push(
          context!,
          CupertinoPageRoute(
            builder: (context) => Chat(
              id: pay[1],
              status: "",
            ),
          ),
        );
      }
    } else {
      Navigator.push(
        context!,
        CupertinoPageRoute(
          builder: (context) => MyApp(),
        ),
      );
    }
  }
}

Future<dynamic> myForgroundMessageHandler(RemoteMessage message) async {
  await setPrefrenceBool(ISFROMBACK, true);
  return Future<void>.value();
}

Future<String> _downloadAndSaveImage(String url, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  final response = await http.get(Uri.parse(url));
  final file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> generateImageNotication(
  String title,
  String msg,
  String image,
  String type,
  String id,
) async {
  final largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
  final bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
  final bigPictureStyleInformation = BigPictureStyleInformation(
    FilePathAndroidBitmap(bigPicturePath),
    hideExpandedLargeIcon: true,
    contentTitle: title,
    htmlFormatContentTitle: true,
    summaryText: msg,
    htmlFormatSummaryText: true,
  );
  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'big text channel id',
    'big text channel name',
    channelDescription: 'big text channel description',
    largeIcon: FilePathAndroidBitmap(largeIconPath),
    styleInformation: bigPictureStyleInformation,
  );
  final platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(0, title, msg, platformChannelSpecifics, payload: "$type,$id");
}

const DarwinNotificationDetails darwinNotificationDetails =
    DarwinNotificationDetails(
  categoryIdentifier: "",
);
Future<void> generateSimpleNotication(
  String title,
  String msg,
  String type,
  String id,
) async {
  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: darwinNotificationDetails,
  );
  await flutterLocalNotificationsPlugin
      .show(0, title, msg, platformChannelSpecifics, payload: "$type,$id");
}
