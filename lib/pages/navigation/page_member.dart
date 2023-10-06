import 'package:chat_app/instances/UserStateInstance.dart';
import 'package:chat_app/widgets/UserInfoDialog.dart';
import 'package:chat_app/widgets/dynamicLink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final _firestore = FirebaseFirestore.instance;
Stream<List<UserInfo>> UserInfoStream;
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MemberPage extends StatefulWidget {
  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  @override
  void initState() {
    UserInfoStream = _firestore
        .collection("公司")
        .doc(context.read<UserState>().currentCompanyID)
        .collection('成員')
        .snapshots()
        .asyncMap((members) => Future.wait(members.docs.map((member) async {
              DocumentReference memberRef = member.data()['使用者'];
              Map cMember;
              var value = await memberRef.get();
              cMember = value.data();
              return UserInfo(
                uid: cMember['uid'],
                name: cMember['名稱'],
                email: cMember['信箱'],
                photoUrl: cMember['照片'],
                phoneNumber: cMember['電話'],
              );
            })));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height / 1.5,
            child: StreamBuilder<List<UserInfo>>(
              // stream: _firestore
              //     .collection("公司")
              //     .doc(context.read<UserState>().currentCompanyID)
              //     .collection('成員')
              //     .snapshots()
              //     .asyncMap(
              //         (members) => Future.wait(members.docs.map((member) async {
              //               DocumentReference memberRef = member.data()['使用者'];
              //               Map cMember;
              //               var value = await memberRef.get();
              //               cMember = value.data();
              //               return UserInfo(
              //                 uid: cMember['uid'],
              //                 name: cMember['名稱'],
              //                 email: cMember['信箱'],
              //                 photoUrl: cMember['照片'],
              //                 phoneNumber: cMember['電話'],
              //               );
              //             }))),
              stream: context.watch<UserState>().streamMember,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final members = snapshot.data;
                  List<UserInfo> memberWidgets = [];
                  for (var member in members) {
                    UserInfo memberWidget = UserInfo(
                        uid: member.uid,
                        name: member.name,
                        email: member.email,
                        photoUrl: member.photoUrl,
                        phoneNumber: member.phoneNumber,
                        status: member.status);
                    memberWidgets.add(memberWidget);
                  }
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: memberWidgets.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('${memberWidgets[index].name}'),
                        leading: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 40.0,
                              height: 40.0,
                              child: CircleAvatar(
                                  radius: 100,
                                  backgroundImage: NetworkImage(
                                      memberWidgets[index].photoUrl)),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              width: 40.0,
                              height: 40.0,
                              child: CircleAvatar(
                                radius: 5,
                                // backgroundColor: Colors.lightGreenAccent[700],
                                backgroundColor:
                                    memberWidgets[index].status == "Online"
                                        ? Colors.lightGreenAccent[700]
                                        : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                        //subtitle: Text("test"),
                        onTap: () {
                          UserInfoDialog(
                                  memberWidgets[index].name,
                                  memberWidgets[index].email,
                                  memberWidgets[index].phoneNumber,
                                  memberWidgets[index].photoUrl)
                              .showUserInfoDialog(context);
                        },
                      );
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.deepPurple),
                  );
                }
              },
            )),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          addMemberButton(
              type: "公司",
              name: context.read<UserState>().currentCompanyName,
              id: context.read<UserState>().currentCompanyID),
        ]),
      ],
    );
  }
}
