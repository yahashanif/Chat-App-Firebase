import 'dart:convert';

import 'package:get/get.dart';

import '../models/users_model.dart';

class Provider extends GetConnect {
  void sendPushMessage(String token, String body, String title) async {
    try {
      String content = 'application/x-www-form-urlencoded';
      await post(
        'https://fcm.googleapis.com/fcm/send',
        jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAABsF8CYg:APA91bHhbIQdM1euJT5-YKzbUT7OXiiyOGf0ILo6J6ktB9Zg8wrgd8Mt6gfWab-4XuIDwJ8SmxglzYbI3HNd-wGItvCcO1jilss-h5lJLf_qiC6MGST8o7TFnfmZ-OgAsor2ojFdJb18'
        },
      );
    } catch (e) {
      print("error push notification");
    }
  }
}
