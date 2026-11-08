import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/soft_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(height: 2, fontSize: 13, color: context.mutedText);
    return Scaffold(
      appBar: idaraAppBar('ہمارے بارے میں'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: context.cs.primary.withValues(alpha: 0.15)),
              ),
              child: Image.asset(AppConstants.logoPath, height: 160),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              AppConstants.appNameUrdu,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          Center(child: Text(AppConstants.appNameEnglish, style: muted)),
          Center(child: Text('ورژن ${AppConstants.version}', style: muted)),
          const SectionHeader('ماخذ اور شکریہ'),
          SoftCard(
            child: Text(
              'قرآنی عربی متن: Tanzil / AlQuran Cloud (alquran.cloud)\n'
              'اردو ترجمہ: کنز الایمان — امام احمد رضا خان بریلوی رحمہ اللہ\n'
              'نماز کے اوقات: adhan لائبریری (کراچی طریقہ، حنفی عصر)\n\n'
              'قرآنی متن اور ترجمہ ایپ میں ہاتھ سے نہیں لکھا گیا؛ وہ مذکورہ ماخذ سے لیا جاتا ہے۔ '
              'کسی فرق یا غلطی کی صورت میں مستند مصحف اور اہلِ علم سے رجوع کریں۔',
              style: muted,
            ),
          ),
        ],
      ),
    );
  }
}
