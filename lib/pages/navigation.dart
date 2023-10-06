import 'package:chat_app/pages/chatterScreen.dart';
import 'package:chat_app/pages/mainScreen.dart';
import 'package:chat_app/pages/navigation/page_group.dart';
import 'package:chat_app/widgets/editProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/widgets/Company.dart';
import 'package:chat_app/pages/navigation/page_member.dart';
import '../instances/UserStateInstance.dart';
import 'package:transformer_page_view/transformer_page_view.dart';

var _auth = FirebaseAuth.instance;
final _user = FirebaseAuth.instance.currentUser;

final _firestore = FirebaseFirestore.instance;

class ChatterNavigation extends StatefulWidget {
  @override
  _ChatterNavigationState createState() => _ChatterNavigationState();
}

class _ChatterNavigationState extends State<ChatterNavigation>
    with WidgetsBindingObserver {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<UserState>().getInformation().then((value) => {
          // 預設取第一筆公司
          context.read<UserState>().initCompanyInformation(),
        });
    setStatus("Online");
    //
  }

  void setStatus(String status) async {
    await _firestore.collection('使用者').doc(_user.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  // Widget build(BuildContext context) {
  //   //final UserState userState = Provider.of<UserState>(context);
  //   return context.watch<UserState>().drawer;
  // }

  Widget build(BuildContext context) {
    //final UserState userState = Provider.of<UserState>(context);
    return Scaffold(
      key: context.read<UserState>().drawerKey,
      resizeToAvoidBottomInset: false,
      body: MainPageView(),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple[900],
              ),
              accountName: Text(context.watch<UserState>().currentUserName),
              accountEmail: Text(context.watch<UserState>().currentUserEmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    context.watch<UserState>().currentUserPhotoUrl),
              ),
              onDetailsPressed: () {},
              otherAccountsPictures: <Widget>[
                IconButton(
                    onPressed: () =>
                        {Navigator.pushNamed(context, '/settings')},
                    icon: Icon(Icons.settings, color: Colors.white)),
              ],
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
              subtitle: Text("Sign out of this account"),
              onTap: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            Expanded(child: Company())
          ],
        ),
      ),
    );
  }
}

class MainPageView extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      // body: PageView(
      //   controller: context.watch<UserState>().pageController,
      //   children: context.watch<UserState>().viewList,
      // ),
      body: Consumer<UserState>(
        builder: (context, value, child) {
          return PageView(
            controller: value.pageController,
            children: value.viewList,
          );
          // return TransformerPageView(
          //   scrollDirection: Axis.vertical,
          //   curve: Curves.easeInBack,
          //   transformer: ScaleAndFadeTransformer(), // transformers[5],
          //   itemCount: value.viewList,
          //   itemBuilder: (context, index) {

          //   },
          // );

          // TransformerPageController controller =
          //     TransformerPageController(itemCount: value.viewList.length,initialPage: 0,keepPage: true);

          // return TransformerPageView.children(
          //     pageController: value.transcontroller,
          //     transformer: ScaleAndFadeTransformer(),
          //     children: value.viewList);

          //return value.transformerPageView;
        },
      ),
    );
  }
}

class ScaleAndFadeTransformer extends PageTransformer {
  final double _scale;
  final double _fade;

  ScaleAndFadeTransformer({double fade: 0.3, double scale: 0.8})
      : _fade = fade,
        _scale = scale;

  @override
  Widget transform(Widget item, TransformInfo info) {
    double position = info.position;
    double scaleFactor = (1 - position.abs()) * (1 - _scale);
    double fadeFactor = (1 - position.abs()) * (1 - _fade);
    double opacity = _fade + fadeFactor;
    double scale = _scale + scaleFactor;
    return new Opacity(
      opacity: opacity,
      child: new Transform.scale(
        scale: scale,
        child: item,
      ),
    );
  }
}
