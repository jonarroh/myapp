import 'package:flutter/material.dart';

class Editlist extends StatefulWidget {
  final int id;
  const Editlist({super.key, required this.id});

  @override
  State<Editlist> createState() => _EditlistState();
}

class _EditlistState extends State<Editlist> {
  @override
  Widget build(BuildContext context) {
    return Text('el id es ${widget.id}');
  }
}
