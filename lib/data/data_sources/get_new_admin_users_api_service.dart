// // ignore_for_file: avoid_print

// import 'dart:convert';
// import 'package:homewalkers_app/data/models/new_admin_users_model.dart';
// import 'package:http/http.dart' as http;

// // --- API Service Class ---
// // هذا الكلاس مسؤول عن جلب البيانات من الـ API
// class GetNewAdminUsersApiService {
//   // الدالة تقوم بإرجاع موديل المستخدمين أو null في حالة الفشل
//   Future<NewAdminUsersModel?> getNewAdminUsers() async {
//     // الرابط الخاص بالـ API
//     const String url = 'https://apirender8.onrender.com/api/v1/users/leads-with-stages';

//     try {
//       // إرسال طلب GET إلى الرابط
//       final response = await http.get(Uri.parse(url));

//       // التحقق من نجاح الطلب (status code 200)
//       if (response.statusCode == 200) {
//         // فك تشفير الـ JSON القادم من الـ response
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
//         // تحويل الـ JSON إلى كائن Dart باستخدام الموديل
//         final allUsersModel = NewAdminUsersModel.fromJson(jsonResponse);
        
//         // إرجاع البيانات بعد تحويلها
//         return allUsersModel;
//       } else {
//         // في حالة فشل الطلب، يتم طباعة رمز الحالة
//         print('Request failed with status: ${response.statusCode}.');
//         return null;
//       }
//     } catch (e) {
//       // في حالة حدوث أي خطأ آخر (مثل مشكلة في الشبكة)
//       print('An error occurred: $e');
//       return null;
//     }
//   }
// }