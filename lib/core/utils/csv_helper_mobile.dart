import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/member_model.dart';
import 'date_formatter.dart';

class CsvHelper {
  static Future<void> exportMembersCsv(BuildContext context, List<Member> members) async {
    final buffer = StringBuffer();
    // Add UTF-8 BOM so Excel opens it with Arabic encoding correctly
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

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/gym_members_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'تقرير بيانات المشتركين (Excel) - جيم سكن بازرعة',
    );
  }
}
