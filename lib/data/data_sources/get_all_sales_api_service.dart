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

  Future<void> saveIdToSharedPreferences(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_id', id);
    print('Saved id to SharedPreferences: $id');
  }

  Future<AllSalesModel?> fetchAllSales() async {
    final url = Uri.parse('${Constants.baseUrl}/Sales?salesisactivate=true');
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
