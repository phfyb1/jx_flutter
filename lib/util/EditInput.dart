// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, camel_case_types, prefer_typing_uninitialized_variables, unnecessary_import, file_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
var height;
var width;
class editInput extends StatelessWidget {
  final String hintText;
  // final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const editInput({
    Key? key, 
    required this.hintText,
    // required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // height = MediaQuery.of(context).size.height;
    height=664;
    // width = MediaQuery.of(context).size.width;
    width=1034;
    return Container(
    height: height * 0.1,
    width: width * 0.5,
    child: TextField(
      decoration: InputDecoration(
        fillColor: Color(0x30cccccc),
        filled: true,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x00FF0000)),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x00000000)),
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      // controller: controller,
      onChanged: onChanged,
    ),
  );
  }
}