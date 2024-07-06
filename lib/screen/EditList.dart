import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screen/Listas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Editlist extends StatefulWidget {
  final String topic;
  const Editlist({super.key, required this.topic});

  @override
  State<Editlist> createState() => _EditlistState();
}

class _EditlistState extends State<Editlist> {
  late TextEditingController _topicController;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.topic);
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> topics = List<Map<String, dynamic>>.from(json.decode(prefs.getString('topics')!));

    int index = topics.indexWhere((element) => element['topic'] == widget.topic);
    if (index != -1) {
      setState(() {
        topics[index]['topic'] = _topicController.text;
        prefs.setString('topics', json.encode(topics));
      });
    }

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => const Listas()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.topic}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Tópico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
