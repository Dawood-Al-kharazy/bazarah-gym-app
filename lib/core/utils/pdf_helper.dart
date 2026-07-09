import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/member_model.dart';
import 'date_formatter.dart';

class PdfHelper {
  static Future<Uint8List> generateMembersPdf(List<Member> members) async {
    final pdf = pw.Document();
    
    // Load local Tajawal font
    final fontData = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: ttf),
        build: (context) => [
          _buildHeader(ttf),
          pw.SizedBox(height: 20),
          _buildTable(members, ttf),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Font ttf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text('جيم سكن بازرعة - نظام الإدارة', style: pw.TextStyle(font: ttf, fontSize: 24, color: PdfColors.redAccent)),
        pw.SizedBox(height: 5),
        pw.Text('تقرير بيانات المشتركين', style: pw.TextStyle(font: ttf, fontSize: 18, color: PdfColors.grey700)),
        pw.SizedBox(height: 10),
        pw.Text('تاريخ الطباعة: ${DateFormatter.formatArabic(DateTime.now())}', style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.grey600)),
        pw.Divider(color: PdfColors.grey400),
      ],
    );
  }

  static pw.Widget _buildTable(List<Member> members, pw.Font ttf) {
    return pw.TableHelper.fromTextArray(
      context: null,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.redAccent),
      headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, font: ttf),
      cellStyle: pw.TextStyle(font: ttf, fontSize: 12),
      cellAlignment: pw.Alignment.center,
      headers: ['م', 'اسم المشترك', 'الفترة', 'تاريخ الانتهاء', 'المدة', 'الحالة'].reversed.toList(),
      data: members.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final member = entry.value;
        final isExpired = DateFormatter.isExpired(member.endDate);
        final status = isExpired ? 'منتهي' : 'نشط';
        final durationText = member.duration == '15' ? 'نصف شهر' : 'شهر كامل';
        
        return [
          index.toString(),
          member.name,
          'الفترة ${member.periodId}',
          DateFormatter.formatArabic(member.endDate),
          durationText,
          status,
        ].reversed.toList();
      }).toList(),
    );
  }
}
