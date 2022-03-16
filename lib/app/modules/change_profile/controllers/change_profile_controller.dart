import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChangeProfileController extends GetxController {
  late TextEditingController emailC;
  late TextEditingController nameC;
  late TextEditingController statusC;
  late ImagePicker imagePicker;

  XFile? pickImage = null;

  void resetImage(){
    pickImage = null;
    update();
  }

  void selectImage() async {
    try {
      final checkDataImage =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (checkDataImage != null) {
        print(checkDataImage.name);
        print(checkDataImage.path);
        pickImage = checkDataImage;
      }
        update();
    } catch (e) {
      print(e);
      pickImage = null;
      update();
    }
  }

  @override
  void onInit() {
    emailC = TextEditingController(text: 'loremipsum@gmail.com');
    nameC = TextEditingController(text: 'Lorem Ipsum');
    statusC = TextEditingController();
    imagePicker = ImagePicker();
    super.onInit();
  }

  @override
  void onClose() {
    emailC.dispose();
    nameC.dispose();
    statusC.dispose();
    super.onClose();
  }
}
