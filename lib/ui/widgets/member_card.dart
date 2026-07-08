import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/member_model.dart';
import '../../../providers/member_provider.dart';

class MemberCard extends StatelessWidget {
  final Member member;

  const MemberCard({Key? key, required this.member}) : super(key: key);

  Future<void> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
    bool isDanger = false,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF14181E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
        content: Text(content, style: const TextStyle(color: AppTheme.textMuted, fontFamily: 'Tajawal')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء', style: TextStyle(color: AppTheme.textMuted, fontFamily: 'Tajawal')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger ? AppTheme.danger : AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    String tempPeriod = member.periodId;
    int? renewOption;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF14181E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            title: const Text('تعديل المشترك', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الفترة', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: tempPeriod,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF14181E),
                    style: const TextStyle(color: Colors.white, fontFamily: 'Tajawal', fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.glassBorder)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    items: const [
                      DropdownMenuItem(value: '1', child: Text('الفترة الأولى')),
                      DropdownMenuItem(value: '2', child: Text('الفترة الثانية')),
                      DropdownMenuItem(value: '3', child: Text('الفترة الثالثة')),
                      DropdownMenuItem(value: '4', child: Text('الفترة الرابعة')),
                      DropdownMenuItem(value: '5', child: Text('الفترة الخامسة')),
                      DropdownMenuItem(value: '6', child: Text('الفترة السادسة')),
                    ],
                    onChanged: (val) => setState(() => tempPeriod = val!),
                  ),
                  const SizedBox(height: 20),
                  const Text('تجديد الاشتراك؟ (اختياري)', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<int?>(
                    value: renewOption,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF14181E),
                    style: const TextStyle(color: Colors.white, fontFamily: 'Tajawal', fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.glassBorder)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('بدون تجديد (تعديل الفترة فقط)')),
                      DropdownMenuItem(value: 15, child: Text('تجديد نصف شهر (15 يوم)')),
                      DropdownMenuItem(value: 30, child: Text('تجديد شهر كامل (30 يوم)')),
                    ],
                    onChanged: (val) => setState(() => renewOption = val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء', style: TextStyle(color: AppTheme.textMuted, fontFamily: 'Tajawal')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<MemberProvider>().editMember(
                    id: member.id,
                    newPeriodId: tempPeriod,
                    renewDays: renewOption,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم الحفظ بنجاح!', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.success, duration: Duration(seconds: 2)),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = DateFormatter.isExpired(member.endDate);
    final days = DateFormatter.daysLeft(member.endDate);
    
    String statusText;
    Color statusColor;
    Color statusBgColor;
    
    if (days < 0) {
      statusText = 'منتهي';
      statusColor = AppTheme.danger;
      statusBgColor = AppTheme.danger.withValues(alpha: 0.2);
    } else if (days == 0) {
      statusText = 'ينتهي اليوم';
      statusColor = AppTheme.warning;
      statusBgColor = AppTheme.warning.withValues(alpha: 0.2);
    } else {
      statusText = 'نشط';
      statusColor = AppTheme.success;
      statusBgColor = AppTheme.success.withValues(alpha: 0.2);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.glassBg,
        border: Border.all(color: AppTheme.glassBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.white,
          collapsedIconColor: AppTheme.textMuted,
          tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      'الفترة ${member.periodId} | ${member.duration == '15' ? 'نصف شهر' : 'شهر'}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'من ${DateFormatter.formatArabic(member.startDate)} إلى ${DateFormatter.formatArabic(member.endDate)}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    days < 0 ? 'انتهى الاشتراك' : (days == 0 ? 'اليوم الأخير' : 'متبقي $days يوم'),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              ),
              child: Column(
                children: [
                  if (isExpired)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.error_outline, color: AppTheme.danger, size: 16),
                          SizedBox(width: 5),
                          Text('الاشتراك منتهي، يرجى التجديد', style: TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => _showEditDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.8),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('تعديل / تجديد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              title: 'تأكيد الحذف',
                              content: 'هل أنت متأكد من رغبتك في حذف المشترك "${member.name}" بشكل نهائي؟',
                              isDanger: true,
                              onConfirm: () {
                                context.read<MemberProvider>().deleteMember(member.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم حذف المشترك', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.danger, duration: Duration(seconds: 2)),
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.danger.withValues(alpha: 0.8),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('حذف', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
