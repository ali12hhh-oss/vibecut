import 'package:flutter/material.dart';

/// شريط أدوات سفلي بأيقونات فقط (بدون نصوص ظاهرة)، مع تلميح عند الضغط المطول
class EditorToolbar extends StatelessWidget {
  final VoidCallback onAddVideo;
  final VoidCallback onSplit;
  final VoidCallback onDelete;
  final VoidCallback onAddText;
  final VoidCallback onFilters;
  final VoidCallback onTransitions;
  final VoidCallback onExport;
  final bool hasSelection;

  const EditorToolbar({
    super.key,
    required this.onAddVideo,
    required this.onSplit,
    required this.onDelete,
    required this.onAddText,
    required this.onFilters,
    required this.onTransitions,
    required this.onExport,
    required this.hasSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.video_library, color: Colors.white),
              tooltip: 'إضافة فيديو',
              onPressed: onAddVideo,
            ),
            IconButton(
              icon: Icon(Icons.content_cut, color: hasSelection ? Colors.white : Colors.white24),
              tooltip: 'قص',
              onPressed: hasSelection ? onSplit : null,
            ),
            IconButton(
              icon: const Icon(Icons.text_fields, color: Colors.white),
              tooltip: 'نص',
              onPressed: onAddText,
            ),
            IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              tooltip: 'فلاتر',
              onPressed: onFilters,
            ),
            IconButton(
              icon: Icon(Icons.sync_alt, color: hasSelection ? Colors.white : Colors.white24),
              tooltip: 'انتقال',
              onPressed: hasSelection ? onTransitions : null,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: hasSelection ? Colors.redAccent : Colors.white24),
              tooltip: 'حذف',
              onPressed: hasSelection ? onDelete : null,
            ),
            IconButton(
              icon: const Icon(Icons.file_upload_outlined, color: Colors.white),
              tooltip: 'تصدير',
              onPressed: onExport,
            ),
          ],
        ),
      ),
    );
  }
}
