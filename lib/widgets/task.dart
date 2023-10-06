import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chat_app/instances/UserStateInstance.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:d_chart/d_chart.dart';

final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;
String currentTaskId;

final taskDescriptionController = TextEditingController();
final subTaskDescriptionController = TextEditingController();
List<dynamic> groupMemeber, allTaskMember = [], allSubTaskMember = [];
int backPageIndex = 1;

final _pageController = PageController(
  initialPage: 1,
  keepPage: true,
);

class myTask extends StatefulWidget {
  myTask();

  @override
  _TaskState createState() => _TaskState();
}

class _TaskState extends State<myTask> {
  List<Widget> titleWigets,
      firstTitle,
      secondTitle,
      thirdTitle,
      fourthTitle,
      pieChartTitle;

  Column firstPage, fourthPage, pieChartPage;
  List<Map<String, dynamic>> DChartPieData = [];

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final nameController2 = TextEditingController();
  final descriptionController2 = TextEditingController();

  List<Widget> memberList = [];
  List<bool> selectedMembers = [];
  List<Map> membersData = [];

  getMemberList() async {
    await _firestore
        .collection('公司')
        .doc(context.read<UserState>().currentCompanyID)
        .collection('群組')
        .doc(context.read<UserState>().currentGroupID)
        .get()
        .then((value) => {groupMemeber = value.data()['成員']});

    for (var i = 0; i < groupMemeber.length; i++) {
      DocumentReference memberRef = groupMemeber[i];
      await _firestore.collection('使用者').doc(memberRef.id).get().then((value) =>
          {
            membersData.add(value.data()),
            selectedMembers.add(false),
            memberList.add(
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Center(
                          child: Checkbox(
                            value: selectedMembers[i],
                            onChanged: (bool value) {
                              setState(() {
                                selectedMembers[i] = value;
                              });
                            },
                          ),
                        );
                      })),
                  Expanded(
                      flex: 1,
                      child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(value.data()['照片']))),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(value.data()['名稱'],
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 20)),
                  ),
                ],
              ),
            ),
          });
    }
    setState(() {});
  }

  addNewTask() async {
    List addMembers = [];
    for (var i = 0; i < selectedMembers.length; i++) {
      if (selectedMembers[i]) {
        addMembers.add({
          'uid': groupMemeber[i],
          '名稱': membersData[i]['名稱'],
          '照片': membersData[i]['照片']
        });
      }
    }

    DocumentReference newTaskRef = await _firestore
        .collection('公司')
        .doc(context.read<UserState>().currentCompanyID)
        .collection('群組')
        .doc(context.read<UserState>().currentGroupID)
        .collection('任務列表')
        .add({
      "名稱": nameController.text,
      "說明": descriptionController.text,
      "成員": addMembers
    });

    _firestore
        .collection('公司')
        .doc(context.read<UserState>().currentCompanyID)
        .collection('群組')
        .doc(context.read<UserState>().currentGroupID)
        .collection('任務列表')
        .doc(newTaskRef.id)
        .collection('子任務')
        .add({});
  }

  addNewSubTask() async {
    List addMembers = [];
    for (var i = 0; i < selectedMembers.length; i++) {
      if (selectedMembers[i]) {
        addMembers.add({
          'uid': groupMemeber[i],
          '名稱': membersData[i]['名稱'],
          '照片': membersData[i]['照片']
        });
      }
    }

    DocumentReference newSubTaskRef = await _firestore
        .collection('公司')
        .doc(context.read<UserState>().currentCompanyID)
        .collection('群組')
        .doc(context.read<UserState>().currentGroupID)
        .collection('任務列表')
        .doc(currentTaskId)
        .collection('子任務')
        .add({
      "名稱": nameController2.text,
      "說明": descriptionController2.text,
      "成員": addMembers
    });
  }

  resetPage1() {
    nameController.clear();
    descriptionController.clear();
    for (var i = 0; i < selectedMembers.length; i++) {
      setState(() {
        selectedMembers[i] = false;
      });
    }
  }

  resetPage4() {
    nameController2.clear();
    descriptionController2.clear();
    for (var i = 0; i < selectedMembers.length; i++) {
      setState(() {
        selectedMembers[i] = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getMemberList();

    firstTitle = [
      Text('新增任務'),
      Spacer(),
      GestureDetector(
        onTap: () {
          setState(() {
            titleWigets = secondTitle;
          });
          _pageController.animateToPage(
            1,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          );
        },
        child: Icon(Icons.arrow_circle_right_rounded),
      ),
    ];

    secondTitle = [
      Text('任務列表'),
      Spacer(),
      GestureDetector(
        onTap: () {
          setState(() {
            titleWigets = firstTitle;
          });
          resetPage1();
          _pageController.animateToPage(
            0,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          );
        },
        child: Icon(Icons.add_circle_outline),
      ),
    ];

    thirdTitle = [
      GestureDetector(
        onTap: () {
          setState(() {
            titleWigets = secondTitle;
          });
          _pageController.animateToPage(
            1,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          );
        },
        child: Icon(Icons.arrow_circle_left_rounded),
      ),
      Container(margin: EdgeInsets.only(left: 10), child: Text('子任務列表')),
      Spacer(),
      GestureDetector(
        onTap: () {
          setState(() {
            titleWigets = fourthTitle;
          });
          resetPage4();
          _pageController.animateToPage(
            3,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          );
        },
        child: Icon(Icons.add_circle_outline),
      ),
    ];

    fourthTitle = [
      GestureDetector(
        onTap: () {
          setState(() {
            titleWigets = thirdTitle;
          });
          resetPage4();
          _pageController.animateToPage(
            2,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          );
        },
        child: Icon(Icons.arrow_circle_left_rounded),
      ),
      Container(margin: EdgeInsets.only(left: 10), child: Text('新增子任務')),
    ];

    pieChartTitle = [
      GestureDetector(
        onTap: () {
          if (backPageIndex == 1) {
            setState(() {
              titleWigets = secondTitle;
            });
          } else {
            setState(() {
              titleWigets = thirdTitle;
            });
          }
          _pageController.animateToPage(
            backPageIndex,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          );
        },
        child: Icon(Icons.arrow_circle_left_rounded),
      ),
      Container(margin: EdgeInsets.only(left: 10), child: Text('參與程度')),
    ];

    titleWigets = secondTitle;
  }

  goSubTask(taskId) {
    currentTaskId = taskId;
    context.read<UserState>().setSubCurrentTask(taskId);
    setState(() {
      titleWigets = thirdTitle;
    });
  }

  goPieChart(source, members) {
    int memberCount = 0;
    DChartPieData = [];
    Map<String, int> memberParticipation = {};
    if (source == 'mainTask') {
      for (String taskMember in allTaskMember) {
        if (memberParticipation[taskMember] == null) {
          memberParticipation[taskMember] = 0;
        }
        memberParticipation[taskMember]++;
      }

      var ParticipationRate;
      memberParticipation.keys.forEach((k) => {
            ParticipationRate =
                memberParticipation[k] / allTaskMember.length * 100,
            DChartPieData.add({
              'domain': k,
              'measure': double.parse(ParticipationRate.toStringAsFixed(2))
            }),
          });
    } else {
      for (String taskMember in allSubTaskMember) {
        if (memberParticipation[taskMember] == null) {
          memberParticipation[taskMember] = 0;
        }
        memberParticipation[taskMember]++;
      }

      var ParticipationRate;
      memberParticipation.keys.forEach((k) => {
            ParticipationRate =
                memberParticipation[k] / allSubTaskMember.length * 100,
            DChartPieData.add({
              'domain': k,
              'measure': double.parse(ParticipationRate.toStringAsFixed(2))
            }),
          });
    }

    setState(() {
      titleWigets = pieChartTitle;
    });
    _pageController.animateToPage(
      4,
      curve: Curves.ease,
      duration: Duration(milliseconds: 200),
    );
  }

  deleteMainTask(taskId) {
    _firestore
        .collection('公司')
        .doc(context.read<UserState>().currentCompanyID)
        .collection('群組')
        .doc(context.read<UserState>().currentGroupID)
        .collection('任務列表')
        .doc(taskId)
        .delete();
  }

  deleteSubTask(taskId) {
    _firestore
        .collection('公司')
        .doc(context.read<UserState>().currentCompanyID)
        .collection('群組')
        .doc(context.read<UserState>().currentGroupID)
        .collection('任務列表')
        .doc(currentTaskId)
        .collection('子任務')
        .doc(taskId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    firstPage =
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Expanded(
          flex: 2,
          child: Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 0.0),
                  child: Text("名稱",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 12.0),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '請輸入名稱',
                      ),
                    ),
                  )),
            ],
          ))),
      Expanded(
          flex: 2,
          child: Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 0.0),
                  child: Text("說明",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 12.0),
                    child: TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '請輸入說明',
                      ),
                    ),
                  )),
            ],
          ))),
      Expanded(
          flex: 7,
          child:
              Container(child: Center(child: ListView(children: memberList)))),
      Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.blueGrey)),
                  textColor: Colors.white,
                  color: Colors.grey,
                  child: Text('取消'),
                  onPressed: () {
                    resetPage1();
                    setState(() {
                      titleWigets = secondTitle;
                    });
                    _pageController.animateToPage(
                      1,
                      curve: Curves.ease,
                      duration: Duration(milliseconds: 200),
                    );
                  }),
              SizedBox(width: 10),
              RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.blue)),
                  textColor: Colors.white,
                  color: Colors.lightBlue,
                  child: Text('加入'),
                  onPressed: () async {
                    await addNewTask();
                    setState(() {
                      titleWigets = secondTitle;
                    });
                    _pageController.animateToPage(
                      1,
                      curve: Curves.ease,
                      duration: Duration(milliseconds: 200),
                    );
                  })
            ],
          ))
    ]);

    fourthPage =
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Expanded(
          flex: 2,
          child: Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 0.0),
                  child: Text("名稱",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 12.0),
                    child: TextFormField(
                      controller: nameController2,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '請輸入名稱',
                      ),
                    ),
                  )),
            ],
          ))),
      Expanded(
          flex: 2,
          child: Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 0.0),
                  child: Text("說明",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 12.0),
                    child: TextFormField(
                      controller: descriptionController2,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '請輸入說明',
                      ),
                    ),
                  )),
            ],
          ))),
      Expanded(
          flex: 7,
          child:
              Container(child: Center(child: ListView(children: memberList)))),
      Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.blueGrey)),
                  textColor: Colors.white,
                  color: Colors.grey,
                  child: Text('取消'),
                  onPressed: () {
                    resetPage4();
                    setState(() {
                      titleWigets = thirdTitle;
                    });
                    _pageController.animateToPage(
                      2,
                      curve: Curves.ease,
                      duration: Duration(milliseconds: 200),
                    );
                  }),
              SizedBox(width: 10),
              RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.blue)),
                  textColor: Colors.white,
                  color: Colors.lightBlue,
                  child: Text('加入'),
                  onPressed: () async {
                    await addNewSubTask();
                    setState(() {
                      titleWigets = thirdTitle;
                    });
                    _pageController.animateToPage(
                      2,
                      curve: Curves.ease,
                      duration: Duration(milliseconds: 200),
                    );
                  })
            ],
          ))
    ]);

    pieChartPage =
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Expanded(
        child: DChartPie(
          data: DChartPieData,
          fillColor: (pieData, index) {
            return Color.fromRGBO(
                8 + (index + 1) * 50, 8 + (index + 1) * 50, 8, 0.4);
          },
          pieLabel: (pieData, index) {
            return "${pieData['domain']}:\n${pieData['measure']}%";
          },
        ),
      )
    ]);

    return AlertDialog(
        title: Row(children: titleWigets),
        content: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  firstPage,
                  StreamBuilder(
                    stream: context.watch<UserState>().streamTask,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<TaskInfo> messages = snapshot.data;
                        List<Widget> slidableWidgets = [];
                        allTaskMember = [];
                        for (var i = 0; i < messages.length; i++) {
                          if (messages[i].name == '' ||
                              messages[i].name == null) {
                            continue;
                          }
                          for (var j = 0; j < messages[i].members.length; j++) {
                            allTaskMember.add(messages[i].members[j]['名稱']);
                          }
                          slidableWidgets.add(SlidableItem(
                            uid: messages[i].uid,
                            name: messages[i].name,
                            description: messages[i].description,
                            members: messages[i].members,
                            source: 'mainTask',
                            pressFunction: goSubTask,
                            deleteFunction: deleteMainTask,
                            pieChartFunction: goPieChart,
                          ));
                        }

                        return Center(
                            child: ListView.builder(
                          itemCount: slidableWidgets.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.file_copy_outlined),
                                  title: slidableWidgets[index],
                                ),
                                Divider(thickness: 2)
                              ],
                            );
                          },
                        ));
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.deepPurple),
                        );
                      }
                    },
                  ),

                  // 子任務
                  StreamBuilder(
                    stream: context.watch<UserState>().streamSubTask,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<TaskInfo> messages = snapshot.data;
                        List<Widget> slidableWidgets = [];
                        allSubTaskMember = [];
                        for (var i = 0; i < messages.length; i++) {
                          if (messages[i].name == '' ||
                              messages[i].name == null) {
                            continue;
                          }
                          for (var j = 0; j < messages[i].members.length; j++) {
                            allSubTaskMember.add(messages[i].members[j]['名稱']);
                          }
                          slidableWidgets.add(SlidableItem(
                              name: messages[i].name,
                              description: messages[i].description,
                              uid: messages[i].uid,
                              members: messages[i].members,
                              deleteFunction: deleteSubTask,
                              pieChartFunction: goPieChart));
                        }
                        return Center(
                            child: Column(children: <Widget>[
                          Expanded(
                              child: ListView.builder(
                            itemCount: slidableWidgets.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  ListTile(
                                    leading:
                                        Icon(Icons.insert_drive_file_outlined),
                                    title: slidableWidgets[index],
                                  ),
                                  Divider(thickness: 2),
                                ],
                              );
                            },
                          ))
                        ]));
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.deepPurple),
                        );
                      }
                    },
                  ),
                  fourthPage,
                  pieChartPage,
                ])));
  }
}

class SlidableItem extends StatelessWidget {
  final String uid;
  final String name;
  final String description;
  final List<dynamic> members;
  final String source;
  final Function pressFunction;
  final Function deleteFunction;
  final Function pieChartFunction;
  SlidableItem(
      {this.uid,
      this.name,
      this.description,
      this.members,
      this.source,
      this.pressFunction,
      this.deleteFunction,
      this.pieChartFunction});
  @override
  Widget build(BuildContext context) {
    List<String> memberImages = [];
    for (var i = 0; i < members.length; i++) {
      memberImages.add(members[i]['照片']);
    }
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              deleteFunction(uid);
            },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(name),
              Spacer(),
              GestureDetector(
                  onTap: () {
                    source == 'mainTask'
                        ? backPageIndex = 1
                        : backPageIndex = 2;
                    pieChartFunction(source, members);
                  },
                  child: SizedBox(
                      width: 70,
                      height: 40,
                      child: FlutterImageStack(
                        imageList: memberImages,
                        showTotalCount: true,
                        totalCount: memberImages.length,
                        itemRadius: 10, // Radius of each images
                        itemCount:
                            3, // Maximum number of images to be shown in stack
                        itemBorderWidth: 1, // Border width around the images
                      ))),
            ],
          ),
          onTap: source == 'mainTask'
              ? () {
                  pressFunction(uid);
                  taskDescriptionController.text = description;
                  _pageController.animateToPage(
                    2,
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 200),
                  );
                }
              : null),
    );
  }
}
