import 'package:flutter/material.dart';
import 'package:myapp/routes.dart';
import 'package:myapp/screen/Listas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: rutas,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, secondary: Colors.red, primary: Colors.green),
        useMaterial3: true,
      ),
      home: const Listas(),
      
    );
  }
}
