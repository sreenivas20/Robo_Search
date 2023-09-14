import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:robot_api_search/api_service/api_service.dart';
import 'package:robot_api_search/model/get_bot_model.dart';
import 'package:robot_api_search/screen/widget/bot_list_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  TextEditingController searchController = TextEditingController();
  List<BotModel> allBotList = [];
  List<BotModel> filteredBotList = [];

  @override
  Widget build(BuildContext context) {
  

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 38.0.h, left: 10.w),
                child: Text(
                  'Search',
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(width: 2)),
                  child: TextFormField(
                    controller: searchController,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: 'Search',
                        border: InputBorder.none),
                    onChanged: (query) {
                      _filterBotList(query);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Text(
                  'ALL RESULT',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
              ),
              if (filteredBotList.isEmpty && searchController.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 176.0.h),
                  child: Center(
                    child: Text(
                      'Search not found for "${searchController.text}"',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.7,
                ),
                itemCount: filteredBotList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BotListWidget(
                      index: index,
                      data: filteredBotList[index],
                      height: 190.h,
                      width: 150.h,
                    ),
                  );
                },
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black.withOpacity(0.5),
            currentIndex: 2,
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                  ),
                  label: 'Home'),
              const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.search,
                  ),
                  label: 'Search'),
              BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      height: 30.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                            colors: [
                              Color(0xffEB3386),
                              Color(0xffF83142),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  label: 'Add'),
              const BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.chat_bubble, // Use CupertinoIcons correctly
                  ),
                  label: 'chat'),
              const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_2_outlined, // Use CupertinoIcons correctly
                  ),
                  label: 'profile'),
            ]),
      ),
    );
  }

  void _loadData() async {
    final data = await ApiService().getPublic();
    bool isInternetConnected = await _checkInternetConnectivity();
    if (!isInternetConnected) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('No Internet Connection'),
            content: Text('Please connect to the internet and click ok'),
            actions: [
              TextButton(
                onPressed: () {
                  _loadData();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    setState(() {
      allBotList = data;
      filteredBotList = data;
    });
  }

  Future<bool> _checkInternetConnectivity() async {
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

  void _filterBotList(String query) {
    final filteredList = allBotList.where((bot) {
      final botName = bot.name.toLowerCase();
      return botName.contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredBotList = filteredList;
    });
  }
}
