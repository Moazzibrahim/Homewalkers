// // lib/presentation/widgets/toast_utils.dart

// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class ToastUtils {
//   static void showSuccessToast(BuildContext context, {required String message}) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//       fontSize: 14.0,
//     );
//   }

//   static void showErrorToast(BuildContext context, {required String message}) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.red,
//       textColor: Colors.white,
//       fontSize: 14.0,
//     );
//   }

//   static void showInfoToast(BuildContext context, {required String message}) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.blue,
//       textColor: Colors.white,
//       fontSize: 14.0,
//     );
//   }
// }