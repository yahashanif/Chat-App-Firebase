import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ChatRoomController extends GetxController {
  var isShowEmoji = false.obs;

  int total_undread = 0;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late FocusNode focusNode;
  late TextEditingController chatC;

  void addEmojiToChat(Emoji emoji) {
    chatC.text = chatC.text + emoji.emoji;
  }

  void deleteEmoji() {
    chatC.text = chatC.text.substring(0, chatC.text.length - 2);
  }

  void closeFocusKeyEmoji() {
    focusNode.unfocus();
    if (isShowEmoji.isTrue) {
      isShowEmoji.toggle();
    }
  }

  void newChat(
    String email,
    Map<String, dynamic> argument,
    String chat,
  ) async {
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");
    String date = DateTime.now().toIso8601String();

    final newChat =
        await chats.doc(argument['chat_id']).collection("chat").add({
      "pengirim": email,
      "penerima": argument['friendEmail'],
      "msg": chat,
      "time": date,
      "isRead": false
    });
    await users.doc(email).collection("chats").doc(argument['chat_id']).update({
      "lastTime": date,
    });

    final checkChatsFriend = await users
        .doc(argument['friendEmail'])
        .collection("chats")
        .doc(argument['chat_id'])
        .get();

    if (checkChatsFriend.exists) {
      // ini ada data chat di teman kita
      // Exitst on friend db
      // first cek total unread
      final checkTotalUnread = await chats
          .doc(argument['chat_id'])
          .collection("chat")
          .where("isRead", isEqualTo: false)
          .where("pengirim", isEqualTo: email)
          .get();

      // total unread for freind
      total_undread = checkTotalUnread.docs.length;

      await users
          .doc(argument['friendEmail'])
          .collection("chats")
          .doc(argument['chat_id'])
          .update({
        "lastTime": date,
        "total_unread": total_undread,
      });
    } else {
      // Not Exitst on friend db
      //  new
      await users
          .doc(argument['friendEmail'])
          .collection("chats")
          .doc(argument['chat_id'])
          .set({
        "connection": email,
        "lastTime": date,
        "total_unread": 1,
      });
    }

    // }
  }

  @override
  void onInit() {
    chatC = TextEditingController();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isShowEmoji.value = false;
      }
    });
    super.onInit();
  }

  @override
  void dispose() {
    chatC.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
