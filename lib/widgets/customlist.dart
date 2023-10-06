import 'package:flutter/material.dart';

class CustomList extends StatelessWidget {
  final List<String> datas;
  CustomList({this.datas});

  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: datas.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text('${datas[index]}'));
      },
    );
  }
}
