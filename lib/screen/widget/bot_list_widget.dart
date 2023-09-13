import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:robot_api_search/api_service/api_service.dart';

class BotListWidget extends StatelessWidget {
  const BotListWidget({
    super.key,
    required this.height,
    required this.width,
    required this.data,
    required this.index,
  });
  final double height;
  final double width;
  final int index;
  final data;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(border: Border.all(width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
              future: ApiService().getImage(data.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No data available'),
                  );
                }
                return Container(
                  margin: const EdgeInsets.only(
                    left: 6,
                    top: 8,
                  ),
                  height: 150.h,
                  width: 160.w,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: MemoryImage(snapshot.data!),
                    ),
                  ),
                );
              }),
          Padding(
            padding: EdgeInsets.only(top: 12.0.h, left: 5.w, bottom: 10.h),
            child: Text(
              data.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
          )
        ],
      ),
    );
  }
}
