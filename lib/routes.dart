//objeto con las rutas

import 'package:flutter/material.dart';
import 'package:myapp/screen/AddList.dart';
import 'package:myapp/screen/EditList.dart';
import 'package:myapp/screen/Listas.dart';
import 'package:myapp/screen/DataList.dart';

dynamic rutas = {
  '': (context) => const Listas(),
  '/Edit': (context) =>
      Editlist(topic: ModalRoute.of(context)!.settings.arguments as String),
  'Add': (context) => const AddList(),
  '/list': (context) =>
      Tareaslist(topic: ModalRoute.of(context)!.settings.arguments as String),
};