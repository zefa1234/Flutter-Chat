import 'package:chat_app/pages/chatterScreen.dart';
import 'package:chat_app/pages/navigation/page_group.dart';
import 'package:chat_app/pages/navigation/page_permessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/widgets/Company.dart';
import 'package:chat_app/pages/navigation/page_member.dart';
import '../instances/UserStateInstance.dart';

var _auth = FirebaseAuth.instance;

class MainSceen extends StatefulWidget {
  @override
  _MainSceenState createState() => _MainSceenState();
}

class _MainSceenState extends State<MainSceen> {
  int _currentIndex = 0;
  BottomNavigationBar navigator;
  var pages = [GroupPage(), PermessagePage(), MemberPage()];
  var pageView;

  void initState() {
    setState(() {
      _currentIndex = 0;
      pageView = pages;
    });

    super.initState();
  }

  void _onItemClick(int index) {
    // if (hasCompany == false) {
    //   Fluttertoast.showToast(
    //       msg: "尚無公司!",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.TOP,
    //       timeInSecForIosWeb: 1,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    //   return;
    // }
    setState(() {
      _currentIndex = index;
      context.read<UserState>().updateNavigationPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    //final UserState userState = Provider.of<UserState>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: new SingleChildScrollView(
          child: new ConstrainedBox(
        constraints: new BoxConstraints(
          minHeight: 120.0,
        ),
        child: new Column(
          children: [pageView[context.watch<UserState>().navigatorIndex]],
        ),
      )),
/*
      body: Column(
        children: [pageView[context.watch<UserState>().navigatorIndex]],
        //children: [context.watch<UserState>().navi[_currentIndex]],
      ),
      //body: Column(),*/

      appBar: AppBar(
        leading: new IconButton(
            onPressed: () {
              context.read<UserState>().drawerKey.currentState.openDrawer();
            },
            icon: Icon(Icons.menu)),
        iconTheme: IconThemeData(color: Colors.deepPurple),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size(25, 10),
          child: Container(
            child: LinearProgressIndicator(
              value: 100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.deepPurple,
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
                  context.watch<UserState>().currentCompanyName,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.deepPurple),
                )
              ],
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.deepPurple,
            onPressed: () => {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            color: Colors.deepPurple,
            onPressed: null,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '群組'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '私訊'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: '成員'),
        ],
        currentIndex: context.read<UserState>().navigatorIndex,
        // selectedIconTheme: IconThemeData(
        //     color: Colors.deepPurple[900]), //Colors.deepPurple[900],
        // //unselectedIconTheme: Colors.grey,
        fixedColor: Colors.deepPurple[900],
        // selectedItemColor: Colors.deepPurple[900],
        // unselectedItemColor: Colors.grey,
        onTap: _onItemClick,
      ),
    );
  }
}

class MainSceen_2 extends StatefulWidget {
  @override
  _MainSceenState_2 createState() => _MainSceenState_2();
}

class _MainSceenState_2 extends State<MainSceen_2> {
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          child: Center(
        child: Text("NO COMPANY EXIST~"),
      )), // drawer: Drawer(

      appBar: AppBar(
        leading: new IconButton(
            onPressed: () {
              context.read<UserState>().drawerKey.currentState.openDrawer();
            },
            icon: Icon(Icons.menu)),
        iconTheme: IconThemeData(color: Colors.deepPurple),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size(25, 10),
          child: Container(
            child: LinearProgressIndicator(
              value: 100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.deepPurple,
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
                  context.watch<UserState>().currentCompanyName,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.deepPurple),
                )
              ],
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.grey,
            onPressed: () => {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            color: Colors.deepPurple,
            onPressed: null,
          )
        ],
      ),
      bottomNavigationBar: null,
    );
  }
}
