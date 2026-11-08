import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/hero_card.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../prayer/presentation/providers/prayer_providers.dart';
import '../../domain/qibla_calculator.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(prayerLocationProvider);
    final qibla = QiblaCalculator.bearing(loc.latitude, loc.longitude);
    final km = QiblaCalculator.distanceKm(loc.latitude, loc.longitude);
    final stream = FlutterCompass.events;

    return Scaffold(
      appBar: idaraAppBar('قبلہ رخ'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HeroCard(
            child: Column(
              children: [
                Text(loc.name, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                if (stream == null)
                  _Dial(heading: 0, qibla: qibla, hasSensor: false)
                else
                  StreamBuilder<CompassEvent>(
                    stream: stream,
                    builder: (context, snap) {
                      final heading = snap.data?.heading;
                      return _Dial(
                        heading: heading ?? 0,
                        qibla: qibla,
                        hasSensor: heading != null,
                      );
                    },
                  ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '${qibla.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'خانہ کعبہ تک تقریباً ${km.round()} کلومیٹر',
                  style: const TextStyle(color: AppColors.goldLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'فون کو سیدھا (زمین کے متوازی) پکڑیں اور دھات یا مقناطیس سے دور رکھیں۔ '
            'سنہری تیر قبلے کی سمت ہے؛ جب تیر اوپر والے نشان کے سامنے آ جائے تو آپ کا رخ قبلے کی طرف ہے۔ '
            'کمپاس درست کرنے کے لیے فون کو ہوا میں “8” کی شکل میں گھمائیں۔ '
            'مقام تبدیل کرنے کے لیے نماز کے اوقات والی اسکرین میں شہر یا GPS چنیں۔',
            style: TextStyle(fontSize: 12.5, height: 2, color: context.mutedText),
          ),
        ],
      ),
    );
  }
}

class _Dial extends StatelessWidget {
  final double heading;
  final double qibla;
  final bool hasSensor;
  const _Dial({required this.heading, required this.qibla, required this.hasSensor});

  @override
  Widget build(BuildContext context) {
    final diff = ((qibla - heading + 540) % 360) - 180;
    final aligned = hasSensor && diff.abs() < 4;

    return Column(
      children: [
        SizedBox(
          width: 270,
          height: 270,
          child: CustomPaint(
            painter: _DialPainter(heading: heading, qibla: qibla, aligned: aligned),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          !hasSensor
              ? 'اس فون میں کمپاس سینسر دستیاب نہیں؛ ڈائل میں اوپر شمال (N) ہے'
              : (aligned ? 'آپ کا رخ قبلے کی طرف ہے ✓' : 'فون کو گھما کر تیر کو اوپر لائیں'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: aligned ? AppColors.goldLight : Colors.white70,
            fontWeight: aligned ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  final double heading;
  final double qibla;
  final bool aligned;
  const _DialPainter({required this.heading, required this.qibla, required this.aligned});

  void _label(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 40;

    // Dial (shumal ke hisab se ghoomta hai)
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-heading * math.pi / 180);

    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final tick = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1.5;
    for (int i = 0; i < 36; i++) {
      final a = i * math.pi / 18;
      final len = i % 9 == 0 ? 12.0 : 6.0;
      canvas.drawLine(
        Offset((r - len) * math.sin(a), -(r - len) * math.cos(a)),
        Offset(r * math.sin(a), -r * math.cos(a)),
        tick,
      );
    }
    _label(canvas, 'N', Offset(0, -r - 14));
    _label(canvas, 'E', Offset(r + 14, 0));
    _label(canvas, 'S', Offset(0, r + 14));
    _label(canvas, 'W', Offset(-r - 14, 0));

    // Qibla ka tir
    canvas.save();
    canvas.rotate(qibla * math.pi / 180);
    final arrowColor = aligned ? Colors.greenAccent : AppColors.gold;
    canvas.drawLine(
      Offset.zero,
      Offset(0, -(r - 14)),
      Paint()
        ..color = arrowColor
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    final tip = Path()
      ..moveTo(0, -(r + 4))
      ..lineTo(-11, -(r - 16))
      ..lineTo(11, -(r - 16))
      ..close();
    canvas.drawPath(tip, Paint()..color = arrowColor);
    canvas.restore();

    canvas.drawCircle(Offset.zero, 9, Paint()..color = Colors.white);
    canvas.restore();

    // Sabit nishani (phone ka rukh)
    final marker = Path()
      ..moveTo(c.dx, c.dy - r - 24)
      ..lineTo(c.dx - 9, c.dy - r - 40)
      ..lineTo(c.dx + 9, c.dy - r - 40)
      ..close();
    canvas.drawPath(marker, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.heading != heading || old.qibla != qibla || old.aligned != aligned;
}
