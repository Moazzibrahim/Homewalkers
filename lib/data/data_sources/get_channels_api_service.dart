// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/channel_model.dart';
import 'package:http/http.dart' as http;

class GetChannelsApiService {

  Future<ChannelModelresponse?> getChannels() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/channal'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChannelModelresponse.fromJson(data);
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }
}
