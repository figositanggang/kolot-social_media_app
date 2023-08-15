import 'package:image_picker/image_picker.dart';
import 'package:kolot/provider/add_post_navigation_provider_.dart';

pickImage(ImageSource source, {AddPostNavigationProvider? provider}) async {
  String res = "error";
  final ImagePicker imagePicker = ImagePicker();

  XFile? file;

  if (source == ImageSource.gallery) {
    file = await imagePicker.pickImage(source: ImageSource.gallery);
    res = "success";
    provider!.image = await file!.readAsBytes();
  } else if (source == ImageSource.camera) {
    file = await imagePicker.pickImage(source: source);
    res = "success";
    provider!.image = await file!.readAsBytes();
  }

  if (file != null) {
    return await file.readAsBytes();
  } else {
    return res;
  }
}
