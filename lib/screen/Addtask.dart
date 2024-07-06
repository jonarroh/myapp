import 'package:flutter/material.dart';
import 'package:myapp/screen/DataList.dart';
import 'package:myapp/screen/Listas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';

class Addtask extends StatefulWidget {
  final String topic;
  const Addtask({Key? key, required this.topic}) : super(key: key);

  @override
  State<Addtask> createState() => _AddtaskState();
}

class _AddtaskState extends State<Addtask> {
  late TextEditingController _taskNameController;
  late TextEditingController _taskDetailsController;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController();
    _taskDetailsController = TextEditingController();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskDetailsController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final prefs = await SharedPreferences.getInstance();
    final String? topicsString = prefs.getString('topics');
    if (topicsString != null) {
      List<Map<String, dynamic>> topics = List<Map<String, dynamic>>.from(json.decode(topicsString));
      int index = topics.indexWhere((element) => element['topic'] == widget.topic);
      if (index != -1) {
        topics[index]['data'].add({
          'taskName': _taskNameController.text,
          'taskDetails': _taskDetailsController.text,
        });
        await prefs.setString('topics', json.encode(topics));
      }
    }
    if(mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Tareaslist(topic: widget.topic)), (route) => false);
    }
  }

  void _handleNavigationChange(int index) {
    setState(() {
      if (index == 0) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Listas()),
              (route) => false,
        );
      } else if (index == 1) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Addtask(topic: widget.topic)),
              (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _taskDetailsController,
              decoration: const InputDecoration(
                labelText: 'Detalles de la Tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Agregar Tarea'),
            ),
          ],
        ),
      ),

    );
  }
}
