import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screen/AddList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Listas extends StatefulWidget {
  const Listas({super.key});

  @override
  State<Listas> createState() => _ListasState();
}

class _ListasState extends State<Listas> {
  List<Map<String, dynamic>> _topics = [];

  int _currentTab = 0;
  List<Widget> vistas = [];

  @override
  void initState() {
    super.initState();
    vistas = [buildTopicList(), const AddList()];
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final String? topicsString = prefs.getString('topics');
    if (topicsString != null) {
      setState(() {
        _topics = List<Map<String, dynamic>>.from(json.decode(topicsString));
      });
    }
  }

  void _handleNavigationChange(int index) {
    setState(() {
      _currentTab = index;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _topics.removeAt(oldIndex);
      _topics.insert(newIndex, item);
    });
    _saveTopics();
  }

  Future<void> _saveTopics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('topics', json.encode(_topics));
  }

  Widget buildTopicList() {
    return _topics.isEmpty
        ? const Center(
            child: Text(
              'La lista está vacía, agrega más tareas',
              style: TextStyle(fontSize: 18),
            ),
          )
        : ReorderableListView.builder(
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              return ListTile(
                key: ValueKey(_topics[index]['topic']),
                title: Text(_topics[index]['topic']),
              );
            },
            onReorder: _onReorder,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: vistas[_currentTab],
    );
  }
}
