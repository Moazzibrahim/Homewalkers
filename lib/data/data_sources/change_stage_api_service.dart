import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;

class ChangeStageApiService {
  static Future<http.Response> changeStage({
    required String leadId,
    required String datebydayonly,
    required String stage,
    required String dateupdated,
    String? unitnumber,
    String? unitPrice,
    String? commissionratio,
    String? commissionmoney,
    String? cashbackratio,
    String? cashbackmoney,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/users/$leadId');

    final Map<String, dynamic> body = {
      "last_stage_date_updated": datebydayonly,
      "stage": stage,
      "stagedateupdated": dateupdated,
      "unit_price":unitPrice,
      "unitnumber": unitnumber,
      "review":false,
      "commissionration":commissionratio,
      "commissionmoney":commissionmoney,
      "cashbackratio":cashbackratio,
      "cashbackmoney":cashbackmoney,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return response;
    } catch (e) {
      throw Exception('Failed to change stage: $e');
    }
  }

  
  // الدالة الجديدة لإرسال البيانات عبر POST
  static Future<http.Response> postLeadStage({
    required String leadId,
    required String date,
    required String stage,
    required String sales,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/LeadStages');

    final Map<String, dynamic> body = {
      "LeadId": leadId,
      "date": date,
      "stage": stage,
      "sales": sales,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return response;
    } catch (e) {
      throw Exception('Failed to post lead stage: $e');
    }
  }
}
