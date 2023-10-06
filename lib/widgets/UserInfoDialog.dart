import 'package:flutter/material.dart';

class UserInfoDialog {
  final String name;
  final String email;
  final String photoUrl;
  final String phoneNumber;
  UserInfoDialog(this.name, this.email, this.phoneNumber, this.photoUrl);

  showUserInfoDialog(BuildContext currentContext) {
    showDialog(
        context: currentContext,
        builder: (ctx) {
          return SizedBox(
            width: 200.0,
            height: 100.0,
            child: AlertDialog(
              title: Text("聯絡資訊"),
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50.0,
                      height: 50.0,
                      child: CircleAvatar(
                          radius: 100, backgroundImage: NetworkImage(photoUrl)),
                    ),
                    Text(name),
                    Text(email),
                    Text(phoneNumber),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
