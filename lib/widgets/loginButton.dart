import 'package:chat_app/instances/UserStateInstance.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSigninButton extends StatelessWidget {
  final _auth;
  GoogleSigninButton(this._auth);
  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    return SignInButton(
      Buttons.Google,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      onPressed: () async {
        try {
          final GoogleSignInAccount googleAccount =
              await GoogleSignIn().signIn();
          final GoogleSignInAuthentication googleAuth =
              await googleAccount.authentication;
          final GoogleAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          UserCredential authResult =
              await _auth.signInWithCredential(credential);
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (authResult.additionalUserInfo.isNewUser) {
            _firestore.collection('使用者').doc(_auth.currentUser.uid).set({
              'uid': _auth.currentUser.uid,
              '名稱': _auth.currentUser.displayName,
              '信箱': _auth.currentUser.email,
              '照片': googleAccount.photoUrl,
              '電話': '',
              '公司': [],
              'token': fcmToken,
              'status': '',
            });
          }

          Navigator.pushReplacementNamed(context, '/navigation');
        } catch (e) {
          print(e);
        }
      },
    );
  }
}

class FacebookSigninButton extends StatelessWidget {
  final _auth;
  FacebookSigninButton(this._auth);
  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    return SignInButton(
      Buttons.Facebook,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      onPressed: () async {
        try {
          final fb = FacebookLogin();
          final res = await fb.logIn(permissions: [
            FacebookPermission.publicProfile,
            FacebookPermission.email,
          ]);

          switch (res.status) {
            case FacebookLoginStatus.success:
              final FacebookAuthCredential credential =
                  FacebookAuthProvider.credential(res.accessToken.token);
              UserCredential authResult =
                  await _auth.signInWithCredential(credential);
              if (authResult.additionalUserInfo.isNewUser) {
                String photoUrl = _auth.currentUser.photoURL +
                    "?height=500&access_token=" +
                    res.accessToken.token;
                final fcmToken = await FirebaseMessaging.instance.getToken();
                _firestore.collection('使用者').doc(_auth.currentUser.uid).set({
                  'uid': _auth.currentUser.uid,
                  '名稱': _auth.currentUser.displayName,
                  '信箱': _auth.currentUser.email,
                  '照片': photoUrl,
                  '電話': '',
                  '公司': [],
                  'token': fcmToken,
                  'status': '',
                });
              }
              Navigator.pushReplacementNamed(context, '/navigation');
              break;
            case FacebookLoginStatus.cancel:
              print('cancel');
              break;
            case FacebookLoginStatus.error:
              print('Error while log in: ${res.error}');
              break;
          }
        } catch (e) {
          print(e);
        }
      },
    );
  }
}
