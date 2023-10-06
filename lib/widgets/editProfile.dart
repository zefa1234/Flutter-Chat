import 'package:chat_app/instances/UserStateInstance.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

final _firestore = FirebaseFirestore.instance;

class editProfileButton extends StatefulWidget {
  final String type;
  final String initValue;
  editProfileButton({this.type, this.initValue});

  @override
  _editProfileButton createState() => _editProfileButton();
}

class _editProfileButton extends State<editProfileButton> {
  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    var _auth = FirebaseAuth.instance;
    var user = _auth.currentUser;

    var editController = TextEditingController(text: widget.initValue);
    final _formKey = GlobalKey<FormState>();

    return MaterialButton(
      child: Icon(Icons.edit, size: 30),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Positioned(
                      right: -40.0,
                      top: -40.0,
                      child: InkResponse(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          child: Icon(Icons.close),
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(widget.type,
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 30))),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: editController,
                              style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 30),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              child: Text("修改"),
                              onPressed: () async {
                                if (editController.text.trim() == '') {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text('請輸入' + widget.type),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('確定'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                } else {
                                  updateUserInfo(user.uid, widget.type,
                                      editController.text);
                                  userState.updateUserWigetInfo();
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }
}

class getUserInfo {
  Future<Map> getUserAllData(uid) async {
    return (await _firestore.collection('使用者').doc(uid).get()).data();
  }

  Future<String> getUserInfoFutureData(uid, infoType) async {
    return (await _firestore.collection('使用者').doc(uid).get()).data()[infoType];
  }

  Future<Map> getCompanyData(uid) async {
    return (await _firestore.collection('公司').doc(uid).get()).data();
  }

  Future<Map> getCompanyGroupData(companyUid, groupUid) async {
    return (await _firestore
            .collection('公司')
            .doc(companyUid)
            .collection('群組')
            .doc(groupUid)
            .get())
        .data();
  }
}

class updateUserInfo {
  updateUserInfo(uid, infoType, info) {
    _firestore.collection('使用者').doc(uid).update({infoType: info});
  }
}
