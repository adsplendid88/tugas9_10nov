import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/device_grid_view.dart';
import 'viewmodels/device_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceViewModel(), // Inisialisasi ViewModel
      child: MaterialApp(
        title: 'Device App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const DeviceGridView(), // Atau halaman utama Anda
      ),
    );
  }
}