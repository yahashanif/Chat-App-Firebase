import 'package:chat_app/app/controllers/auth_controller.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/chat_room_controller.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  final authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[900],
          leadingWidth: 125,
          leading: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 5,
                ),
                IconButton(onPressed: () {
                  Get.back();
                }, icon: Icon(Icons.arrow_back)),
                SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  child: Image.asset("assets/logo/noimage.png"),
                )
              ],
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lorem Ipsum',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Statusnya lorem',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        body: WillPopScope(
          onWillPop: () {
            if (controller.isShowEmoji.isTrue) {
              controller.isShowEmoji.value = false;
            } else {
              Navigator.pop(context);
            }

            return Future.value(false);
          },
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    controller.closeFocusKeyEmoji();
                  },
                  child: Container(
                    child: ListView(
                      children: [
                        ItemChat(isSender: true),
                        ItemChat(isSender: false),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    bottom: controller.isShowEmoji.isTrue
                        ? 5
                        : context.mediaQueryPadding.bottom),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        child: TextField(
                          controller: controller.chatC,
                          focusNode: controller.focusNode,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              onPressed: () {
                                controller.focusNode.unfocus();
                                controller.isShowEmoji.toggle();
                              },
                              icon: Icon(Icons.emoji_emotions_outlined),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Material(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.red[900],
                      child: InkWell(
                        onTap: () => controller.newChat(
                         authC.user.value.email!,
                          Get.arguments as Map<String,dynamic>,
                          controller.chatC.text,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => (controller.isShowEmoji.isTrue)
                    ? Container(
                        height: 325,
                        child: EmojiPicker(
                          onEmojiSelected: (category, emoji) {
                            controller.addEmojiToChat(emoji);
                          },
                          onBackspacePressed: () {
                            controller.deleteEmoji();
                          },
                          config: const Config(
                              columns: 7,
                              emojiSizeMax:
                                  32, // Issue: https://github.com/flutter/flutter/issues/28894
                              verticalSpacing: 0,
                              horizontalSpacing: 0,
                              initCategory: Category.RECENT,
                              bgColor: Color(0xFFF2F2F2),
                              indicatorColor: Color(0xFFB71C1C),
                              iconColor: Colors.grey,
                              iconColorSelected: Color(0xFFB71C1C),
                              progressIndicatorColor: Color(0xFFB71C1C),
                              backspaceColor: Color(0xFFB71C1C),
                              skinToneDialogBgColor: Colors.white,
                              skinToneIndicatorColor: Colors.grey,
                              enableSkinTones: true,
                              showRecentsTab: true,
                              recentsLimit: 28,
                              noRecentsText: "No Recents",
                              noRecentsStyle: TextStyle(
                                  fontSize: 20, color: Colors.black26),
                              tabIndicatorAnimDuration: kTabScrollDuration,
                              categoryIcons: CategoryIcons(),
                              buttonMode: ButtonMode.MATERIAL),
                        ),
                      )
                    : SizedBox(),
              )
            ],
          ),
        ));
  }
}

class ItemChat extends StatelessWidget {
  final bool? isSender;

  ItemChat({required this.isSender});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment:
            isSender! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
              decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: isSender!
                      ? BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15))
                      : BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15))),
              padding: EdgeInsets.all(15),
              child: Text(
                "Halo selamat datang",
                style: TextStyle(color: Colors.white),
              )),
          SizedBox(
            height: 5,
          ),
          Text("18:22 PM"),
        ],
      ),
      alignment: isSender! ? Alignment.centerRight : Alignment.centerLeft,
    );
  }
}
