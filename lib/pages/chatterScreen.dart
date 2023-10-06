import 'dart:convert';
import 'dart:io';
import 'package:chat_app/widgets/addGroupMembers.dart';
import 'package:chat_app/widgets/editProfile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import 'package:chat_app/instances/UserStateInstance.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chat_app/widgets/UserInfoDialog.dart';
import 'package:focused_menu/modals.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/widgets/task.dart';

final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;

String messageText;
Map<String, UserInfo> userInfoMap = {};

class ChatterScreen extends StatefulWidget {
  @override
  _ChatterScreenState createState() => _ChatterScreenState();
}

class _ChatterScreenState extends State<ChatterScreen> {
  final chatMsgTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (context.read<UserState>().currentCompanyID == "") {
      return Center(child: Text("尚無公司"));
    }
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
              onPressed: () {
                //context.read<UserState>().updateViewTrans(0);
                context.read<UserState>().updateViewPage(0);
              },
              icon: Icon(Icons.arrow_back)),
          iconTheme: IconThemeData(color: Colors.deepPurple),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size(25, 10),
            child: Container(
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.blue[100],
              ),
              decoration: BoxDecoration(
                  // color: Colors.blue,

                  // borderRadius: BorderRadius.circular(20)
                  ),
              constraints: BoxConstraints.expand(height: 1),
            ),
          ),
          backgroundColor: Colors.white10,
          title: Row(
            children: <Widget>[
              Text(
                context.watch<UserState>().currentGroupName,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.deepPurple),
              ),
              Spacer(),
              GestureDetector(
                child: Icon(Icons.task_outlined),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => new myTask(),
                  );
                },
              ),
              SizedBox(width: 30),
              GestureDetector(
                child: Icon(Icons.group_add),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => new AddGroupMembers(),
                  );
                },
              )
            ],
          ),
          actions: <Widget>[
            GestureDetector(
              child: Icon(Icons.more_vert),
            )
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ChatStream(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 1),
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                      shape: CircleBorder(),
                      color: Colors.blue,
                      onPressed: () {
                        getImage();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.photo,
                          color: Colors.white,
                        ),
                      )),
                  Expanded(
                    child: Material(
                      borderRadius: BorderRadius.circular(50),
                      color: context.read<UserState>().deepColor
                          ? Colors.grey
                          : Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 1.0, top: 2, bottom: 2),
                        child: TextField(
                          onChanged: (value) {
                            messageText = value;
                          },
                          autofocus: false,
                          controller: chatMsgTextController,
                          decoration: kMessageTextFieldDecoration,
                        ),
                      ),
                    ),
                  ),
                  MaterialButton(
                      shape: CircleBorder(),
                      color: Colors.blue,
                      onPressed: () {
                        chatMsgTextController.clear();
                        storeMessage('message');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ));
  }

  void sendPushMessage(String token, String sender, String content) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAA9kXnRdE:APA91bF2pGcvspirhEQztcwkDmQL_eOYZpiKA7TF5yJzjEAM09vONsPrnQGOwREMGFWmsJ5Bjo5zYbY4p_6TSjlC8ru6W48A9pcdf_oHJ7xh8YWl3qptlzDguGX1WhZg-33Uy7XH5vn4',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': '${content}',
              'title':
                  '${context.read<UserState>().currentCompanyName} - ${sender}'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }

  Future<String> storeMessage(type) async {
    var myMessage, myImage;
    var fcmContent;
    if (type == 'message') {
      myMessage = messageText;
      fcmContent = messageText;
      myImage = '';
    } else if (type == 'image') {
      myMessage = '';
      fcmContent = "傳送了圖片";
      myImage =
          'https://upload.wikimedia.org/wikipedia/commons/b/b1/Loading_icon.gif';
    }
    DocumentReference userRef = _firestore
        .collection('使用者')
        .doc(context.read<UserState>().currentUserId);
    DocumentReference messageLog = await _firestore
        .collection('公司')
        .doc(context.read<UserState>().currentCompanyID)
        .collection('群組')
        .doc(context.read<UserState>().currentGroupID)
        .collection('聊天紀錄')
        .add({
      'sender': context.read<UserState>().currentUserName,
      'text': myMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'senderemail': context.read<UserState>().currentUserEmail,
      'userId': context.read<UserState>().currentUserId,
      'userRef': userRef,
      'star': false,
      'takeback': false,
      'reads': [],
      'color': '',
      'image': myImage,
    });

    var tempGroupInfo = await getUserInfo().getCompanyGroupData(
        context.read<UserState>().currentCompanyID,
        context.read<UserState>().currentGroupID);
    final fcmToken = await FirebaseMessaging.instance.getToken();

    List tempTokens = tempGroupInfo['memberTokens'];
    tempTokens.remove(fcmToken);

    for (var token in tempTokens) {
      sendPushMessage(
          token, context.read<UserState>().currentUserName, fcmContent);
      print(token);
    }

    _firestore
        .collection('公司')
        .doc(context.read<UserState>().currentCompanyID)
        .collection('群組')
        .doc(context.read<UserState>().currentGroupID)
        .update({'topMessage': fcmContent});

    return messageLog.id;
  }

  Future<void> getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, maxHeight: 200, maxWidth: 200);

    if (pickedFile != null) {
      // 先存一筆空白紀錄且回傳ID
      final messageLogId = await storeMessage('image');

      // 以ID為檔名存入firestore
      await _storage
          .ref('chatterScreenImg/' + messageLogId + '.png')
          .putFile(File(pickedFile.path));

      // 取得檔案URL
      final imgURL = await _storage
          .ref('chatterScreenImg/' + messageLogId + '.png')
          .getDownloadURL();

      // 更新紀錄
      await _firestore
          .collection('公司')
          .doc(context.read<UserState>().currentCompanyID)
          .collection('群組')
          .doc(context.read<UserState>().currentGroupID)
          .collection('聊天紀錄')
          .doc(messageLogId)
          .update({'image': imgURL});
    }
  }
}

class ChatStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (context.read<UserState>().currentGroupID == null ||
        context.read<UserState>().currentGroupID == "") {
      return Container();
    }
    return StreamBuilder(
      stream: context.watch<UserState>().streamChatter,
      //_firestore.collection('公司').doc(context.read<UserState>().currentCompanyID).collection('群組').doc()
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<MessageBubble> messageWidgets = [];
          if (!snapshot.data.isEmpty) {
            List<MessageBubble> messages = snapshot.data;
            messageWidgets = messages.reversed.toList();
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              children: messageWidgets,
            ),
          );
        } else {
          return Center(
            child:
                CircularProgressIndicator(backgroundColor: Colors.deepPurple),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String msgId;
  final String msgText;
  final String msgSender;
  final bool user;
  final String msgUserId;
  final String msgUserImg;

  final bool star;
  final bool takeback;
  final int reads;
  final String color;
  final int timestamp;
  final String image;
  MessageBubble(
      {this.msgId,
      this.msgText,
      this.msgSender,
      this.user,
      this.msgUserId,
      this.msgUserImg,
      this.star,
      this.takeback,
      this.reads,
      this.color,
      this.timestamp,
      this.image});

  @override
  Widget build(BuildContext context) {
    if (user)
      return Padding(
        // 本人訊息
        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
        child: Row(
            mainAxisAlignment:
                user ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              OtherInfo(star: star, reads: reads, timestamp: timestamp),
              SenderAndMessage(
                msgSender: msgSender,
                msgText: msgText,
                alignRight: user,
                msgUserId: msgUserId,
                msgId: msgId,
                star: star,
                takeback: takeback,
                image: image,
              ),
              UserCircle(msgUserId: msgUserId),
            ]),
      );
    else
      return Padding(
        // 他人訊息
        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
        child: Row(
            mainAxisAlignment:
                user ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              UserCircle(msgUserId: msgUserId),
              SenderAndMessage(
                msgSender: msgSender,
                msgText: msgText,
                alignRight: user,
                msgUserId: msgUserId,
                msgId: msgId,
                star: star,
                takeback: takeback,
                image: image,
              ),
              OtherInfo(star: star, reads: reads, timestamp: timestamp),
            ]),
      );
  }
}

class OtherInfo extends StatelessWidget {
  final bool star;
  final int reads;
  final int timestamp;

  OtherInfo({this.star, this.reads, this.timestamp});

  @override
  Widget build(BuildContext context) {
    // 將時區 +8
    DateTime convertTimeZone =
        DateTime.fromMillisecondsSinceEpoch(timestamp).add(Duration(hours: 8));

    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Column(
        children: <Widget>[
          star
              ? Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 30,
                )
              : Container(height: 30),
          Text(
            '已讀$reads',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            convertTimeZone.toString().substring(10, 16),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class SenderAndMessage extends StatelessWidget {
  final String msgSender;
  String msgText;
  final bool alignRight;
  final String msgUserId;
  final String msgId;
  final bool star;
  final bool takeback;
  final String image;
  SenderAndMessage(
      {this.msgSender,
      this.msgText,
      this.alignRight,
      this.msgUserId,
      this.msgId,
      this.star,
      this.takeback,
      this.image});

  @override
  Widget build(BuildContext context) {
    /* 顯示內容*/
    Widget msgContext;
    if (takeback) {
      msgContext = Text(
        '訊息已收回',
        style: TextStyle(
          //訊息氣泡文字顏色
          fontFamily: 'Poppins',
          fontSize: 15,
          fontStyle: FontStyle.italic,
        ),
      );
    } else if (image != '') {
      msgContext = Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.width * 0.2,
        child: Image.network(
          image,
          fit: BoxFit.cover,
        ),
      );
    } else {
      msgContext = Text(
        msgText,
        style: TextStyle(
            //訊息氣泡文字顏色
            fontFamily: 'Poppins',
            fontSize: 15),
      );
    }

    /* 點擊選單 */
    List<FocusedMenuItem> FocusedMenu = [
      FocusedMenuItem(
          title: star
              ? Text("取消最愛", style: TextStyle(color: Colors.black))
              : Text("最愛", style: TextStyle(color: Colors.black)),
          trailingIcon: Icon(Icons.star_border, color: Colors.black),
          onPressed: () {
            // Handle Menu Item Click
            _firestore
                .collection('公司')
                .doc(context.read<UserState>().currentCompanyID)
                .collection('群組')
                .doc(context.read<UserState>().currentGroupID)
                .collection('聊天紀錄')
                .doc(msgId)
                .update({'star': !this.star});
          })
    ];
    if (alignRight) {
      FocusedMenu.add(FocusedMenuItem(
          title: takeback
              ? Text("還原訊息", style: TextStyle(color: Colors.black))
              : Text("收回訊息", style: TextStyle(color: Colors.black)),
          trailingIcon: Icon(Icons.reply, color: Colors.black),
          onPressed: () {
            _firestore
                .collection('公司')
                .doc(context.read<UserState>().currentCompanyID)
                .collection('群組')
                .doc(context.read<UserState>().currentGroupID)
                .collection('聊天紀錄')
                .doc(msgId)
                .update({'takeback': !takeback});
          }));
      FocusedMenu.add(FocusedMenuItem(
          title: Text(
            "刪除",
            style: TextStyle(color: Colors.redAccent),
          ),
          trailingIcon: Icon(
            Icons.delete,
            color: Colors.redAccent,
          ),
          onPressed: () {
            _firestore
                .collection('公司')
                .doc(context.read<UserState>().currentCompanyID)
                .collection('群組')
                .doc(context.read<UserState>().currentGroupID)
                .collection('聊天紀錄')
                .doc(msgId)
                .delete();
          }));
    }

    BorderRadius borderRadius;
    if (image != '') {
      borderRadius = BorderRadius.all(Radius.circular(10));
    } else {
      borderRadius = BorderRadius.only(
        bottomLeft: Radius.circular(50),
        topLeft: alignRight ? Radius.circular(50) : Radius.circular(0),
        bottomRight: Radius.circular(50),
        topRight: alignRight ? Radius.circular(0) : Radius.circular(50),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            msgSender,
            style: TextStyle(fontSize: 13, fontFamily: 'Poppins'),
          ),
        ),
        FocusedMenuHolder(
          onPressed: () {},
          child: Material(
            borderRadius: borderRadius,
            //訊息氣泡背景顏色
            color: context.read<UserState>().deepColor
                ? Colors.grey
                : Colors.white,
            elevation: 5,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: msgContext),
          ),
          menuWidth: MediaQuery.of(context).size.width * 0.50,
          blurSize: 0,
          menuItemExtent: 45,
          menuBoxDecoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          duration: Duration(milliseconds: 100),
          animateMenuItems: true,
          blurBackgroundColor: Colors.black54,
          openWithTap: true, // Open Focused-Menu on Tap rather than Long Press
          menuOffset:
              10.0, // Offset value to show menuItem from the selected item
          bottomOffsetHeight:
              80.0, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
          menuItems: FocusedMenu,
        )
      ],
    );
  }
}

class UserCircle extends StatelessWidget {
  final String msgUserId;
  UserCircle({this.msgUserId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CircleAvatar(
        backgroundImage: NetworkImage(userInfoMap[msgUserId].photoUrl),
        radius: 20,
      ),
      onTap: () {
        UserInfoDialog(
                userInfoMap[msgUserId].name,
                userInfoMap[msgUserId].email,
                userInfoMap[msgUserId].phoneNumber,
                userInfoMap[msgUserId].photoUrl)
            .showUserInfoDialog(context);
      },
    );
  }
}
