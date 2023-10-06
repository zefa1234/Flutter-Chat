import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chat_app/instances/UserStateInstance.dart';
import 'package:provider/provider.dart';

final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;

class AddGroupMembers extends StatefulWidget {
  AddGroupMembers();

  @override
  _AddGroupMembersState createState() => _AddGroupMembersState();
}

class _AddGroupMembersState extends State<AddGroupMembers> {
  List<Widget> memberList = [];
  var selectedMembers, memberUids = [];

  @override
  void initState() {
    super.initState();
  }

  addMember() async {
    DocumentReference companyRef = _firestore
        .collection('公司')
        .doc(context.read<UserState>().currentCompanyID);

    for (int i = 0; i < memberUids.length; i++) {
      if (selectedMembers[i] == false) continue;
      DocumentReference memberRef =
          _firestore.doc('/公司/' + companyRef.id + '/成員/' + memberUids[i]);

      DocumentReference groupRef = _firestore.doc('/公司/' +
          companyRef.id +
          '/群組/' +
          context.read<UserState>().currentGroupID);

      await _firestore
          .collection('公司')
          .doc(companyRef.id)
          .collection('群組')
          .doc(context.read<UserState>().currentGroupID)
          .update({
        '成員': FieldValue.arrayUnion([memberRef])
      });

      _firestore
          .collection('公司')
          .doc(companyRef.id)
          .collection('成員')
          .doc(memberRef.id)
          .update({
        '群組': FieldValue.arrayUnion([groupRef])
      });

      _firestore
          .collection('公司')
          .doc(companyRef.id)
          .collection('成員')
          .doc(memberRef.id)
          .collection('群組')
          .add({"群組": groupRef});
    }
  }

  @override
  Widget build(BuildContext context) {
    memberList = [];
    selectedMembers = [];
    memberUids = [];
    return AlertDialog(
        title: Row(children: [Text("添加成員")]),
        content: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: StreamBuilder(
              stream: context.watch<UserState>().streamMember,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<UserInfo> messages = snapshot.data;
                  for (int i = 0; i < messages.length; i++) {
                    selectedMembers.add(false);
                    memberUids.add(messages[i].uid);
                    memberList.add(
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return Center(
                                  child: Checkbox(
                                    value: selectedMembers[i],
                                    onChanged: (bool value) {
                                      setState(() {
                                        selectedMembers[i] = value;
                                      });
                                    },
                                  ),
                                );
                              })),
                          Expanded(
                              flex: 1,
                              child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      NetworkImage(messages[i].photoUrl))),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(messages[i].name,
                                style: TextStyle(
                                    fontFamily: 'Poppins', fontSize: 20)),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(children: [
                    Expanded(flex: 10, child: ListView(children: memberList)),
                    Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.blueGrey)),
                                textColor: Colors.white,
                                color: Colors.grey,
                                child: Text('取消'),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            SizedBox(width: 10),
                            RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.blue)),
                                textColor: Colors.white,
                                color: Colors.lightBlue,
                                child: Text('加入'),
                                onPressed: () async {
                                  await addMember();
                                  Navigator.pop(context);
                                })
                          ],
                        ))
                  ]);
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.deepPurple),
                  );
                }
              },
            )));
  }
}
