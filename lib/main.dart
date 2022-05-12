import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:burn_up/blocs/burn_up_bloc.dart';
import 'package:burn_up/burn_up_chart.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Burn Up',
      home: BurnUpBlocProvider(child: BurnUpChart()),
    );
  }
}
