import 'package:chat_app/instances/UserStateInstance.dart';
import 'package:chat_app/widgets/UserInfoDialog.dart';
import 'package:chat_app/widgets/dynamicLink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final _firestore = FirebaseFirestore.instance;
Stream<List<UserInfo>> UserInfoStream;
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class PermessagePage extends StatefulWidget {
  @override
  _PermessagePageState createState() => _PermessagePageState();
}

class _PermessagePageState extends State<PermessagePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Text("havent done yet"),
      ),
    ]);
  }
}
