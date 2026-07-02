import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/editor_cubit.dart';

class EditorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("VibeCut Editor")),
      body: Column(
        children: [
          // منطقة عرض التايم لاين
          Expanded(
            child: BlocBuilder<EditorCubit, EditorState>(
              builder: (context, state) {
                final segments = context.read<EditorCubit>().currentSegments;
                return ListView.builder(
                  itemCount: segments.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text("مقطع فيديو ${index + 1}"),
                      subtitle: Text("المدة: ${segments[index].duration} ثانية"),
                    );
                  },
                );
              },
            ),
          ),
          // أزرار التحكم
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<EditorCubit>().exportVideo("/path/to/output.mp4");
              },
              child: Text("تصدير الفيديو (Export)"),
            ),
          ),
        ],
      ),
    );
  }
}