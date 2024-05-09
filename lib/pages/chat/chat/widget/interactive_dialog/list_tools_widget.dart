import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_craft/res/images.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ListToolsWidget extends StatelessWidget {
  const ListToolsWidget({
    Key? key,
    required this.openCamera,
    required this.openPhotoAlbum,
  }) : super(key: key);

  final GestureTapCallback openCamera;
  final GestureTapCallback openPhotoAlbum;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.w,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          functionItem(iconUrl: ImagesRes.icPhotoAlbum, onTap: openPhotoAlbum),
          functionItem(iconUrl: ImagesRes.icCamera, onTap: openCamera),
        ],
      ),
    );
  }

  Widget functionItem(
      {required String iconUrl, required GestureTapCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52.w,
        height: 52.w,
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(iconUrl),
      ),
    );
  }
}
