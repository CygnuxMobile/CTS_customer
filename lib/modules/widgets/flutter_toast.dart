import 'package:cts_customer/configs/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

toastMessage({required text, color, isTop = false}) {
  if (text.toString().isNotEmpty) {
    Fluttertoast.showToast(
      timeInSecForIosWeb: 5,
      gravity: isTop ? ToastGravity.TOP : ToastGravity.BOTTOM,
      msg: text,
      backgroundColor: color ?? AppColors.greenColor,
      fontSize: 14,
      textColor: AppColors.whiteColor,
    );
  }
}
