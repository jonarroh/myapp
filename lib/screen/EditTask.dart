import 'package:flutter/material.dart';
import 'package:myapp/screen/Addtask.dart';
import 'package:myapp/screen/DataList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';

class Edittask extends StatefulWidget {
  final Map<String, dynamic> task;
  final String topic;

  const Edittask({Key? key, required this.task, required this.topic}) : super(key: key);

  @override
  State<Edittask> createState() => _EdittaskState();
}

class _EdittaskState extends State<Edittask> {
  late TextEditingController _taskNameController;
  late TextEditingController _taskDetailsController;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.task['taskName']);
    _taskDetailsController = TextEditingController(text: widget.task['taskDetails']);
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskDetailsController.dispose();
    super.dispose();
  }

  Future<void> _editTask() async {
    final prefs = await SharedPreferences.getInstance();
    final String? topicsString = prefs.getString('topics');
    if (topicsString != null) {
      List<Map<String, dynamic>> topics = List<Map<String, dynamic>>.from(json.decode(topicsString));
      int topicIndex = topics.indexWhere((element) => element['topic'] == widget.topic);
      if (topicIndex != -1) {
        int taskIndex = topics[topicIndex]['data'].indexWhere((element) => element['taskName'] == widget.task['taskName']);
        if (taskIndex != -1) {
          topics[topicIndex]['data'][taskIndex]['taskName'] = _taskNameController.text;
          topics[topicIndex]['data'][taskIndex]['taskDetails'] = _taskDetailsController.text;
          await prefs.setString('topics', json.encode(topics));
        }
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
          MaterialPageRoute(builder: (context) => Tareaslist(topic: widget.topic)),
              (route) => false,
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Addtask(topic: widget.topic)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarea'),
      ),
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
              onPressed: _editTask,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FluidNavBar(
        icons: [
          FluidNavBarIcon(
            icon: Icons.list,
            backgroundColor: Colors.pink,
            extras: {"label": "Ver listas"},
          ),
          FluidNavBarIcon(
            icon: Icons.add,
            backgroundColor: Colors.pink,
            extras: {"label": "Agregar"},
          ),
        ],
        onChange: _handleNavigationChange,
        style: const FluidNavBarStyle(
          barBackgroundColor: Colors.pink,
          iconSelectedForegroundColor: Colors.white,
          iconUnselectedForegroundColor: Colors.white60,
        ),
        scaleFactor: 2,
        defaultIndex: 0,
        itemBuilder: (icon, item) => Semantics(
          label: icon.extras!["label"],
          child: item,
        ),
      ),
    );
  }
}
