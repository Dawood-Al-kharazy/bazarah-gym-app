import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../data/models/member_model.dart';
import 'date_formatter.dart';

class CsvHelper {
  static Future<void> exportMembersCsv(BuildContext context, List<Member> members) async {
    final buffer = StringBuffer();
    // Add UTF-8 BOM
    buffer.write('\uFEFF');
    
    // Headers
    buffer.writeln('م,اسم المشترك,الفترة,تاريخ الانتهاء,المدة,الحالة');
    
    // Data
    for (int i = 0; i < members.length; i++) {
      final member = members[i];
      final isExpired = DateFormatter.isExpired(member.endDate);
      final status = isExpired ? 'منتهي' : 'نشط';
      final durationText = member.duration == '15' ? 'نصف شهر' : 'شهر كامل';
      final formattedDate = DateFormatter.formatNumeric(member.endDate);
      
      // Escape commas in names if any
      final safeName = member.name.contains(',') ? '"${member.name}"' : member.name;
      
      buffer.writeln('${i + 1},$safeName,الفترة ${member.periodId},$formattedDate,$durationText,$status');
    }

    final bytes = utf8.encode(buffer.toString());
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    html.AnchorElement(href: url)
      ..setAttribute("download", "gym_members_report_${DateTime.now().millisecondsSinceEpoch}.csv")
      ..click();
      
    html.Url.revokeObjectUrl(url);
  }
}
