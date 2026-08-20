import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/editor_cubit.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('VibeCut Pro'),
              actions: [
                IconButton(
                  tooltip: 'الإعدادات',
                  onPressed: () {},
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroCard(colorScheme: colorScheme),
                    const SizedBox(height: 20),
                    Text('أدوات مجانية ومضمنة', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    const _FeatureGrid(),
                    const SizedBox(height: 20),
                    Text('مشاريعك', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    const _EmptyProjectsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<EditorCubit>().createSampleProject();
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const EditorScreen()));
        },
        icon: const Icon(Icons.movie_creation_outlined),
        label: const Text('مشروع جديد'),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: colorScheme.onPrimaryContainer, size: 36),
          const SizedBox(height: 16),
          Text(
            'مونتاج احترافي بدون خدمات مدفوعة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'واجهة عربية، موارد محلية، تصدير FFmpeg، وفكرة جاهزة للتوسع إلى متجر إضافات مجاني ومصرّح.',
            style: TextStyle(color: colorScheme.onPrimaryContainer.withAlpha(209)),
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const List<_FeatureItem> _features = [
    _FeatureItem('قص ودمج', Icons.content_cut),
    _FeatureItem('نص عربي', Icons.text_fields),
    _FeatureItem('فلاتر LUT', Icons.filter_vintage),
    _FeatureItem('ملصقات', Icons.emoji_emotions_outlined),
    _FeatureItem('انتقالات', Icons.swap_horiz),
    _FeatureItem('تصدير محلي', Icons.file_upload_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: _features.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final feature = _features[index];
        return Card(
          child: Center(
            child: ListTile(
              leading: Icon(feature.icon),
              title: Text(feature.label),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureItem {
  const _FeatureItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _EmptyProjectsCard extends StatelessWidget {
  const _EmptyProjectsCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('لا توجد مشاريع محفوظة بعد. ابدأ مشروعًا جديدًا لتجربة محرر VibeCut.'),
      ),
    );
  }
}
