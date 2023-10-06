import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../instances/UserStateInstance.dart';
import 'customtextinput.dart';

final _firestore = FirebaseFirestore.instance;

class AddGroupButton extends StatelessWidget {
  String inputGroupName = "";

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        child: Icon(Icons.group_add, size: 30),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Input Group name"),
              content: CustomTextInput(
                hintText: 'Group name',
                leading: Icons.text_format,
                keyboard: TextInputType.name,
                obscure: false,
                userTyped: (value) {
                  inputGroupName = value;
                },
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      DocumentReference userRef = _firestore
                          .collection('使用者')
                          .doc(context.read<UserState>().currentUserId);
                      DocumentReference companyRef = _firestore
                          .collection('公司')
                          .doc(context.read<UserState>().currentCompanyID);

                      DocumentReference memberRef = _firestore.doc('/公司/' +
                          companyRef.id +
                          '/成員/' +
                          context.read<UserState>().currentUserId);

                      final fcmToken =
                          await FirebaseMessaging.instance.getToken();

                      DocumentReference groupRef = await _firestore
                          .collection('公司')
                          .doc(companyRef.id)
                          .collection('群組')
                          .add({
                        '類別': '群組',
                        '名稱': inputGroupName,
                        '成員': [
                          memberRef,
                        ],
                        'memberTokens': [
                          fcmToken,
                        ],
                        'topMessage': "",
                      });

                      _firestore
                          .collection('公司')
                          .doc(companyRef.id)
                          .collection('群組')
                          .doc(groupRef.id)
                          .collection('聊天紀錄')
                          .add({});
                      _firestore
                          .collection('公司')
                          .doc(companyRef.id)
                          .collection('成員')
                          .doc(memberRef.id)
                          .set({
                        '使用者': userRef,
                        '群組': [groupRef],
                      });

                      _firestore
                          .collection('公司')
                          .doc(companyRef.id)
                          .collection('成員')
                          .doc(memberRef.id)
                          .collection('群組')
                          .add({"群組": groupRef});

                      inputGroupName = "";
                      Navigator.pop(context);
                    },
                    child: Text("OK"))
              ],
            ),
          );
        });
  }
}
