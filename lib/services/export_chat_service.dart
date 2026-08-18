import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportChatService {
  static final ExportChatService _instance = ExportChatService._internal();
  factory ExportChatService() => _instance;
  ExportChatService._internal();

  // ============================================================
  // 📤 تصدير كـ PDF
  // ============================================================

  Future<String> exportAsPDF(List<Map<String, dynamic>> messages) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '📋 محادثة المساعد الصحي',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'التاريخ: ${DateTime.now().toString()}',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              ...messages.map((msg) {
                final isUser = msg['isUser'] as bool;
                final text = msg['text'] as String;
                final time = msg['timestamp'] as DateTime;
                
                return pw.Column(
                  crossAxisAlignment: isUser 
                      ? pw.CrossAxisAlignment.end 
                      : pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: isUser ? PdfColors.blue : PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Text(
                        text,
                        style: pw.TextStyle(
                          color: isUser ? PdfColors.white : PdfColors.black,
                        ),
                      ),
                    ),
                    pw.Text(
                      _formatTime(time),
                      style: pw.TextStyle(
                        fontSize: 10, 
                        color: PdfColors.grey500,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      );
      
      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/chat_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);
      
      return file.path;
    } catch (e) {
      print('❌ PDF export error: $e');
      return '';
    }
  }

  // ============================================================
  // 📤 تصدير كـ Text
  // ============================================================

  Future<String> exportAsText(List<Map<String, dynamic>> messages) async {
    try {
      String text = '📋 محادثة المساعد الصحي\n';
      text += 'التاريخ: ${DateTime.now()}\n';
      text += '═' * 40 + '\n\n';
      
      for (var msg in messages) {
        final isUser = msg['isUser'] as bool;
        final textMsg = msg['text'] as String;
        final time = msg['timestamp'] as DateTime;
        
        text += '${isUser ? '👤 أنت' : '🤖 المساعد'} (${_formatTime(time)}):\n';
        text += '$textMsg\n\n';
      }
      
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/chat_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(text);
      
      return file.path;
    } catch (e) {
      print('❌ Text export error: $e');
      return '';
    }
  }

  // ============================================================
  // 📤 تصدير كـ JSON
  // ============================================================

  Future<String> exportAsJSON(List<Map<String, dynamic>> messages) async {
    try {
      final jsonData = messages.map((msg) {
        return {
          'text': msg['text'],
          'isUser': msg['isUser'],
          'timestamp': (msg['timestamp'] as DateTime).toIso8601String(),
          'type': msg['type'] ?? 'general',
        };
      }).toList();
      
      final json = jsonEncode(jsonData);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/chat_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(json);
      
      return file.path;
    } catch (e) {
      print('❌ JSON export error: $e');
      return '';
    }
  }

  // ============================================================
  // 📤 مشاركة المحادثة
  // ============================================================

  Future<void> shareChat(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)], text: '📋 محادثة المساعد الصحي');
    } catch (e) {
      print('❌ Share error: $e');
    }
  }

  // ============================================================
  // 🛠️ مساعدات
  // ============================================================

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
