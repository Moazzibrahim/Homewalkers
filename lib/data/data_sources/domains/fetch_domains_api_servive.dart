// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/data/models/domains/fetch_all_domains_model.dart';
import 'package:http/http.dart' as http;

class CompanyApiService {
  static const String baseUrl =
      'http://test.realatixcrm.com/api/v1/CompanyDomains';

  static Future<CompaniesResponse?> getCompanies() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CompaniesResponse.fromJson(data);
      } else {
        print('❌ Error: ${response.statusCode}');
        print('❌ Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }

  // 🔥 الدالة الجديدة
  static Future<String?> getCompanyDomainByName(String companyName) async {
    try {
      final result = await getCompanies();

      if (result != null && result.data != null) {
        final company = result.data!.firstWhere(
          (c) =>
              c.companyName?.toLowerCase().trim() ==
                  companyName.toLowerCase().trim() &&
              (c.isActive ?? false), // ✅ تتأكد إن الشركة active
          orElse: () => CompanyData(),
        );

        // لو ملقاش الشركة
        if (company.companyDomain == null) {
          print('❌ Company not found');
          return null;
        }

        return company.companyDomain;
      } else {
        print('❌ No data found');
        return null;
      }
    } catch (e) {
      print('❌ Exception in search: $e');
      return null;
    }
  }
}
