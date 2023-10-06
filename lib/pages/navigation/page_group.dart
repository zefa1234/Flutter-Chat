import 'package:chat_app/instances/UserStateInstance.dart';
import 'package:chat_app/widgets/AddGroup.dart';
import 'package:chat_app/widgets/UserInfoDialog.dart';
import 'package:chat_app/widgets/dynamicLink.dart';
import 'package:chat_app/widgets/editProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final _firestore = FirebaseFirestore.instance;
final _user = FirebaseAuth.instance.currentUser;

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  DocumentReference userRef = _firestore.doc('/使用者/' + _user.uid);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return StreamBuilder(
    //   stream: _firestore
    //       .collection('公司')
    //       .doc(context.read<UserState>().currentCompanyID)
    //       .collection('成員')
    //       .doc(context.read<UserState>().currentUserId)
    //       .collection('群組')
    //       .snapshots()
    //       .asyncMap((groups) => Future.wait(groups.docs.map((group) async {
    //             if (group.exists) {
    //               DocumentReference groupRef = group.data()['群組'];
    //               Map cgroup;

    //               //var newUserAllData =
    //               await getUserInfo().getUserAllData(user.uid);
    //               var value = await groupRef.get();
    //               //var companyreflist = newUserAllData['公司'];
    //               //context.read<UserState>().updateCompanyMap(companyreflist);
    //               cgroup = value.data();
    //               Map temp = {"id": groupRef.id, "名稱": cgroup['名稱']};

    //               return temp;
    //             } else {
    //               return null;
    //             }
    //           }))),
    //   builder: (context, snapshot) {
    //     var groups = snapshot.data;
    //     if (groups != null) {
    //       List<ListTile> CompanyButtonList = [];
    //       //context.read<UserState>().updateCompanyMap(groups);
    //       for (var group in groups) {
    //         print(group['名稱']);

    //         ListTile tempButton = ListTile(
    //           title: Text(group['名稱']),
    //           onTap: () {
    //             // context
    //             //     .read<UserState>()
    //             //     .setCompany(group['id'], group['名稱']);
    //             // Navigator.pop(context);
    //           },
    //         );

    //         CompanyButtonList.add(tempButton);
    //       }

    //       return ListView.separated(
    //           itemBuilder: (context, index) {
    //             return CompanyButtonList[index];
    //           },
    //           padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    //           separatorBuilder: (BuildContext context, int index) => Divider(
    //                 height: 8.0,
    //                 color: Color(0xFFFFFFFF),
    //               ),
    //           itemCount: CompanyButtonList.length);
    //     } else {
    //       return Center(
    //         child:
    //             CircularProgressIndicator(backgroundColor: Colors.deepPurple),
    //       );
    //     }
    //   },
    // );

    return Column(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height / 1.5,
            child: StreamBuilder(
              stream: context.watch<UserState>().streamGroup,
              builder: (context, snapshot) {
                // var groups = snapshot.data;

                // if (groups != null) {
                //   List<ListTile> CompanyButtonList = [];
                //   //context.read<UserState>().updateCompanyMap(groups);
                //   for (var group in groups) {
                //     print(group['名稱']);

                //     //getGroupData(group['id']);

                //     ListTile tempButton = ListTile(
                //       title: Text(group['名稱']),
                //       subtitle: Text(group['topMessage']),
                //       // trailing: Text(group['chatCount'].toString()),
                //       trailing: group['chatCount'] != 0
                //           ? Stack(
                //               alignment: Alignment.center,
                //               children: <Widget>[
                //                 Container(
                //                   alignment: Alignment.center,
                //                   width: 40.0,
                //                   height: 40.0,
                //                   child: CircleAvatar(
                //                       radius: 15,
                //                       backgroundColor:
                //                           Color.fromARGB(255, 40, 207, 49)),
                //                 ),
                //                 Container(
                //                   alignment: Alignment.center,
                //                   width: 40.0,
                //                   height: 40.0,
                //                   child: Text(
                //                     group['chatCount'].toString(),
                //                     style: TextStyle(color: Colors.white),
                //                   ),
                //                 ),
                //               ],
                //             )
                //           : null,
                //       onTap: () {
                //         context
                //             .read<UserState>()
                //             .setCurrentGroup(group['id'], group['名稱']);
                //         context.read<UserState>().updateViewPage(1);
                //         // Navigator.pop(context);
                //       },
                //     );

                //     CompanyButtonList.add(tempButton);
                //   }

                //   return ListView.separated(
                //       itemBuilder: (context, index) {
                //         return CompanyButtonList[index];
                //       },
                //       padding:
                //           EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                //       separatorBuilder: (BuildContext context, int index) =>
                //           Divider(
                //             height: 8.0,
                //             color: Color(0xFFFFFFFF),
                //           ),
                //       itemCount: CompanyButtonList.length);

                if (snapshot.hasData) {
                  List<GroupInfo> groupWidgets = [];
                  if (!snapshot.data.isEmpty) {
                    List<GroupInfo> grouplist = snapshot.data;
                    groupWidgets = grouplist.reversed.toList();
                  }
                  return ListView(
                    reverse: false,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    children: groupWidgets,
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
          AddGroupButton(),
        ]),
      ],
    );

    //return Column();
  }

  Future<int> getGroupData(String gid) async {
    // var newGroupData = await getUserInfo().getCompanyGroupData(context.read<UserState>().currentCompanyID
    //       ,gid );
    int chatCout = 0;

    var chats = _firestore
        .collection('公司')
        .doc(context.read<UserState>().currentCompanyID)
        .collection('群組')
        .doc(gid)
        .collection('聊天紀錄')
        .where('sender',
            isNotEqualTo: context.read<UserState>().currentUserName);

    await chats.get().then((chat) => {
          print(chat.docs.map((e) => {e.data()['reads'], chatCout++}))
        });

    print(chatCout);

    return chatCout;
  }
}
