import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/controllers/editor_cubit.dart';
import 'presentation/screens/editor_screen.dart';

void main() {
  runApp(const VibeCutApp());
}

class VibeCutApp extends StatelessWidget {
  const VibeCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: BlocProvider(
        create: (context) => EditorCubit(),
        child: const EditorScreen(),
      ),
    );
  }
}
