import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

class ChatterSplash extends StatefulWidget {
  @override
  _ChatterSplash createState() => _ChatterSplash();
}

class _ChatterSplash extends State<ChatterSplash>
    with TickerProviderStateMixin {
  AnimationController mainController;
  Animation mainAnimation;
  String appLock = '';
  bool getLock = false;
  final user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();

    getAppLock();
  }

  getAppLock() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var preAppLock = prefs.getString('appLock');
    print(" app lock: $preAppLock");
    if (preAppLock == "" || preAppLock == null) {
      if (user == null)
        Navigator.pushNamed(context, '/login');
      else
        Navigator.pushNamed(context, '/navigation');
    } else {
      setState(() {
        getLock = true;
        appLock = preAppLock;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;
    if (!getLock) {
      return Scaffold();
    } else {
      return Scaffold(
        body: SizedBox(
            width: double.infinity,
            child: ScreenLock(
                correctString: appLock,
                didUnlocked: () {
                  if (user == null)
                    Navigator.pushNamed(context, '/login');
                  else
                    Navigator.pushNamed(context, '/navigation');
                })),
      );
    }
  }
}
