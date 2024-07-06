import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screen/Addtask.dart';
import 'package:myapp/screen/EditTask.dart';
import 'package:myapp/screen/Listas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Tareaslist extends StatefulWidget {
  const Tareaslist({Key? key, required this.topic}) : super(key: key);
  final String topic;

  @override
  State<Tareaslist> createState() => _TareaslistState();
}

class _TareaslistState extends State<Tareaslist> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? topicsString = prefs.getString('topics');
    if (topicsString != null) {
      List<Map<String, dynamic>> topics = List<Map<String, dynamic>>.from(json.decode(topicsString));
      int index = topics.indexWhere((element) => element['topic'] == widget.topic);
      if (index != -1) {
        setState(() {
          _tasks = List<Map<String, dynamic>>.from(topics[index]['data']);
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _handleNavigationChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? topicsString = prefs.getString('topics');
    if (topicsString != null) {
      List<Map<String, dynamic>> topics = List<Map<String, dynamic>>.from(json.decode(topicsString));
      int index = topics.indexWhere((element) => element['topic'] == widget.topic);
      if (index != -1) {
        topics[index]['data'] = _tasks;
        await prefs.setString('topics', json.encode(topics));
      }
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, item);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            //retorna a la pantalla anterior
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Listas()), (route) => false);
              },
            ),
            const Icon(Icons.list, color: Colors.white),
            const SizedBox(width: 8,),
            Text(widget.topic, style: const TextStyle(fontSize: 24,color: Colors.white),),

          ],
        ),
        backgroundColor: Colors.pink,
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildTaskList(),
          Addtask(topic: widget.topic),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _tasks.isEmpty
        ? const Center(
      child: Text(
        'No hay tareas disponibles',
        style: TextStyle(fontSize: 18),
      ),
    )
        : ReorderableListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(_tasks[index]['taskName']),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 52),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  Text('Eliminar', style: TextStyle(color: Colors.white)),
                ],

            ),

          ),
        ),
          child: Card(
            key: ValueKey(_tasks[index]['taskName']),
            child: ListTile(
              title: Text(_tasks[index]['taskName']),
              subtitle: Text(_tasks[index]['taskDetails']),
              trailing: InkWell(
                child: const Icon(Icons.edit),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Edittask(
                        topic: widget.topic,
                        task: _tasks[index],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          confirmDismiss: (DismissDirection direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirmar"),
                  content: const Text("¿Estás seguro de que deseas eliminar esta tarea?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("ELIMINAR")),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("CANCELAR"),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            setState(() {
              _tasks.removeAt(index);
            });
            _saveTasks();
          },
        );
      },
      onReorder: _onReorder,
    );
  }
}
