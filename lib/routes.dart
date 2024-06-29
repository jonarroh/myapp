//objeto con las rutas

import 'package:flutter/material.dart';
import 'package:myapp/screen/AddList.dart';
import 'package:myapp/screen/EditList.dart';
import 'package:myapp/screen/Listas.dart';

dynamic rutas = {
  '': (context) => const Listas(),
  'Edit': (context) =>
      Editlist(id: ModalRoute.of(context)!.settings.arguments as int),
  'Add': (context) => const AddList()
};
