import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/hero_card.dart';

class _Page {
  final IconData icon;
  final String title;
  final String body;
  const _Page(this.icon, this.title, this.body);
}

const List<_Page> _pages = [
  _Page(
    Icons.mosque,
    'ادارہ خیر العباد میں خوش آمدید',
    'قرآن پاک، نماز کے اوقات، تسبیح اور قبلہ رخ — سب کچھ ایک ہی ایپ میں۔',
  ),
  _Page(
    Icons.menu_book,
    'قرآن پاک کنز الایمان کے ترجمے کے ساتھ',
    'تمام 114 سورتیں اور 30 پارے، اردو ترجمہ کنز الایمان (امام احمد رضا خان)، نشان اور آخری پڑھائی۔',
  ),
  _Page(
    Icons.access_time_filled,
    'درست اوقات اور قبلہ',
    'کراچی طریقہ اور حنفی عصر کے مطابق اوقات، پاکستان کے شہر یا GPS، اور کمپاس والا قبلہ رخ۔',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(sharedPrefsProvider).setBool(AppConstants.kOnboardingDone, true);
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: _finish,
                child: const Text('چھوڑیں'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HeroCard(
                          padding: const EdgeInsets.all(40),
                          radius: 40,
                          child: Icon(p.icon, size: 96, color: AppColors.goldLight),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(height: 2, color: context.mutedText),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? AppColors.gold : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: last
                      ? _finish
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(last ? 'شروع کریں' : 'آگے'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
