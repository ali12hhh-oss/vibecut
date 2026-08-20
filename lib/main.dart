import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_initializer.dart';
import 'core/engine_processor.dart';
import 'core/engine_timeline.dart';
import 'presentation/controllers/editor_cubit.dart';
import 'presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initAll();
  runApp(const VibeCutApp());
}

class VibeCutApp extends StatelessWidget {
  const VibeCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    final timeline = EngineTimeline();
    final processor = EngineProcessor(timeline);

    return BlocProvider(
      create: (_) => EditorCubit(timeline, processor),
      child: MaterialApp(
        title: 'VibeCut Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF7C4DFF),
          fontFamily: 'Tajawal',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
