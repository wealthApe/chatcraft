import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_craft/common/global_data.dart';
import 'package:flutter_chat_craft/models/user_info.dart';
import 'package:flutter_chat_craft/models/user_story.dart';
import 'package:flutter_chat_craft/res/strings.dart';
import 'package:flutter_chat_craft/widget/toast_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/apis.dart';
import '../../../widget/barrage/barrage_controller.dart';
import '../../../widget/barrage/barrage_model.dart';
import 'widget/mine_story_interactive_dialog/mine_story_interactive_dialog.dart';

class MineStoryDetailsLogic extends GetxController {
  late UserInfo userInfo;
  late UserStory userStory;

  bool isShowToolsDialog = false;
  RxInt currentImage = 0.obs;
  PageController imagesController = PageController();
  TextEditingController commentController = TextEditingController();

  Size get areaSize => Size(1.sw, 0.3.sh);

  RxBool isLike = false.obs;

  BarrageController barrageController = BarrageController();

  addBarrage(UserStoryComment comment) {
    barrageController.addBarrage(comment);
  }

  setBulletTapCallBack(BarrageModel bulletModel) {
    barrageController.pause();
  }

  @override
  void onInit() {
    super.onInit();
    userInfo = Get.arguments["userInfo"];
    userStory = Get.arguments["userStory"];
    isLike.value = userStory.storyLikes
            ?.any((like) => like.ownerId == GlobalData.userInfo.userID) ??
        true;
  }

  @override
  void onReady() {
    super.onReady();
    barrageController.init(areaSize);
    barrageController.setBulletTapCallBack(setBulletTapCallBack);
    simulateBarrage(userStory.storyComments ?? []);
  }

  Future<void> simulateBarrage(List<UserStoryComment> comments) async {
    if (comments.isEmpty) return;
    for (var comment in comments) {
      await addBarrage(comment);
      final delay = Duration(milliseconds: Random().nextInt(300) + 500);
      await Future.delayed(delay);
    }
  }

  void changeCurrent(int index) {
    currentImage.value = index;
  }

  void showToolsDialog(BuildContext context) {
    isShowToolsDialog = true;
    showDialog(
      context: context,
      barrierColor: const Color(0x573D3D3D),
      builder: (BuildContext context) {
        return MineStoryInteractiveDialog(
          height: 290.w,
          editingController: commentController,
          onSubmitted: storyComment,
        );
      },
    ).then((value) {
      isShowToolsDialog = false;
    });
  }

  void addLikeOrRemoveLike() async {
    // if (isLike.value) {
    //   //Remove Like
    //   isLike.value = !isLike.value;
    // } else {
    //   //Add Like
    //   isLike.value = !isLike.value;
    // }
    isLike.value = !isLike.value;
    var data = await Apis.addOrRemoveUserStoryLike(
      userId: GlobalData.userInfo.userID,
      storyId: userStory.storyId!,
    );
    if (data == false) {
      isLike.value = false;
      ToastUtils.toastText(StrRes.operationFailed);
    } else {
      if (data == "Successfully!") {
        bool isAdd = userStory.storyLikes
                ?.any((like) => like.ownerId == GlobalData.userInfo.userID) ??
            true;
        if (isAdd) {
          userStory.storyLikes?.removeWhere(
              (like) => like.ownerId == GlobalData.userInfo.userID);
        } else {
          userStory.storyLikes?.add(UserStoryLike(
              storyId: userStory.storyId, ownerId: GlobalData.userInfo.userID));
        }

        ToastUtils.toastText(StrRes.operationSuccessful);
      }
    }
  }

  void storyComment(String value) async {
    var data = await Apis.addUserStoryComment(
      userId: GlobalData.userInfo.userID,
      storyId: userStory.storyId!,
      content: value,
      type: UserStoryCommentType.text,
    );
    if (data == false) {
    } else {
      UserStoryComment comment = UserStoryComment.fromJson(data);
      userStory.storyComments?.add(comment);
      ToastUtils.toastText(StrRes.operationSuccessful);
      commentController.clear();
    }
  }
}
