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
    try {
      String text = postController.text.trim();
      if (text.isEmpty) {
        debugPrint("⚠️ Post.add: Yazı boş!");
        return;
      }

      String uid = MyProfileData.uid();
      if (uid.isEmpty) {
        debugPrint("⚠️ Post.add: UID boş!");
        return;
      }

      await ByBugDatabase.add("post", CosmosRandom.randomTag(), {
        "text": text,
        "uid": uid,
        "create_at": DateTime.now().toIso8601String(),
      });

      postController.clear();
      await Future.wait([
        getProfilePosts(uid),
        getPosts(),
      ]);

      debugPrint("✅ Post başarıyla eklendi");

    } catch (e) {
      debugPrint("❌ Post.add hatası: $e");
    }
  }

  static Future<void> remove(String tag) async {
    try {
      if (tag.isEmpty) {
        debugPrint("⚠️ Post.remove: Tag boş!");
        return;
      }

      await ByBugDatabase.remove("post", tag);
      await Future.delayed(Durations.medium1);

      String uid = MyProfileData.uid();
      if (uid.isNotEmpty) {
        await getProfilePosts(uid);
        await getPosts();
      }

      debugPrint("✅ Post başarıyla silindi");

    } catch (e) {
      debugPrint("❌ Post.remove hatası: $e");
    }
  }

  static Future<void> getProfilePosts(String? uid) async {
    try {
      String bucket = "usersDatabaseByBugDatabase135153";
      String targetUID = uid ?? MyProfileData.uid();

      if (targetUID.isEmpty) {
        debugPrint("⚠️ getProfilePosts: UID boş!");
        profilePosts.value = [];
        profilePosts.notifyListeners();
        return;
      }

      debugPrint("✅ getProfilePosts çağrıldı, UID: $targetUID");

      var posts = await ByBugDatabase.getAll("post");
      if (posts == null || posts.isEmpty) {
        debugPrint("⚠️ Hiç post yok");
        profilePosts.value = [];
        profilePosts.notifyListeners();
        return;
      }

      var user = await ByBugDatabase.get(bucket, targetUID);
      if (user == null || user["value"] == null) {
        debugPrint("⚠️ Kullanıcı bulunamadı: $targetUID");
        profilePosts.value = [];
        profilePosts.notifyListeners();
        return;
      }

      Map<String, dynamic> usrData = Map<String, dynamic>.from(user["value"] ?? {});
      if (usrData.isEmpty) {
        debugPrint("⚠️ Kullanıcı verileri boş");
        profilePosts.value = [];
        profilePosts.notifyListeners();
        return;
      }

      List<PostComponent> tempPosts = [];

      for (var element in posts) {
        try {
          if (element == null || element["value"] == null) continue;

          Map<String, dynamic> val = Map<String, dynamic>.from(element["value"] ?? {});
          if (val["uid"] != targetUID) continue;

          String postUid = val["uid"]?.toString() ?? "";
          String postTag = element["tag"]?.toString() ?? "";
          String postText = val["text"]?.toString() ?? "";
          String createAt = val["create_at"]?.toString() ?? DateTime.now().toIso8601String();

          if (postUid.isEmpty && postText.isEmpty) continue;

          tempPosts.add(
            PostComponent(
              uid: postUid,
              tag: postTag,
              dateTime: DateTime.tryParse(createAt) ?? DateTime.now(),
              name: usrData["name"]?.toString() ?? "Kullanıcı",
              verify: usrData["data"]?["verify"] ?? false,
              photo: usrData["photo"]?.toString() ?? "",
              text: postText,
              isAdmin: usrData["data"]?["isAdmin"] ?? false,
            ),
          );

        } catch (e) {
          debugPrint("⚠️ Post dönüştürme hatası: $e");
          continue;
        }
      }

      // Admin postlarını sırala
      List<PostComponent> adminPosts = tempPosts.where((p) => p.isAdmin).toList();
      List<PostComponent> normalPosts = tempPosts.where((p) => !p.isAdmin).toList();
      adminPosts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      normalPosts.shuffle();
      tempPosts = [...adminPosts, ...normalPosts];

      profilePosts.value = tempPosts;
      profilePosts.notifyListeners();

      debugPrint("✅ getProfilePosts: ${tempPosts.length} post yüklendi");

    } catch (e, stack) {
      debugPrint("❌ getProfilePosts ÇÖKTÜ: $e");
      debugPrint("📚 Stack: $stack");
      profilePosts.value = [];
      profilePosts.notifyListeners();
    }
  }

  static Future<void> getProfileYouPosts(String? uid) async {
    try {
      String bucket = "usersDatabaseByBugDatabase135153";
      String targetUID = uid ?? MyProfileData.uid();

      if (targetUID.isEmpty) {
        debugPrint("⚠️ getProfileYouPosts: UID boş!");
        profilePostsYou.value = [];
        profilePostsYou.notifyListeners();
        return;
      }

      var posts = await ByBugDatabase.getAll("post");
      if (posts == null || posts.isEmpty) {
        profilePostsYou.value = [];
        profilePostsYou.notifyListeners();
        return;
      }

      var user = await ByBugDatabase.get(bucket, targetUID);
      if (user == null || user["value"] == null) {
        debugPrint("⚠️ Kullanıcı bulunamadı: $targetUID");
        profilePostsYou.value = [];
        profilePostsYou.notifyListeners();
        return;
      }

      Map<String, dynamic> usrData = Map<String, dynamic>.from(user["value"] ?? {});
      if (usrData.isEmpty) {
        profilePostsYou.value = [];
        profilePostsYou.notifyListeners();
        return;
      }

      List<PostComponent> tempPosts = [];

      for (var element in posts) {
        try {
          if (element == null || element["value"] == null) continue;

          Map<String, dynamic> val = Map<String, dynamic>.from(element["value"] ?? {});
          if (val["uid"] != targetUID) continue;

          String postUid = val["uid"]?.toString() ?? "";
          String postTag = element["tag"]?.toString() ?? "";
          String postText = val["text"]?.toString() ?? "";
          String createAt = val["create_at"]?.toString() ?? DateTime.now().toIso8601String();

          if (postUid.isEmpty && postText.isEmpty) continue;

          tempPosts.add(
            PostComponent(
              verify: usrData["data"]?["verify"] ?? false,
              tag: postTag,
              uid: postUid,
              dateTime: DateTime.tryParse(createAt) ?? DateTime.now(),
              name: usrData["name"]?.toString() ?? "Kullanıcı",
              photo: usrData["photo"]?.toString() ?? "",
              text: postText,
              isAdmin: usrData["data"]?["isAdmin"] ?? false,
            ),
          );

        } catch (e) {
          debugPrint("⚠️ Post dönüştürme hatası: $e");
          continue;
        }
      }

      List<PostComponent> adminPosts = tempPosts.where((p) => p.isAdmin).toList();
      List<PostComponent> normalPosts = tempPosts.where((p) => !p.isAdmin).toList();
      adminPosts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      normalPosts.shuffle();
      tempPosts = [...adminPosts, ...normalPosts];

      profilePostsYou.value = tempPosts;
      profilePostsYou.notifyListeners();

      debugPrint("✅ getProfileYouPosts: ${tempPosts.length} post yüklendi");

    } catch (e, stack) {
      debugPrint("❌ getProfileYouPosts ÇÖKTÜ: $e");
      debugPrint("📚 Stack: $stack");
      profilePostsYou.value = [];
      profilePostsYou.notifyListeners();
    }
  }

  static Future<void> getPosts() async {
    try {
      String bucket = "usersDatabaseByBugDatabase135153";
      var posts = await ByBugDatabase.getAll("post");
      if (posts == null || posts.isEmpty) {
        postsW.value = [];
        postsW.notifyListeners();
        return;
      }

      var users = await ByBugDatabase.getAll(bucket);
      if (users == null || users.isEmpty) {
        postsW.value = [];
        postsW.notifyListeners();
        return;
      }

      List<PostComponent> tempPosts = [];

      for (var element in posts) {
        try {
          if (element == null || element["value"] == null) continue;

          Map<String, dynamic> val = Map<String, dynamic>.from(element["value"] ?? {});
          String postUid = val["uid"]?.toString() ?? "";
          if (postUid.isEmpty) continue;

          Map<String, dynamic>? usrData;
          for (var usr in users) {
            if (usr == null || usr["value"] == null) continue;
            Map<String, dynamic> usrVal = Map<String, dynamic>.from(usr["value"] ?? {});
            if (usrVal["uid"] == postUid) {
              usrData = usrVal;
              break;
            }
          }

          if (usrData == null) continue;

          String postTag = element["tag"]?.toString() ?? "";
          String postText = val["text"]?.toString() ?? "";
          String createAt = val["create_at"]?.toString() ?? DateTime.now().toIso8601String();

          if (postText.isEmpty) continue;

          tempPosts.add(
            PostComponent(
              verify: usrData["data"]?["verify"] ?? false,
              isAdmin: usrData["data"]?["isAdmin"] ?? false,
              tag: postTag,
              uid: postUid,
              dateTime: DateTime.tryParse(createAt) ?? DateTime.now(),
              name: usrData["name"]?.toString() ?? "Kullanıcı",
              photo: usrData["photo"]?.toString() ?? "",
              text: postText,
            ),
          );

        } catch (e) {
          debugPrint("⚠️ Post dönüştürme hatası: $e");
          continue;
        }
      }

      List<PostComponent> adminPosts = tempPosts.where((p) => p.isAdmin).toList();
      List<PostComponent> normalPosts = tempPosts.where((p) => !p.isAdmin).toList();
      adminPosts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      normalPosts.shuffle();
      tempPosts = [...adminPosts, ...normalPosts];

      postsW.value = tempPosts;
      postsW.notifyListeners();

      debugPrint("✅ getPosts: ${tempPosts.length} post yüklendi");

    } catch (e, stack) {
      debugPrint("❌ getPosts ÇÖKTÜ: $e");
      debugPrint("📚 Stack: $stack");
      postsW.value = [];
      postsW.notifyListeners();
    }
  }
}

extension PostReactions on Post {
  static Future<Map<String, dynamic>> getReactionData(String tag) async {
    try {
      var all = await ByBugDatabase.getAll("reaction");
      if (all == null || all.isEmpty) {
        return {"likes": 0, "dislikes": 0, "myReaction": null};
      }

      int likes = 0;
      int dislikes = 0;
      String? myReaction;
      String myUid = MyProfileData.uid();

      for (var element in all) {
        if (element == null || element["value"] == null) continue;
        Map<String, dynamic> val = Map<String, dynamic>.from(element["value"] ?? {});
        if (val["tag"] != tag) continue;
        if (val["type"] == "like") likes++;
        if (val["type"] == "dislike") dislikes++;
        if (val["uid"] == myUid) myReaction = val["type"];
      }

      return {"likes": likes, "dislikes": dislikes, "myReaction": myReaction};

    } catch (e) {
      debugPrint("❌ getReactionData hatası: $e");
      return {"likes": 0, "dislikes": 0, "myReaction": null};
    }
  }

  static Future<String?> toggleReaction(String tag, String type) async {
    try {
      String myUid = MyProfileData.uid();
      if (myUid.isEmpty) return null;
      if (tag.isEmpty || type.isEmpty) return null;

      String key = "${tag}_$myUid";
      String? currentType;

      try {
        var current = await ByBugDatabase.get("reaction", key);
        currentType = current["value"]?["type"];
      } catch (_) {
        currentType = null;
      }

      if (currentType == type) {
        await ByBugDatabase.remove("reaction", key);
        return null;
      } else {
        await ByBugDatabase.add("reaction", key, {
          "tag": tag,
          "uid": myUid,
          "type": type,
        });
        return type;
      }

    } catch (e) {
      debugPrint("❌ toggleReaction hatası: $e");
      return null;
    }
  }
}