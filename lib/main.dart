import 'package:burn_up/blocs/burn_up_bloc.dart';
import 'package:burn_up/burn_up_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

Future<void> main() async {
  await Settings.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Burn Up',
      home: BurnUpBlocProvider(child: BurnUpChart()),
    );
  }
}
