// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // مهم تضيف دي
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/all_sales_model.dart';
import 'package:http/http.dart' as http;

class GetAllSalesApiService {
  Future<AllSalesModel?> fetchSalesData(String userlogId) async {
    final url = Uri.parse('${Constants.baseUrl}/Sales?userlog=$userlogId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // افترضنا موديل AllSalesModel عنده fromJson
        final salesModel = AllSalesModel.fromJson(jsonData);
        // هنا بنجيب أول عنصر من قائمة data ونخزن الـ _id
        if (salesModel.data!.isNotEmpty) {
          String idToSave =
              salesModel.data![0].id!; // افترضنا أن الـ id في الموديل اسمه id
          await saveIdToSharedPreferences(idToSave);
        }
        return salesModel;
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching sales data: $e');
      return null;
    }
  }

  Future<AllSalesModel?> fetchSalesDataofSpecificUser(String userlogId) async {
    final url = Uri.parse('${Constants.baseUrl}/Sales?userlog=$userlogId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // افترضنا موديل AllSalesModel عنده fromJson
        final salesModel = AllSalesModel.fromJson(jsonData);
        // هنا بنجيب أول عنصر من قائمة data ونخزن الـ _id
        if (salesModel.data!.isNotEmpty) {
          String idToSave =
              salesModel.data![0].id!; // افترضنا أن الـ id في الموديل اسمه id
          await saveIdToSharedPreferencesforSpecific(idToSave);
        }
        return salesModel;
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching sales data: $e');
      return null;
    }
  }

  Future<void> saveIdToSharedPreferences(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_id', id);
    print('Saved id to SharedPreferences: $id');
  }

  Future<void> saveIdToSharedPreferencesforSpecific(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedid', id);
    print('Saved id to SharedPreferences: $id');
  }

  Future<AllSalesModel?> fetchAllSales() async {
    final url = Uri.parse('${Constants.baseUrl}/Sales?salesisactivate=true');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final salesModel = AllSalesModel.fromJson(jsonData);
        final salesList = salesModel.data;
        final prefs = await SharedPreferences.getInstance();

        if (salesList != null && salesList.isNotEmpty) {
          String? noSalesId;
          String? teamLeaderUserLogId;
          String? salesuserlogId;

          // ابحث عن Sales اسمه "No Sales"
          for (var sale in salesList) {
            final name = sale.name?.trim().toLowerCase();
            if (name == 'no sales') {
              noSalesId = sale.id;
            }
            final saveduserlogid = prefs.getString('salesId') ?? '';
            // ✅ احفظ الـ userlog._id لو الدور "Team Leader"
            final userRole = sale.userlog?.role?.trim().toLowerCase();
            if (userRole == 'team leader' &&
                sale.userlog?.id == saveduserlogid) {
              teamLeaderUserLogId = sale.id;
            } else if (userRole == 'sales' &&
                sale.userlog?.id == saveduserlogid) {
              salesuserlogId = sale.id;
            }

            if (noSalesId != null && teamLeaderUserLogId != null) break;
          }

          if (noSalesId != null) {
            await prefs.setString('no_sales_id', noSalesId);
            print('✅ Saved No Sales ID: $noSalesId');
          } else {
            print('⚠️ No "No Sales" record found.');
          }

          if (teamLeaderUserLogId != null) {
            await prefs.setString('teamleader_userlog_id', teamLeaderUserLogId);
            print('✅ Saved Team Leader UserLog ID: $teamLeaderUserLogId');
          } else if (salesuserlogId != null) {
            await prefs.setString('sales_userlog_id', salesuserlogId);
            print('✅ Saved Sales UserLog ID: $salesuserlogId');
          } else {
            print('⚠️ No Team Leader in userlog found.');
          }
        } else {
          print('⚠️ No sales data found.');
        }

        return salesModel;
      } else {
        print(
          '❌ Failed to load sales data. Status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Error fetching sales data: $e');
      return null;
    }
  }

  Future<AllSalesModel?> fetchAllSalesInTrash() async {
    final url = Uri.parse('${Constants.baseUrl}/Sales?salesisactivate=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final salesModel = AllSalesModel.fromJson(jsonData);
        return salesModel;
      } else {
        print(
          '❌ Failed to load sales data. Status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Error fetching sales data: $e');
      return null;
    }
  }
}
