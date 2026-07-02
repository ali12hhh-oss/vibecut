import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/engine_timeline.dart';
import 'core/engine_processor.dart';
import 'presentation/controllers/editor_cubit.dart';
import 'presentation/screens/editor_screen.dart';

void main() {
  runApp(const VibeCutApp());
}

class VibeCutApp extends StatelessWidget {
  const VibeCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    // نقوم بإنشاء المحركات الأساسية قبل تشغيل الواجهة
    final timeline = EngineTimeline();
    final processor = EngineProcessor(timeline);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => EditorCubit(timeline, processor),
        child: EditorScreen(),
      ),
    );
  }
}