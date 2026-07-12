import 'package:airdrop/page/home.dart';
import 'package:airdrop/page/profile.dart';
import 'package:airdrop/page/youprofile.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/widget/post.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

class Post extends ChangeNotifier {
  static Future<void> add() async {
    await ByBugDatabase.add("post", CosmosRandom.randomTag(), {
      "text": postController.text,
      "uid": MyProfileData.uid(),
      "create_at": DateTime.now().toString(),
    });
    postController.clear();
    await Future.wait([
      getProfilePosts(MyProfileData.uid()),
      getPosts(),
    ]);
  }

  static Future<void> remove(String tag) async {
    await ByBugDatabase.remove("post", tag);
    await Future.delayed(Durations.medium1);
    await getProfilePosts(MyProfileData.uid());
    await getPosts();
  }

  static Future<void> getProfilePosts(String? uid) async {
    String bucket = "usersDatabaseByBugDatabase135153";
    var posts = await ByBugDatabase.getAll("post");
    var user = await ByBugDatabase.get(bucket, uid ?? MyProfileData.uid());
    profilePosts.value.clear();

    final Map<String, dynamic> usrData = user["value"];
    final String targetUID = uid ?? MyProfileData.uid();

    List<PostComponent> tempPosts = [];

    for (var element in posts) {
      Map<String, dynamic> val = element["value"];
      if (val["uid"] == targetUID) {
        tempPosts.add(
          PostComponent(
            uid: val["uid"],
            tag: element["tag"],
            dateTime: DateTime.parse(val["create_at"]),
            name: usrData["name"],
            verify: usrData["data"]["verify"] ?? false,
            photo: usrData["photo"],
            text: val["text"],
          ),
        );
      }
    }

    List<PostComponent> adminPosts = tempPosts.where((p) => p.isAdmin).toList();
    List<PostComponent> normalPosts = tempPosts.where((p) => !p.isAdmin).toList();
    adminPosts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    normalPosts.shuffle();
    tempPosts = [...adminPosts, ...normalPosts];

    profilePosts.value = tempPosts;
    profilePosts.notifyListeners();
  }

  static Future<void> getProfileYouPosts(String? uid) async {
    String bucket = "usersDatabaseByBugDatabase135153";
    var posts = await ByBugDatabase.getAll("post");
    var user = await ByBugDatabase.get(bucket, uid ?? MyProfileData.uid());
    profilePostsYou.value.clear();

    final Map<String, dynamic> usrData = user["value"];
    final String targetUID = uid ?? MyProfileData.uid();

    List<PostComponent> tempPosts = [];

    for (var element in posts) {
      Map<String, dynamic> val = element["value"];
      if (val["uid"] == targetUID) {
        tempPosts.add(
          PostComponent(
            verify: usrData["data"]["verify"] ?? false,
            tag: element["tag"],
            uid: val["uid"],
            dateTime: DateTime.parse(val["create_at"]),
            name: usrData["name"],
            photo: usrData["photo"],
            text: val["text"],
          ),
        );
      }
    }

    List<PostComponent> adminPosts = tempPosts.where((p) => p.isAdmin).toList();
    List<PostComponent> normalPosts = tempPosts.where((p) => !p.isAdmin).toList();
    adminPosts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    normalPosts.shuffle();
    tempPosts = [...adminPosts, ...normalPosts];

    profilePostsYou.value = tempPosts;
    profilePostsYou.notifyListeners();
  }

  static Future<void> getPosts() async {
    String bucket = "usersDatabaseByBugDatabase135153";
    var posts = await ByBugDatabase.getAll("post");
    var users = await ByBugDatabase.getAll(bucket);
    postsW.value.clear();
    List<PostComponent> tempPosts = [];

    for (var element in posts) {
      Map<String, dynamic> val = element["value"];
      Map<String, dynamic>? usrData;

      for (var usr in users) {
        if (val["uid"] == usr["value"]["uid"]) {
          usrData = usr["value"];
          break;
        }
      }

      if (usrData != null) {
        tempPosts.add(
          PostComponent(
            verify: usrData["data"]["verify"] ?? false,
            isAdmin: usrData["data"]["isAdmin"] ?? false,
            tag: element["tag"],
            uid: val["uid"],
            dateTime: DateTime.parse(val["create_at"]),
            name: usrData["name"],
            photo: usrData["photo"],
            text: val["text"],
          ),
        );
      }
    }
    List<PostComponent> adminPosts = tempPosts.where((p) => p.isAdmin).toList();
    List<PostComponent> normalPosts = tempPosts.where((p) => !p.isAdmin).toList();
    adminPosts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    normalPosts.shuffle();
    tempPosts = [...adminPosts, ...normalPosts];

    postsW.value = tempPosts;
    postsW.notifyListeners();
  }
}

extension PostReactions on Post {
  static Future<void> like(String tag) async {
    await ByBugDatabase.add("reaction", "${tag}_${MyProfileData.uid()}_like", {
      "tag": tag,
      "uid": MyProfileData.uid(),
      "type": "like",
    });
  }

  static Future<void> dislike(String tag) async {
    await ByBugDatabase.add("reaction", "${tag}_${MyProfileData.uid()}_dislike", {
      "tag": tag,
      "uid": MyProfileData.uid(),
      "type": "dislike",
    });
  }
}
