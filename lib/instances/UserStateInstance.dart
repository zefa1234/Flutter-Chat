import 'package:chat_app/pages/chatterScreen.dart';
import 'package:chat_app/pages/mainScreen.dart';
import 'package:chat_app/pages/navigation.dart';
import 'package:chat_app/pages/navigation/page_group.dart';
import 'package:chat_app/pages/navigation/page_member.dart';
import 'package:chat_app/widgets/Company.dart';
import 'package:chat_app/widgets/editProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:transformer_page_view/transformer_page_view.dart';

final _firestore = FirebaseFirestore.instance;
var user = _auth.currentUser;
var _auth = FirebaseAuth.instance;

class UserState with ChangeNotifier {
  String _currentUserName = "";
  String _currentUserId = "";
  String _currentUserEmail = "";
  String _currentUserPhotoUrl = "";
  String _currentUserPhoneNumber = "";
  bool _deepColor = false;
  bool _isCompanyNull = true;
  SharedPreferences _sharedPreferences;
  List _currentUserCompanyListRef = [];
  List _currentUserCompanyListName = [];
  Map _currentUserCompanyMap = {};
  List _currentUserGroupListRef = [];
  List _currentUserGroupListName = [];
  Map _currentUserGroupMap = {};
  String _currentCompanyID = '';
  String _currentCompanyName = '';
  String _currentGroupName = '';
  String _currentGroupID = '';
  PageController _pageController = new PageController(
    initialPage: 0,
    keepPage: true,
  );
  List<Widget> _viewList = [];
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  Stream<List<GroupInfo>> _streamGroup;
  Stream<List<UserInfo>> _streamMember;
  Stream<List<MessageBubble>> _streamChatter;
  Stream<List<TaskInfo>> _streamTask;
  Stream<List<TaskInfo>> _streamSubTask;
  int _navigatorIndex = 0;
  TransformerPageController _transcontroller;
  TransformerPageView _transformerPageView;

  //List<Widget> _navi = [GroupPage(), GroupPage(), MemberPage()];
  // Widget _drawer = ChatterDrawer();
  //BuildContext _drawerContext;

  String get currentUserName => _currentUserName;
  String get currentUserId => _currentUserId;
  String get currentUserEmail => _currentUserEmail;
  String get currentUserPhotoUrl => _currentUserPhotoUrl;
  String get currentUserPhoneNumber => _currentUserPhoneNumber;
  bool get deepColor => _deepColor;
  SharedPreferences get sharedPreferences => _sharedPreferences;
  List get currentUserCompanyListName => _currentUserCompanyListName;
  List get currentUserCompanyListRef => _currentUserCompanyListRef;
  Map get currentUserCompanyMap => _currentUserCompanyMap;
  List get currentUserGroupListRef => _currentUserGroupListRef;
  List get currentUserGroupListName => _currentUserGroupListName;
  Map get currentUserGroupMap => _currentUserGroupMap;
  String get currentCompanyID => _currentCompanyID;
  String get currentCompanyName => _currentCompanyName;
  String get currentGroupName => _currentGroupName;
  String get currentGroupID => _currentGroupID;
  PageController get pageController => _pageController;
  List<Widget> get viewList => _viewList;
  bool get isCompanyNull => _isCompanyNull;
  GlobalKey<ScaffoldState> get drawerKey => _drawerKey;
  // Stream<List<Map<dynamic, dynamic>>> get streamGroup => _streamGroup;
  Stream<List<GroupInfo>> get streamGroup => _streamGroup;
  Stream<List<UserInfo>> get streamMember => _streamMember;
  Stream<List<MessageBubble>> get streamChatter => _streamChatter;
  Stream<List<TaskInfo>> get streamTask => _streamTask;
  Stream<List<TaskInfo>> get streamSubTask => _streamSubTask;
  int get navigatorIndex => _navigatorIndex;
  TransformerPageController get transcontroller => _transcontroller;
  TransformerPageView get transformerPageView => _transformerPageView;
  //List<Widget> get navi => _navi;

  // Widget get drawer => _drawer;
  //BuildContext get drawerContext => _drawerContext;

  // 建構時初始化
  UserState(AdaptiveThemeMode savedThemeMode) {
    SharedPreferences.getInstance().then((prefs) {
      _sharedPreferences = prefs;
    });

    if (savedThemeMode != null) {
      _deepColor = savedThemeMode.isDark;
      print("deepColor: $_deepColor");
    }
  }

  Future<void> getInformation() async {
    user = _auth.currentUser;
    var newUserAllData = await getUserInfo().getUserAllData(user.uid);

    _currentUserName = newUserAllData['名稱'];
    _currentUserEmail = newUserAllData['信箱'];
    _currentUserPhotoUrl = newUserAllData['照片'];
    _currentUserPhoneNumber = newUserAllData['電話'];
    _currentUserId = newUserAllData['uid'];
    _currentUserCompanyListRef = newUserAllData['公司'];
    List tempCompanyNameList = [];
    Map tempCompanyMap = {};

    for (var doc in _currentUserCompanyListRef) {
      var newCompanyData = await getUserInfo().getCompanyData(doc.id);
      tempCompanyNameList.add(newCompanyData['名稱']);
      tempCompanyMap.addAll({doc.id: newCompanyData['名稱']});
    }

    _currentUserCompanyListName = tempCompanyNameList;
    _currentUserCompanyMap = tempCompanyMap;

    if (tempCompanyMap.isEmpty) {
    } else {}

    print("名稱: $_currentUserName");
    print("信箱: $_currentUserEmail");
    print("照片: $_currentUserPhotoUrl");
    // if (_currentUserCompanyMap.isNotEmpty) {
    //   _currentCompanyID = _currentUserCompanyListRef[0].id;
    //   _currentCompanyName = _currentUserCompanyMap[_currentCompanyID];
    //   setCurrentGroup(_currentCompanyID);
    // } else {}
    notifyListeners();
  }

  Future<void> initCompanyInformation() async {
    if (_currentUserCompanyMap.isNotEmpty) {
      // _currentCompanyID = _currentUserCompanyListRef[0].id;
      // _currentCompanyName = _currentUserCompanyMap[_currentCompanyID];

      setCompany(_currentUserCompanyListRef[0].id,
          _currentUserCompanyMap[_currentUserCompanyListRef[0].id]);
      var newGroupData = await getUserInfo().getCompanyGroupData(
          _currentUserCompanyListRef[0].id, _currentUserCompanyListRef[0].id);

      setCurrentGroup(_currentCompanyID, newGroupData['名稱']);
      _viewList = [MainSceen(), ChatterScreen()];
      // _viewList = [
      //   ChatterScreen(),
      //   MainSceen(),
      // ];

    } else {
      _viewList = [MainSceen_2()];
    }
    notifyListeners();
  }

  void setCompany(String id, String name) {
    _currentCompanyID = id;
    _currentCompanyName = name;

    _streamMember = _firestore
        .collection("公司")
        .doc(_currentCompanyID)
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
                status: cMember['status'],
              );
            })));
    //_currentGroupID = _currentCompanyID;

    getUserInfo().getCompanyGroupData(_currentCompanyID, id).then((value) => {
          //_currentGroupName = value['名稱'],
          setCurrentGroup(_currentCompanyID, value['名稱']),
        });

    //setCurrentGroup(_currentGroupID);
    _viewList = [MainSceen(), ChatterScreen()];
    //updateTranscontroller();
    // _transformerPageView = TransformerPageView.children(
    //           pageController: _transcontroller,
    //           transformer: ScaleAndFadeTransformer(),
    //           children: _viewList);

    //_viewList = [ChatterScreen(), MainSceen()];
    updateViewPage(0);

    //updateViewTrans(0);
    updateNavigationPage(0);
    notifyListeners();
  }

  // void setDrawerContext(BuildContext context) {
  //   _drawerContext = context;
  //   notifyListeners();
  // }

  void updateDeepColor(bool newDeepColor) {
    _deepColor = newDeepColor;
    notifyListeners();
  }

  void updateTranscontroller() {
    _transcontroller = TransformerPageController(
        initialPage: 0, keepPage: true, itemCount: _viewList.length);
    notifyListeners();
  }

  Future<void> updateCompanyMap(var companylist) async {
    List tempCompanyNameList = [];
    Map tempCompanyMap = {};

    for (var doc in companylist) {
      tempCompanyMap.addAll(doc);
    }

    //_currentUserCompanyListName = tempCompanyNameList;
    _currentUserCompanyMap = tempCompanyMap;
    print(_currentUserCompanyMap);
    //notifyListeners();
  }

  void updateNavigationPage(int index) {
    _navigatorIndex = index;
    notifyListeners();
  }

  void updateViewPage(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 400), curve: Curves.ease);
    print(_pageController.offset);
    notifyListeners();
  }

  void updateViewTrans(int index) {
    _transcontroller.animateToPage(index,
        duration: Duration(milliseconds: 400), curve: Curves.ease);
    notifyListeners();
  }

  Future<void> updateCompanyList(List list) async {
    _currentUserCompanyListRef = list;
    List tempCompanyNameList = [];
    Map tempCompanyMap = {};

    for (var doc in _currentUserCompanyListRef) {
      var newCompanyData = await getUserInfo().getCompanyData(doc.id);
      tempCompanyNameList.add(newCompanyData['名稱']);
      tempCompanyMap.addAll({doc.id: newCompanyData['名稱']});
    }

    _currentUserCompanyListName = tempCompanyNameList;
    _currentUserCompanyMap = tempCompanyMap;
    notifyListeners();
  }

  void setCurrentGroup(String id, String name) async {
    _currentGroupName = name;
    _currentGroupID = id;

    _streamGroup = _firestore
        .collection('公司')
        .doc(_currentCompanyID)
        .collection('成員')
        .doc(_currentUserId)
        .collection('群組')
        .snapshots()
        .asyncMap((groups) => Future.wait(groups.docs.map((group) async {
              if (group.exists) {
                DocumentReference groupRef = group.data()['群組'];

                Map cgroup;

                //var newUserAllData =
                await getUserInfo().getUserAllData(user.uid);
                var value = await groupRef.get();
                //var companyreflist = newUserAllData['公司'];
                //context.read<UserState>().updateCompanyMap(companyreflist);
                cgroup = value.data();
                Map temp = {
                  "id": groupRef.id,
                };

                return GroupInfo(
                  id: temp['id'],
                );
              } else {
                return null;
              }
            })));

    setCurrentChat();
    setCurrentTask();

    notifyListeners();
  }

  void setCurrentChat() async {
    _streamChatter = _firestore
        .collection('公司')
        .doc(_currentCompanyID)
        .collection('群組')
        .doc(_currentGroupID)
        .collection('聊天紀錄')
        .orderBy('timestamp')
        .snapshots()
        .asyncMap((chatlog) => Future.wait(chatlog.docs.map((log) async {
              Map logMap = log.data();
              var userRef = await logMap['userRef'].get();
              Map memberMap = userRef.data();
              userInfoMap[memberMap['uid']] = UserInfo(
                uid: memberMap['uid'],
                name: memberMap['名稱'],
                email: memberMap['信箱'],
                photoUrl: memberMap['照片'],
                phoneNumber: memberMap['電話'],
              );

              List readList = logMap['reads'];
              if ((_currentUserId != logMap['userId']) &&
                  (!readList.contains(_currentUserId))) {
                readList.add(_currentUserId);
                _firestore
                    .collection('公司')
                    .doc(_currentCompanyID)
                    .collection('群組')
                    .doc(_currentGroupID)
                    .collection('聊天紀錄')
                    .doc(log.id)
                    .update({'reads': readList});
              }

              return MessageBubble(
                msgId: log.id,
                msgText: logMap['text'],
                msgSender: logMap['sender'],
                user: _currentUserId == logMap['userId'],
                msgUserId: logMap['userId'],
                msgUserImg: memberMap['照片'],
                star: logMap['star'],
                takeback: logMap['takeback'],
                reads: logMap['reads'].length,
                color: logMap['color'],
                timestamp: logMap['timestamp'],
                image: logMap['image'],
              );
            })));
    notifyListeners();
  }

  void setCurrentTask() async {
    _streamTask = _firestore
        .collection('公司')
        .doc(_currentCompanyID)
        .collection('群組')
        .doc(_currentGroupID)
        .collection('任務列表')
        .snapshots()
        .asyncMap((tasks) => Future.wait(tasks.docs.map((task) async {
              Map logMap = task.data();
              return TaskInfo(
                uid: task.id,
                name: logMap['名稱'],
                description: logMap['說明'],
                members: logMap['成員'],
              );
            })));
    notifyListeners();
  }

  void setSubCurrentTask(taskId) async {
    _streamSubTask = _firestore
        .collection('公司')
        .doc(_currentCompanyID)
        .collection('群組')
        .doc(_currentGroupID)
        .collection('任務列表')
        .doc(taskId)
        .collection('子任務')
        .snapshots()
        .asyncMap((tasks) => Future.wait(tasks.docs.map((task) async {
              Map logMap = task.data();
              return TaskInfo(
                uid: task.id,
                name: logMap['名稱'],
                description: logMap['說明'],
                members: logMap['成員'],
              );
            })));
    notifyListeners();
  }

  void updateUserWigetInfo() {
    getInformation();
  }
}

class UserInfo {
  String uid;
  String name;
  String email;
  String photoUrl;
  String phoneNumber;
  String status;

  UserInfo(
      {this.uid,
      this.name,
      this.email,
      this.photoUrl,
      this.phoneNumber,
      this.status});
}

class GroupInfo extends StatelessWidget {
  final String id;

  GroupInfo({
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('公司')
          .doc(context.read<UserState>().currentCompanyID)
          .collection('群組')
          .doc(id)
          .snapshots()
          .asyncMap((groupInfo) async {
        groupInfo.data();

        int chatCout = 0;
        var chats = _firestore
            .collection('公司')
            .doc(context.read<UserState>().currentCompanyID)
            .collection('群組')
            .doc(id)
            .collection('聊天紀錄')
            .where('sender',
                isNotEqualTo: context.read<UserState>().currentUserName);

        await chats.get().then((chat) => {
              print(chat.docs.map((e) {
                List tempList = e.data()['reads'];
                print("${tempList}*************");
                if (tempList
                        .contains(context.read<UserState>().currentUserId) ==
                    false) {
                  chatCout++;
                }
              }))
            });

        //print(chatCout);

        Map temp = {
          '名稱': groupInfo.data()['名稱'],
          'topMessage': groupInfo.data()['topMessage'],
          'chatCout': chatCout.toString()
        };

        return temp;
      }),
      //_firestore.collection('公司').doc(context.read<UserState>().currentCompanyID).collection('群組').doc()
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var groupInfo = snapshot.data;

          return ListTile(
            title: Text(groupInfo['名稱']),
            subtitle: Text(groupInfo['topMessage']),
            // trailing: Text(group['chatCount'].toString()),
            trailing: groupInfo['chatCout'] != 0.toString()
                ? Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        width: 40.0,
                        height: 40.0,
                        child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Color.fromARGB(255, 40, 207, 49)),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: 40.0,
                        height: 40.0,
                        child: Text(
                          groupInfo['chatCout'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                : null,
            onTap: () {
              context.read<UserState>().setCurrentGroup(id, groupInfo['名稱']);
              context.read<UserState>().updateViewPage(1);
              // Navigator.pop(context);
            },
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

class TaskInfo {
  String uid;
  String name;
  String description;
  List members;

  TaskInfo({this.uid, this.name, this.description, this.members});
}
