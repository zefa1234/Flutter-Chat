import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:chat_app/widgets/editProfile.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/instances/UserStateInstance.dart';

final _auth = FirebaseAuth.instance;
final _storage = FirebaseStorage.instance;
File userImageFile;

var qwe;

class ChatterProfile extends StatefulWidget {
  @override
  _ChatterProfileState createState() => _ChatterProfileState();
}

class _ChatterProfileState extends State<ChatterProfile> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, maxHeight: 200, maxWidth: 200);
    if (pickedFile != null) {
      await _storage
          .ref('userImg/' + context.read<UserState>().currentUserId + '.png')
          .putFile(File(pickedFile.path));

      await _storage
          .ref('userImg/' + context.read<UserState>().currentUserId + '.png')
          .getDownloadURL()
          .then((value) {
        updateUserInfo(context.read<UserState>().currentUserId, "照片", value);
      });

      setState(() {
        userImageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.deepPurple),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size(25, 10),
          child: Container(
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.blue[100],
            ),
            constraints: BoxConstraints.expand(height: 1),
          ),
        ),
        backgroundColor: Colors.white10,
        title: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '個人資料',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.deepPurple),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          Container(
              margin: EdgeInsets.only(right: 10),
              child: GestureDetector(
                child: Icon(Icons.logout),
                onTap: () {
                  _auth.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ))
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                flex: 7,
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                      // 使用者照片
                      GestureDetector(
                        onTap: () {
                          getImage().then((value) =>
                              context.read<UserState>().updateUserWigetInfo());
                        },
                        child: Container(
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: userImageFile == null
                                ? (NetworkImage(context
                                    .read<UserState>()
                                    .currentUserPhotoUrl))
                                : FileImage(userImageFile),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(left: 20.0),
                              child: Text(
                                "姓名",
                                style: TextStyle(
                                    fontFamily: 'Poppins', fontSize: 30),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left: 12.0),
                                child: Text(
                                    context.read<UserState>().currentUserName,
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 20),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              )),
                          Expanded(
                              flex: 1,
                              child: editProfileButton(
                                  type: "名稱",
                                  initValue: context
                                      .watch<UserState>()
                                      .currentUserName))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left: 20.0),
                                child: Text(
                                  "信箱",
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 30),
                                ),
                              )),
                          Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left: 12.0),
                                child: Text(
                                    context.read<UserState>().currentUserEmail,
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 20),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              )),
                          Expanded(
                              flex: 1,
                              child: editProfileButton(
                                  type: "信箱",
                                  initValue: context
                                      .read<UserState>()
                                      .currentUserEmail))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left: 20.0),
                                child: Text(
                                  "電話",
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 30),
                                ),
                              )),
                          Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left: 12.0),
                                child: Text(
                                    context
                                        .read<UserState>()
                                        .currentUserPhoneNumber,
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 20),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              )),
                          Expanded(
                              flex: 1,
                              child: editProfileButton(
                                  type: "電話",
                                  initValue: context
                                      .read<UserState>()
                                      .currentUserPhoneNumber))
                        ],
                      ),
                    ]))),
          ],
        ),
      ),
    );
  }
}
