import 'package:flutter/material.dart';
import 'package:flutter_chat_craft/pages/chat/new_chat/new_chat_logic.dart';
import 'package:flutter_chat_craft/res/images.dart';
import 'package:flutter_chat_craft/res/strings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import '../../../models/contact.dart';
import '../../../widget/my_appbar.dart';
import 'package:collection/collection.dart';

import 'widget/new_chat_cursor.dart';
import 'widget/new_chat_index_bar.dart';
import 'widget/new_chat_item.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({Key? key}) : super(key: key);

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final newChatLogic = Get.find<NewChatLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(
        title: StrRes.newChat,
        color: Colors.white,
        backColor: const Color(0xFFFFC15E),
        backOnTap: () => Get.back(),
      ),
      body: Stack(children: [
        SliverViewObserver(
          controller: newChatLogic.observerController,
          sliverContexts: () {
            return newChatLogic.sliverContextMap.values.toList();
          },
          child: GetBuilder<NewChatLogic>(
              id: "chatList",
              builder: (logic) {
                return CustomScrollView(
                  key: ValueKey(newChatLogic.isShowListMode),
                  controller: newChatLogic.scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Stack(
                        children: [
                          topBack(),
                          chatOptions(),
                        ],
                      ),
                    ),
                    if (newChatLogic.contactList.isEmpty)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (newChatLogic.contactList.isNotEmpty)
                      ...newChatLogic.contactList.mapIndexed((i, e) {
                        return _buildSliver(index: i, model: e);
                      }).toList(),
                  ],
                );
              }),
        ),
        _buildCursor(),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: _buildIndexBar(),
        ),
        // AzListPage(),
      ]),
    );
  }

  Widget topBack() {
    return Container(
      width: 1.sw,
      height: 88.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFC15E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.w),
          bottomRight: Radius.circular(28.w),
        ),
      ),
    );
  }

  Widget _buildCursor() {
    return ValueListenableBuilder<CursorInfoModel?>(
      valueListenable: newChatLogic.cursorInfo,
      builder: (
        BuildContext context,
        CursorInfoModel? value,
        Widget? child,
      ) {
        Widget resultWidget = Container();
        double top = 0;
        double right = newChatLogic.indexBarWidth + 8;
        if (value == null) {
          resultWidget = const SizedBox.shrink();
        } else {
          double titleSize = 80;
          top = value.offset.dy - titleSize * 0.5;
          resultWidget = NewChatCursor(size: titleSize, title: value.title);
        }
        resultWidget = Positioned(
          top: top,
          right: right,
          child: resultWidget,
        );
        return resultWidget;
      },
    );
  }

  Widget _buildIndexBar() {
    return Container(
      key: newChatLogic.indexBarContainerKey,
      width: newChatLogic.indexBarWidth,
      alignment: Alignment.center,
      child: GetBuilder<NewChatLogic>(
          id: "cursor",
          builder: (context) {
            return NewChatIndexBar(
              parentKey: newChatLogic.indexBarContainerKey,
              symbols: newChatLogic.symbols,
              onSelectionUpdate: (index, cursorOffset) {
                newChatLogic.cursorInfo.value = CursorInfoModel(
                  title: newChatLogic.symbols[index],
                  offset: cursorOffset,
                );
                final sliverContext = newChatLogic.sliverContextMap[index];
                if (sliverContext == null) return;
                newChatLogic.observerController.jumpTo(
                  index: 0,
                  sliverContext: sliverContext,
                );
              },
              onSelectionEnd: () {
                newChatLogic.cursorInfo.value = null;
              },
            );
          }),
    );
  }

  Widget _buildSliver({
    required int index,
    required ContactModel model,
  }) {
    final users = model.users;
    if (users.isEmpty) return const SliverToBoxAdapter();
    Widget resultWidget =
        // newChatLogic.isShowListMode ?
        SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, itemIndex) {
          if (newChatLogic.sliverContextMap[index] == null) {
            newChatLogic.sliverContextMap[index] = context;
          }
          return NewChatItem(
            user: users[itemIndex],
            onTap: () => newChatLogic.toMine(users[itemIndex]),
          );
        },
        childCount: users.length,
      ),
    );
    // : SliverGrid(
    //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: 2, //Grid按两列显示
    //       mainAxisSpacing: 10.0,
    //       crossAxisSpacing: 10.0,
    //       childAspectRatio: 2.0,
    //     ),
    //     delegate: SliverChildBuilderDelegate(
    //       (BuildContext context, int itemIndex) {
    //         if (newChatLogic.sliverContextMap[index] == null) {
    //           newChatLogic.sliverContextMap[index] = context;
    //         }
    //         return NewChatItem(
    //           user: users[itemIndex],
    //           onTap: () {},
    //         );
    //       },
    //       childCount: users.length,
    //     ),
    //   );
    resultWidget = SliverStickyHeader(
      header: Container(
        height: 44.0,
        color: const Color.fromARGB(255, 243, 244, 246),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          model.section,
          style: const TextStyle(color: Colors.black54),
        ),
      ),
      sliver: resultWidget,
    );
    return resultWidget;
  }

  Widget chatOptions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
      height: 98.h,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.w),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 3),
              color: Color(0x60FFC15E),
              blurRadius: 40,
            )
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          chatButton(
            backColor: const Color(0xFFFE7C59),
            iconUrl: ImagesRes.icPrivateChat,
            iconText: StrRes.privateChat,
          ),
          chatButton(
            backColor: const Color(0xFF6F61FF),
            iconUrl: ImagesRes.icGroupChat,
            iconText: StrRes.groupChat,
          ),
          chatButton(
            backColor: const Color(0xFFFA748E),
            iconUrl: ImagesRes.icMassSend,
            iconText: StrRes.massSend,
          ),
        ],
      ),
    );
  }

  Widget chatButton({
    required Color backColor,
    required String iconUrl,
    required String iconText,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: backColor,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            iconUrl,
          ),
        ),
        Text(
          iconText,
          style: TextStyle(
            fontSize: 12.sp,
          ),
        )
      ],
    );
  }
}
