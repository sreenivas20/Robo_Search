import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:robot_api_search/constants/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:robot_api_search/model/get_bot_model.dart';

class ApiService {
  List<BotModel> extractedData = [];
  List<String> botImages = [];
  Uint8List? image;
  Future<List<BotModel>> getPublic() async {
    final url = ApiUrls.botListGetUrl;

    try {
      final response = await http.get(Uri.parse(url));
      log(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = jsonDecode(response.body);
        extractedData =
            decodedData.map((json) => BotModel.fromJson(json)).toList();
        log(extractedData[0].name.toString());
        return extractedData;
      }
    } catch (e) {
      log(e.toString());
    }

    return extractedData;
  }

  Future<Uint8List> getImage(index) async {
    final url = ApiUrls.botListImage + index.toString();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        log(response.bodyBytes.toString());
        image = response.bodyBytes;
      }
      return image!;
    } catch (e) {
      
      log(e.toString());
    }
    return image!;
  }
}
