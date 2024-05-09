import 'package:flutter_chat_craft/common/global_data.dart';
import 'package:flutter_chat_craft/models/user_story.dart';
import 'package:flutter_chat_craft/routes/app_routes.dart';
import 'package:flutter_chat_craft/utils/sp/data_persistence.dart';
import 'package:flutter_chat_craft/widget/toast_utils.dart';
import 'package:get/get.dart';
import '../../common/apis.dart';
import '../../models/user_info.dart';
import '../../routes/app_navigator.dart';

class MineLogic extends GetxController {
  late UserInfo userInfo;
  RxList<UserStory> userStories = <UserStory>[].obs;
  RxInt storyLike = 0.obs;

  @override
  void onReady() {
    super.onReady();
    getUserShowStoryList();
  }

  void setUserInfo(UserInfo info) {
    userInfo = info;
  }

  bool get isSelf => userInfo.userID == GlobalData.userInfo.userID;

  void toChat() {
    AppNavigator.startChat(userInfo: userInfo);
  }

  Future<bool> getUserShowStoryList() async {
    var data = await Apis.getUserShowStoryList(
      userId: userInfo.userID,
    );
    if (data == false) {
      return false;
    } else {
      print(data.toString());
      var storyData = data["StoryList"];
      var count = data["Count"];
      storyLike.value = count;
      for (var story in storyData) {
        UserStory info = UserStory.fromJson(story["story"]);

        List<UserStoryLike> storyLikes =
            story["story_likes"] != null ? (story["story_likes"] as List<dynamic>).map((likeJson) => UserStoryLike.fromJson(likeJson)).toList() : [];

        List<UserStoryComment> storyComments = story["story_comments"] != null
            ? (story["story_comments"] as List<dynamic>).map((commentJson) => UserStoryComment.fromJson(commentJson)).toList()
            : [];
        info.storyLikes = storyLikes;
        info.storyComments = storyComments;
        userStories.add(info);
        print(info.toString());
      }
    }
    return false;
  }

  void startMineStoryDetails(UserStory story) {
    AppNavigator.startMineStoryDetails(userInfo: userInfo, userStory: story);
  }

  void logout() {
    DataPersistence.removeToken();
    DataPersistence.removeUser();
    AppNavigator.logout();
  }

  void toProfile() {
    Get.toNamed(AppRoutes.profile, arguments: {'userInfo': userInfo});
  }
}
