import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatRoomController extends GetxController {
  var isShowEmoji = false.obs;

  int total_undread = 0;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late FocusNode focusNode;
  late TextEditingController chatC;
  late ScrollController scrollC;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamChat(String chat_id) {
    CollectionReference chats = firestore.collection("chats");

    return chats.doc(chat_id).collection("chat").orderBy("time").snapshots();
  }

  Stream<DocumentSnapshot<Object?>> streamFriendData(String friendEmail) {
    CollectionReference users = firestore.collection("users");

    return users.doc(friendEmail).snapshots();
  }

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
    if (chat != "") {
      CollectionReference chats = firestore.collection("chats");
      CollectionReference users = firestore.collection("users");
      String date = DateTime.now().toIso8601String();
      var isiChat = chat;
      chatC.clear();

      await chats.doc(argument['chat_id']).collection("chat").add({
        "pengirim": email,
        "penerima": argument['friendEmail'],
        "msg": isiChat,
        "time": date,
        "isRead": false,
        "groupTime": DateFormat.yMMMd('en_US').format(DateTime.parse(date))
      });

      Timer(
        Duration.zero,
        () => scrollC.jumpTo(scrollC.position.maxScrollExtent),
      );
      await users
          .doc(email)
          .collection("chats")
          .doc(argument['chat_id'])
          .update({
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
      chatC.clear();
    }
  }

  @override
  void onInit() {
    chatC = TextEditingController();
    scrollC = ScrollController();
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
    scrollC.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
