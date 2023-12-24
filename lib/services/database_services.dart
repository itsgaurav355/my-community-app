import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final String? uid;
  DatabaseServices({this.uid});

  // reference for collection
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  //updating the userData
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profile": "",
      "uid": uid,
    });
  }

  //getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //getting user Groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  //creating new group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    //update the members in db
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  //getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot['admin'];
  }

  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //searching in db for community
  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  //check whether the user has joined the perticular community or not
  Future<bool> isUSerJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  //toggle function for joining and leaning the community
  Future toggleCommunityJoin(
      String groupId, String userName, String groupName) async {
    //doc references
    DocumentReference userReference = userCollection.doc(uid);
    DocumentReference groupReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups then remove and if not then give join option
    if (groups.contains("${groupId}_$groupName")) {
      await userReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$groupName"])
      });
    } else {
      await userReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$groupName"])
      });
    }
  }

  sendMessage(String groupId, Map<String, dynamic> chatMessage) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessage);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessage['message'],
      "recentMessageSender": chatMessage['sender'],
      "recentMessageTime": chatMessage['time'].toString(),
    });
  }
}
