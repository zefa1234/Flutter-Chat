// ignore_for_file: unused_local_variable

import 'package:chat_app/instances/UserStateInstance.dart';
import 'package:chat_app/widgets/Company.dart';
import 'package:chat_app/widgets/editProfile.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DynamicLinkService {
  void fetchLinkData(navigatorKey) async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      handleDynamicLink(navigatorKey, dynamicLink);
    });
  }

  handleDynamicLink(navigatorKey, dynamicLink) async {
    print("detect dynamic link!: ${dynamicLink.link}");
    print(dynamicLink.link.queryParameters['id']);

    BuildContext currentContext = navigatorKey.currentContext;
    showDialog(
        context: currentContext,
        builder: (ctx) {
          return SizedBox(
              width: 200.0,
              height: 300.0,
              child: AlertDialog(
                title: Text("受邀加入${dynamicLink.link.queryParameters['type']}"),
                content: Container(
                  child:
                      Text("名稱: ${dynamicLink.link.queryParameters['name']}"),
                ),
                actions: [
                  FlatButton(
                    child: Text("取消"),
                    onPressed: () {
                      print("取消");
                      Navigator.of(ctx).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("加入"),
                    onPressed: () async {
                      await addUserToCompany(
                          dynamicLink.link.queryParameters['id'],
                          currentContext);
                      currentContext.read<UserState>().updateUserWigetInfo();
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ));
        });
  }

  addUserToCompany(String id, BuildContext currentContext) async {
    final _firestore = FirebaseFirestore.instance;
    final _user = FirebaseAuth.instance.currentUser;

    DocumentReference userRef = _firestore.doc('/使用者/' + _user.uid);
    var existMember = await _firestore
        .collection('公司')
        .doc(id)
        .collection('成員')
        .where('使用者', isEqualTo: userRef)
        .get();

    if (existMember.size == 0) {
      DocumentReference groupRef;
      await _firestore
          .collection('公司')
          .doc(id)
          .collection('群組')
          // .where('名稱', isEqualTo: '大廳')
          .doc(id)
          .get()
          .then((value) {
        if (value.exists) groupRef = value.reference;
      });

      _firestore.collection('公司').doc(id).collection('成員').doc(userRef.id).set({
        '使用者': userRef,
        '群組': [groupRef],
      });

      final fcmToken = await FirebaseMessaging.instance.getToken();
      var newGroupAllData = await getUserInfo().getCompanyGroupData(id, id);
      List tempTokens = newGroupAllData['memberTokens'];
      tempTokens.add(fcmToken);
      await groupRef.update({'memberTokens': tempTokens});

      await _firestore
          .collection('公司')
          .doc(id)
          .collection('成員')
          .doc(userRef.id)
          .collection('群組')
          .add({'群組': groupRef});

      DocumentReference companyRef = _firestore.collection('公司').doc(id);
      var newUserAllData = await getUserInfo().getUserAllData(_user.uid);

      List tempCompanyList = newUserAllData['公司'];

      tempCompanyList.add(companyRef);
      await _firestore
          .collection('使用者')
          .doc(userRef.id)
          .update({'公司': tempCompanyList});

      DocumentReference usercompanyRef = await _firestore
          .collection('使用者')
          .doc(userRef.id)
          .collection('公司群')
          .add({"公司Ref": companyRef});

      Fluttertoast.showToast(
        msg: "加入成功!", // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.TOP, // locat
      );
    } else {
      // 導航到群組頁面
      Fluttertoast.showToast(
        msg: "已經加入過!", // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.TOP, // locat
      );
    }
  }

  Future<String> createDynamicLink(type, name, id) async {
    print("id: " + id);
    final String DynamicLink =
        'https://pseuderandroidtest.page.link/?type=$type&name=$name&id=$id';

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://pseuderandroidtest.page.link',
      link: Uri.parse(DynamicLink),
      androidParameters: AndroidParameters(
        packageName: 'com.example.chat_app',
        minimumVersion: 0,
      ),
    );

    Uri url;
    url = await parameters.buildUrl();

    print("Dynamic link: $url");
    return url.toString();
  }
}

class addMemberButton extends StatefulWidget {
  final String type;
  final String name;
  final String id;
  addMemberButton({this.type, this.name, this.id});

  @override
  _addMemberButton createState() => _addMemberButton();
}

class _addMemberButton extends State<addMemberButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        child: Icon(Icons.person_add_alt_1, size: 30),
        onPressed: () async {
          final dl = await DynamicLinkService()
              .createDynamicLink(widget.type, widget.name, widget.id);
          showDialog(
              context: context,
              builder: (ctx) {
                return SizedBox(
                    child: AlertDialog(
                  title: Text("邀請加入${widget.type}"),
                  content: Container(
                      height: 150,
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text("複製連結"),
                            ),
                            Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(Icons.link),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: dl));
                                    Fluttertoast.showToast(
                                      msg: "已複製到剪貼簿", // message
                                      toastLength: Toast.LENGTH_SHORT, // length
                                      gravity: ToastGravity.TOP, // locat
                                    );
                                  },
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text("QRcode"),
                            ),
                            Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: QrImage(
                                    data: dl,
                                    version: QrVersions.auto,
                                    size: 100,
                                  ),
                                ))
                          ],
                        ),
                      ])),
                ));
              });
        });
  }
}
