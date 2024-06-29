import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddList extends StatefulWidget {
  const AddList({super.key});

  @override
  State<AddList> createState() => _AddListState();
}

class _AddListState extends State<AddList> {
  final _controller = TextEditingController();

  Future<void> _addTopic() async {
    if (_controller.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El campo no puede estar vacío')),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? topicsString = prefs.getString('topics');
    if (topicsString == null) {
      await prefs.setString('topics', '[]');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('No hay tareas guardadas, agregando primera tarea')),
        );
      }
    }

    List<Map<String, dynamic>> topics = topicsString != null
        ? List<Map<String, dynamic>>.from(json.decode(topicsString))
        : [];

    final newTopic = {
      'topic': _controller.text,
      'data': [],
    };

    topics.add(newTopic);

    await prefs.setString('topics', json.encode(topics));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar una nueva tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Escribe algo'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTopic,
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }
}
