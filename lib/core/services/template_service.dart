// ============================================================
// 📁 lib/core/services/template_service.dart
// 🎨 خدمة إنشاء الصور من القوالب
// ============================================================

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sehatak/core/models/template_model.dart';

class TemplateService {
  static final TemplateService _instance = TemplateService._internal();
  factory TemplateService() => _instance;
  TemplateService._internal();

  // ✅ إنشاء صورة من قالب
  Future<ui.Image> generateImageFromTemplate({
    required TemplateModel template,
    required String primaryText,
    required String secondaryText,
    required Size size,
  }) async {
    // إنشاء Recorder
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // ✅ رسم الخلفية
    await _drawBackground(canvas, template, size);

    // ✅ رسم النصوص
    _drawTexts(canvas, template, primaryText, secondaryText, size);

    // ✅ إنهاء الرسم
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());

    return image;
  }

  // ✅ رسم الخلفية
  Future<void> _drawBackground(Canvas canvas, TemplateModel template, Size size) async {
    for (final bg in template.backgroundItems) {
      try {
        // ✅ تحميل الصورة من assets
        final byteData = await rootBundle.load('assets/templates/${bg.fileName}');
        final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        final image = frame.image;

        // ✅ حساب المنطقة
        final rect = bg.marginPercentage.getRect(size);

        // ✅ رسم الصورة مع الشفافية
        final paint = Paint()..alpha = (bg.alpha * 255).toInt();
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          rect,
          paint,
        );
      } catch (e) {
        print('❌ Error drawing background: $e');
      }
    }
  }

  // ✅ رسم النصوص
  void _drawTexts(
    Canvas canvas,
    TemplateModel template,
    String primaryText,
    String secondaryText,
    Size size,
  ) {
    for (final textItem in template.textItems) {
      final isPrimary = textItem.id == 'text_primary';
      final text = isPrimary ? primaryText : secondaryText;

      // ✅ إنشاء الـ Paragraph
      final builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          fontSize: textItem.fontSize,
          fontWeight: textItem.fontWeight,
          fontStyle: textItem.fontStyleEnum,
          textAlign: _getTextAlign(textItem.textAlignment),
          maxLines: 3,
          ellipsis: '...',
        ),
      );

      // ✅ إضافة النص
      builder.pushStyle(ui.TextStyle(color: _getTextColor(isPrimary)));
      builder.addText(text);
      builder.pop();

      final paragraph = builder.build();
      final constraints = ui.ParagraphConstraints(
        width: size.width * (1 - (textItem.marginPercentage.left + textItem.marginPercentage.right) / 100),
      );
      paragraph.layout(constraints);

      // ✅ حساب الموقع
      final x = size.width * (textItem.marginPercentage.left / 100);
      final y = size.height * (textItem.marginPercentage.top / 100);

      // ✅ رسم النص
      canvas.drawParagraph(paragraph, Offset(x, y));
    }
  }

  // ✅ الحصول على TextAlign
  TextAlign _getTextAlign(String alignment) {
    switch (alignment) {
      case 'START':
        return TextAlign.start;
      case 'CENTER':
        return TextAlign.center;
      case 'END':
        return TextAlign.end;
      default:
        return TextAlign.start;
    }
  }

  // ✅ الحصول على لون النص
  Color _getTextColor(bool isPrimary) {
    return isPrimary ? Colors.white : Colors.white70;
  }

  // ✅ تحويل الصورة إلى Uint8List
  Future<Uint8List> imageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // ✅ تحويل الصورة إلى Widget
  Widget buildTemplateWidget({
    required TemplateModel template,
    required String primaryText,
    required String secondaryText,
    double width = 400,
    double height = 400,
  }) {
    return FutureBuilder<ui.Image>(
      future: generateImageFromTemplate(
        template: template,
        primaryText: primaryText,
        secondaryText: secondaryText,
        size: Size(width, height),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return RawImage(
            image: snapshot.data,
            width: width,
            height: height,
            fit: BoxFit.contain,
          );
        }
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
