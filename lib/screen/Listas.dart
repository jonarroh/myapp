import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screen/AddList.dart';
import 'package:myapp/screen/EditList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:myapp/screen/DataList.dart';

class Listas extends StatefulWidget {
  const Listas({super.key});

  @override
  State<Listas> createState() => _ListasState();
}

class _ListasState extends State<Listas> {
  List<Map<String, dynamic>> _topics = [];
  bool _isLoading = true; // Indicador de carga

  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final String? topicsString = prefs.getString('topics');
    print('Cargando datos de SharedPreferences: $topicsString'); // Depuración
    if (topicsString == null) {
      await _setInitialTopics();
    } else {
      setState(() {
        _topics = List<Map<String, dynamic>>.from(json.decode(topicsString));
        _isLoading = false; // Datos cargados, dejar de cargar
        print('Datos cargados en la lista: $_topics'); // Depuración
      });
    }
  }

  Future<void> _setInitialTopics() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> initialTopics = [
      {
        'topic': 'Tarea 1',
        'data': [
          {
            'taskName': 'Tarea 1',
            'taskDetails': 'Detalles de la tarea 1',
          },
          {
            'taskName': 'Tarea 2',
            'taskDetails': 'Detalles de la tarea 2',
          }
        ],
      },
      {
        'topic': 'Tarea 2',
        'data': [],
      },
    ];
    await prefs.setString('topics', json.encode(initialTopics));
    setState(() {
      _topics = initialTopics;
      _isLoading = false; // Datos iniciales establecidos, dejar de cargar
    });
    print('Tareas iniciales configuradas: $initialTopics'); // Depuración
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
    print('Datos guardados en SharedPreferences: $_topics'); // Depuración
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
        return Dismissible(
          key: Key(_topics[index]['topic']),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,

              children: <Widget>[
                Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                Text(
                  'Eliminar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(width: 52),
              ],

            ),
          ),
          child: Card(
            key: ValueKey(_topics[index]['topic']),
            child: ListTile(
              title: Text(_topics[index]['topic']),
              subtitle:
              Text('${_topics[index]['data'].length} tareas pendientes'),
              trailing: InkWell(
                child: const Icon(Icons.edit),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Editlist(
                        topic: _topics[index]['topic'],
                      ),
                    ),
                        (route) => false);
                },
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Tareaslist(
                      topic: _topics[index]['topic'],
                    ),
                  ),
                      (route) => false,

                );
              },
            ),
          ),
          confirmDismiss: (DismissDirection direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirmar"),
                  content: const Text("¿Estás seguro de que deseas eliminar este elemento?"),
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
              _topics.removeAt(index);
            });
            _saveTopics();
          },
        );
      },
      onReorder: _onReorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Agregar una nueva tarea', style: TextStyle(color: Colors.white)),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Indicador de carga
          : (_currentTab == 0 ? buildTopicList() : const AddList()),
    );
  }
}
