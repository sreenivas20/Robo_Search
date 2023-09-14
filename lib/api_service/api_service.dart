import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:robot_api_search/constants/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:robot_api_search/model/get_bot_model.dart';

class ApiService extends GetxController implements GetxService {
  @override
  void onInit() {
    super.onInit();

    loadData();
  }

  TextEditingController searchController = TextEditingController();
  List<BotModel> allBotList = [];
  List<BotModel> filteredBotList = [];

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

  void loadData() async {
    final data = await ApiService().getPublic();
    bool isInternetConnected = await checkInternetConnectivity();
    if (!isInternetConnected) {
      Get.snackbar(
        'No Internet',
        'Please check your network connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.dialog(AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text("Please connect to internet and press 'OK'"),
        actions: [
          Row(
            children: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () {
                  loadData();
                  Get.back();
                },
              ),
            ],
          )
        ],
      ));
      return;
    }

    allBotList = data;
    filteredBotList = data;
    update();
  }

  void filterBotList(String query) async {
    bool isInternetConnected = await checkInternetConnectivity();

    final filteredList = <BotModel>[];

    if (isInternetConnected) {
      filteredList.addAll(allBotList.where((bot) {
        final botName = bot.name.toLowerCase();
        return botName.contains(query.toLowerCase());
      }));
    } else {
      Get.dialog(AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text("Please connect to internet and press 'OK'"),
        actions: [
          Row(
            children: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () async {
                  loadData();
                  Get.back();
                },
              ),
            ],
          )
        ],
      ));

      return;
    }

    filteredBotList = filteredList;
    update();
  }

  Future<bool> checkInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}
