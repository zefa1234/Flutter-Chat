import 'dart:ffi';

import 'package:chat_app/widgets/editProfile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../instances/UserStateInstance.dart';
import 'package:chat_app/widgets/custombutton.dart';
import 'package:chat_app/widgets/customtextinput.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

final _firestore = FirebaseFirestore.instance;

class Company extends StatefulWidget {
  Company();

  @override
  _CompanyState createState() => _CompanyState();
}

class _CompanyState extends State<Company> {
  List<CustomButton> names = <CustomButton>[];
  String inputCompanyName = "";
  TextEditingController nameController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //context.read<UserState>().getInformation();
  }

  void addItemToList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Input Company name"),
        content: CustomTextInput(
          hintText: 'Company name',
          leading: Icons.text_format,
          keyboard: TextInputType.name,
          obscure: false,
          userTyped: (value) {
            inputCompanyName = value;
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel")),
          TextButton(
              onPressed: () async {
                /*setState(() {
                  names.insert(
                      0,
                      CustomButton(
                        accentColor: Colors.white,
                        mainColor: Colors.deepPurple,
                        text: inputCompanyName,
                      ));
                });*/

                DocumentReference userRef = _firestore
                    .collection('使用者')
                    .doc(context.read<UserState>().currentUserId);
                DocumentReference companyRef =
                    await _firestore.collection('公司').add({
                  '名稱': inputCompanyName,
                  '創建者': userRef,
                });

                _firestore
                    .collection('公司')
                    .doc(companyRef.id)
                    .collection('成員')
                    .doc(context.read<UserState>().currentUserId)
                    .set({});
                DocumentReference memberRef = _firestore.doc('/公司/' +
                    companyRef.id +
                    '/成員/' +
                    context.read<UserState>().currentUserId);

                final fcmToken = await FirebaseMessaging.instance.getToken();

                _firestore
                    .collection('公司')
                    .doc(companyRef.id)
                    .collection('群組')
                    .doc(companyRef.id)
                    .set({
                  '類別': '群組',
                  '名稱': "${inputCompanyName} - 大廳",
                  '成員': [memberRef],
                  'memberTokens': [
                    fcmToken,
                  ],
                  'topMessage': "",
                });

                DocumentReference groupRef = _firestore
                    .collection('公司')
                    .doc(companyRef.id)
                    .collection('群組')
                    .doc(companyRef.id);

                _firestore
                    .collection('公司')
                    .doc(companyRef.id)
                    .collection('群組')
                    .doc(groupRef.id)
                    .collection('聊天紀錄')
                    .add({});
                _firestore
                    .collection('公司')
                    .doc(companyRef.id)
                    .collection('成員')
                    .doc(memberRef.id)
                    .set({
                  '使用者': userRef,
                  '群組': [groupRef],
                });

                _firestore
                    .collection('公司')
                    .doc(companyRef.id)
                    .collection('成員')
                    .doc(memberRef.id)
                    .collection('群組')
                    .add({"群組": groupRef});

                DocumentReference usercompanyRef = await _firestore
                    .collection('使用者')
                    .doc(userRef.id)
                    .collection('公司群')
                    .add({"公司Ref": companyRef});
                List tempCompanyList =
                    context.read<UserState>().currentUserCompanyListRef;
                tempCompanyList.add(companyRef);
                await _firestore
                    .collection('使用者')
                    .doc(userRef.id)
                    .update({'公司': tempCompanyList});

                //context.read<UserState>().updateUserWigetInfo();

                context
                    .read<UserState>()
                    .setCompany(companyRef.id, inputCompanyName);
                inputCompanyName = "";
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Flexible(
        flex: 5,
        child: Container(
          alignment: Alignment.center,
          child: CompanyListStream(),
        ),
      ),
      Flexible(
        flex: 1,
        child: Container(
          alignment: Alignment.center,
          child: IconButton(
            icon: Icon(Icons.add, color: Colors.blue[300], size: 40),
            onPressed: () {
              addItemToList();
              //Navigator.pop(context);
            },
          ),
        ),
      ),
    ]);
  }
}

class CompanyListStream extends StatelessWidget {
  CompanyListStream();
  @override
  Widget build(BuildContext context) {
    // context.read<UserState>().getInformation();
    return StreamBuilder(
      stream: _firestore
          .collection('使用者')
          .doc(context.read<UserState>().currentUserId)
          .collection('公司群')
          .snapshots()
          .asyncMap(
              (companys) => Future.wait(companys.docs.map((company) async {
                    if (company.exists) {
                      DocumentReference companyRef = company.data()['公司Ref'];
                      Map cMember;

                      //var newUserAllData =
                      await getUserInfo().getUserAllData(user.uid);
                      var value = await companyRef.get();
                      //var companyreflist = newUserAllData['公司'];
                      //context.read<UserState>().updateCompanyMap(companyreflist);
                      cMember = value.data();
                      Map temp = {"id": companyRef.id, "名稱": cMember['名稱']};

                      return temp;
                    } else {
                      return null;
                    }
                  }))),
      builder: (context, snapshot) {
        var companys = snapshot.data;
        if (companys != null) {
          List<CustomButton> CompanyButtonList = [];
          context.read<UserState>().updateCompanyMap(companys);
          for (var company in companys) {
            print(company['名稱']);

            CustomButton tempButton = CustomButton(
              accentColor: Colors.grey[800],
              mainColor: Colors.white,
              text: company['名稱'],
              onpress: () {
                context
                    .read<UserState>()
                    .setCompany(company['id'], company['名稱']);
                // context.read<UserState>().updateTranscontroller();
                // context.read<UserState>().updateViewTrans(0);
                Navigator.pop(context);
              },
            );

            CompanyButtonList.add(tempButton);
          }

          return ListView.separated(
              itemBuilder: (context, index) {
                return CompanyButtonList[index];
              },
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              separatorBuilder: (BuildContext context, int index) => Divider(
                    height: 8.0,
                    color: Color(0xFFFFFFFF),
                  ),
              itemCount: CompanyButtonList.length);
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
