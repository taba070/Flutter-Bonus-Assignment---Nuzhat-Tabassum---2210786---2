import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:summer_iub_app/screens/home.dart';
import 'package:summer_iub_app/state_management/coffee_state_management.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CoffeeStateManagement(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Summer CSE464 class',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.brown,
          ),
        ),
        home: HomePage(
          pageTitle: "Welcome to CSE464!",
        ),
      ),
    );
  }
}