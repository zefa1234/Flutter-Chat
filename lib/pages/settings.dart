import 'package:chat_app/instances/UserStateInstance.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:passcode_screen/passcode_screen.dart';
import "dart:async";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class ChatterSettings extends StatefulWidget {
  @override
  _ChatterSettingsState createState() => _ChatterSettingsState();
}

class _ChatterSettingsState extends State<ChatterSettings> {
  final chatMsgTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  void _onPasscodeEntered(String enteredPasscode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("appLock", enteredPasscode);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var inputController = InputController();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.deepPurple),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
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
                  'App Setting',
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
      body: Container(
        margin: EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                flex: 6,
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                      GestureDetector(
                        child: Text(
                          '個人資料',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 30),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                      GestureDetector(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '深色模式',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 30,
                                ),
                              ),
                              FlutterSwitch(
                                width: 80.0,
                                height: 40.0,
                                toggleSize: 30.0,
                                value:
                                    Provider.of<UserState>(context).deepColor,
                                borderRadius: 30.0,
                                padding: 0,
                                activeToggleColor: Color(0xFF6E40C9),
                                inactiveToggleColor: Color(0xFF2F363D),
                                activeSwitchBorder: Border.all(
                                  color: Color(0xFF3C1E70),
                                  width: 6.0,
                                ),
                                inactiveSwitchBorder: Border.all(
                                  color: Color(0xFFD1D5DA),
                                  width: 6.0,
                                ),
                                activeColor: Color(0xFF271052),
                                inactiveColor: Colors.white,
                                activeIcon: Icon(
                                  Icons.nightlight_round,
                                  color: Color(0xFFF8E3A1),
                                ),
                                inactiveIcon: Icon(
                                  Icons.wb_sunny,
                                  color: Color(0xFFFFDF5D),
                                ),
                                onToggle: (val) async {
                                  context
                                      .read<UserState>()
                                      .updateDeepColor(val);
                                  val
                                      ? AdaptiveTheme.of(context).setDark()
                                      : AdaptiveTheme.of(context).setLight();
                                },
                              ),
                            ]),
                      ),
                      GestureDetector(
                          child: Text(
                            'APP安全鎖',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 30,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return SizedBox(
                                    width: 200.0,
                                    height: 300.0,
                                    child: PasscodeScreen(
                                      title: Text(
                                        '設置新密碼',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 28),
                                      ),
                                      passwordDigits: 4,
                                      passwordEnteredCallback:
                                          _onPasscodeEntered,
                                      cancelButton: Text('Cancel'),
                                      deleteButton: Text('Delete'),
                                      shouldTriggerVerification:
                                          _verificationNotifier.stream,
                                      cancelCallback: () {
                                        Navigator.pop(context);
                                      },
                                    ));
                              },
                            );
                          }),
                      GestureDetector(
                        child: Shimmer.fromColors(
                          baseColor: Provider.of<UserState>(context).deepColor
                              ? Colors.white
                              : Colors.black,
                          highlightColor: Colors.red,
                          child: Text(
                            '贊助開發者',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                    ]))),
            Expanded(flex: 1, child: Text('')),
          ],
        ),
      ),
    );
  }
}
