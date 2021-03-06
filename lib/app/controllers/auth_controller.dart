import 'dart:io';

import 'package:chat_app/app/data/models/users_model.dart';
import 'package:chat_app/app/routes/app_pages.dart';
import 'package:chat_app/app/shared/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';

class AuthController extends GetxController {
  var isSkipIntro = false.obs;
  var isAuth = false.obs;
  var isLoading = false.obs;
  String? token;
  final box = GetStorage();

  GoogleSignIn? _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  UserCredential? userCredential;

  var user = UsersModel().obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> firstInitialized() async {
    await skipIntro().then((value) {
      if (value) {
        isSkipIntro.value = true;
      }
    });
    await autoLogin().then((value) {
      print(value);
      if (value) {
        isAuth.value = true;
      }
    });
  }

  Future<bool> skipIntro() async {
    // kita akan mengubah isSkipIntro => true
    final box = GetStorage();
    if (box.read('skipIntro') != null || box.read('skipIntro') == true) {
      return true;
    }
    return false;
  }

  Future<bool> autoLogin() async {
    // kita akan mengubah isAuth => true : Auto Login
    try {
      final isSignIn = await _googleSignIn!.isSignedIn();
      print("Sign In");
      print(isSignIn);
      if (isSignIn) {
        token = await FirebaseMessaging.instance.getToken();
        await _googleSignIn!
            .signInSilently()
            .then((value) => _currentUser = value);
        final googleAuth = await _currentUser!.authentication;
        /** untuk mendapatkan data credential yang terdapat dalam akun google
         *  yang digunakan untuk dimasukan kedalam auth firebase,
         * karena firebase membutuhkan data credential 
        */
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => userCredential = value);

        print("User Credential");
        print(userCredential);

        // Masukan data ke firebase Firestore...
        CollectionReference users = firestore.collection('users');

        await users.doc(_currentUser!.email).update({
          'lastSignInTime':
              userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
          "token": token,
        });

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;
        user(UsersModel.fromJson(currUserData));
        user.refresh();

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();
        if (listChats.docs.length != 0) {
          List<ChatUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat["lastTime"],
                total_unread: dataDocChat['total_unread']));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }
        user.refresh();
        Get.offAllNamed(Routes.HOME);
        return true;
      }
      return false;
    } catch (err) {
      print(
          "========================================================================================");
      print(err);
      return false;
    }
  }

  Future<void> login() async {
    try {
      //  untuk handle kebocoran data user sebelum login
      await _googleSignIn!.signOut();

      // ini digunakan untuk mendapatkan google account
      await _googleSignIn!.signIn().then((value) => _currentUser = value);

      // ini untuk mengecek status login user
      final isSignIn = await _googleSignIn!.isSignedIn();
      if (isSignIn) {
        // berhasil login
        print("Sudah berhasil login dengan akun :");
        print(_currentUser);

        // dapatkan data auth dari login dengan google
        final googleAuth = await _currentUser!.authentication;
        /** untuk mendapatkan data credential yang terdapat dalam akun google
         *  yang digunakan untuk dimasukan kedalam auth firebase,
         * karena firebase membutuhkan data credential 
        */
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => userCredential = value);

        print("User Credential");
        print(userCredential);

        // Simpan Status user bahwa sudah pernah login dan tidak akan menampilkan introduction kembali
        if (box.read('skipIntro') != null) {
          box.remove('skipIntro');
        }
        if (box.read('isLogin') != null) {
          box.remove('isLogin');
        }
        box.write('skipIntro', true);
        box.write('isLogin', true);

        // Masukan data ke firebase Firestore...
        CollectionReference users = firestore.collection('users');
        token = await FirebaseMessaging.instance.getToken();

        // Membuat Token FCM

        final checkUser = await users.doc(_currentUser!.email).get();
        if (checkUser.data() == null) {
          await users.doc(_currentUser!.email).set({
            'uid': userCredential!.user!.uid,
            'name': _currentUser!.displayName,
            'keyName': _currentUser!.displayName!.substring(0, 1).toUpperCase(),
            'email': _currentUser!.email,
            'photoUrl': _currentUser!.photoUrl ?? "noimage",
            'status': 'Pengguna Baru',
            'creationTime':
                userCredential!.user!.metadata.creationTime!.toIso8601String(),
            'lastSignInTime': userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
            'updatedTime': DateTime.now().toIso8601String(),
            'token': token,
          });
          await users.doc(_currentUser!.email).collection('chats');
        } else {
          await users.doc(_currentUser!.email).update({
            'lastSignInTime': userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
            'token': token,
          });
        }

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;
        user(UsersModel.fromJson(currUserData));
        user.refresh();

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();
        if (listChats.docs.length != 0) {
          List<ChatUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat["lastTime"],
                total_unread: dataDocChat['total_unread']));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }
        user.refresh();

        isAuth.value = true;
        Get.offAllNamed(Routes.HOME);
      } else {
        print("tidak berhasil login");
      }

      // print(_currentUser);
    } catch (error) {
      print(error);
    }
  }

  Future<void> logout() async {
    BuildContext context;
    Get.defaultDialog(
        title: "Waiting to Logout",
        titleStyle: blackTextStyle.copyWith(
          fontSize: 12,
          fontWeight: bold,
        ),
        backgroundColor: Color.fromARGB(0, 235, 235, 235).withOpacity(0.7),
        barrierDismissible: false,
        content: LottieBuilder.asset(
          "assets/lottie/loading.json",
          width: 100,
        ));
    box.remove("isLogin");
    box.write("isLogin", false);
    await _googleSignIn!.disconnect();
    await _googleSignIn!.signOut().then((value) {
      print(box.read("isLogin"));
      exit(0);
    });
    // Get.offAllNamed(Routes.LOGIN);
  }
// Profile

  void changeProfile(String name, String status) {
    String date = DateTime.now().toIso8601String();
    // Update Firebase
    CollectionReference users = firestore.collection('users');

    users.doc(_currentUser!.email).update({
      'name': name,
      'keyName': name.substring(0, 1).toUpperCase(),
      'status': status,
      'lastSignInTime':
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      'updatedTime': date
    });

    // Update Model
    user.update(
      (user) {
        user!.name = name;
        user.keyName = name.substring(0, 1).toUpperCase();
        user.status = status;
        user.lastSignInTime =
            userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
        user.updatedTime = date;
      },
    );

    user.refresh();
    Get.defaultDialog(title: "Success", middleText: "Change Profile success,");
  }

  // Update Status
  void updateStatus(String status) {
    String date = DateTime.now().toIso8601String();
    // Update Firebase
    CollectionReference users = firestore.collection('users');

    users.doc(_currentUser!.email).update({
      'status': status,
      'lastSignInTime':
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      'updatedTime': date
    });

    // Update Model
    user.update(
      (user) {
        user!.status = status;
        user.lastSignInTime =
            userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
        user.updatedTime = date;
      },
    );

    user.refresh();
    Get.defaultDialog(title: "Success", middleText: "Change Status success,");
  }

// search
  void addNewConnection(String friendEmail) async {
    bool flagNewConnection = false;
    var chat_id;

    String date = DateTime.now().toIso8601String();
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");

    final docChats =
        await users.doc(_currentUser!.email).collection("chats").get();

    if (docChats.docs.length != 0) {
      // user sudah pernah chat dengan siapapun
      final checkConnection = await users
          .doc(_currentUser!.email)
          .collection("chats")
          .where("connection", isEqualTo: friendEmail)
          .get();

      if (checkConnection.docs.length != 0) {
        // sudah pernah buat koneksi dengan => friendEmail
        flagNewConnection = false;

        // chat_id from chats collection
        chat_id = checkConnection.docs[0].id;
      } else {
        //  belum pernah chat dengan friendEmail
        // buat connection...
        flagNewConnection = true;
      }
    } else {
      //  belum pernah chat dengan friendEmail
      // buat connection...
      flagNewConnection = true;
    }
    // FIXING

    if (flagNewConnection) {
      // cek dari chats collection => connection => mereka berdua,
      // apakah ada doc yang chat antara mereka berdua
      // 1. kalo misalnya ada
      final chatsDocs = await chats.where("connections", whereIn: [
        [
          _currentUser!.email,
          friendEmail,
        ],
        [
          friendEmail,
          _currentUser!.email,
        ]
      ]).get();

      if (chatsDocs.docs.length != 0) {
        // terdapat data chats (sudah ada connection antara mereka berdua)
        final chatDataId = chatsDocs.docs[0].id;
        final chatsData = chatsDocs.docs[0].data() as Map<String, dynamic>;

        await users
            .doc(_currentUser!.email)
            .collection("chats")
            .doc(chatDataId)
            .set({
          "connection": friendEmail,
          "lastTime": chatsData["lastTime"],
          "total_unread": 0,
        });

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();
        if (listChats.docs.length != 0) {
          List<ChatUser> dataListChats = List.empty();
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat["lastTime"],
                total_unread: dataDocChat['total_unread']));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        // disini => data yang lama jangan di ganti dengan data yang baru

        chat_id = chatDataId;
        user.refresh();
      } else {
        // mereka berdua benar benar belum ada connection

        final newChatDoc = await chats.add({
          "connections": [
            _currentUser!.email,
            friendEmail,
          ],
        });

        await chats.doc(newChatDoc.id).collection("chat");

        await users
            .doc(_currentUser!.email)
            .collection("chats")
            .doc(newChatDoc.id)
            .set({
          "connection": friendEmail,
          "lastTime": date,
          "total_unread": 0,
        });

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();
        if (listChats.docs.length != 0) {
          List<ChatUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat["lastTime"],
                total_unread: dataDocChat['total_unread']));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }
        chat_id = newChatDoc.id;
        user.refresh();
      }
    }

    final updateStatusChat = await chats
        .doc(chat_id)
        .collection("chat")
        .where("isRead", isEqualTo: false)
        .where("penerima", isEqualTo: _currentUser!.email)
        .get();

    updateStatusChat.docs.forEach((element) async {
      await chats
          .doc(chat_id)
          .collection("chat")
          .doc(element.id)
          .update({"isRead": true});
    });

    await users
        .doc(_currentUser!.email)
        .collection("chats")
        .doc(chat_id)
        .update({
      "total_unread": 0,
    });

    Get.toNamed(Routes.CHAT_ROOM, arguments: {
      "chat_id": chat_id,
      "friendEmail": friendEmail,
      // "friendUser": Frienduser.value,
    });
  }

  screen(context) {
    BoxConstraints constraints = BoxConstraints();
    ScreenUtil.init(
      constraints,
      context: context,
      designSize: Size(390, 844),
    );
  }
}
