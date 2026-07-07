import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/member_provider.dart';

class DashboardTab extends StatelessWidget {
  final Function(String?) onPeriodTap;

  final List<Map<String, dynamic>> periodsData = [
    {"id": "1", "name": "الفترة الأولى", "time": "5:00 ص – 7:00 ص", "capacity": 30},
    {"id": "2", "name": "الفترة الثانية", "time": "7:00 ص – 9:00 ص", "capacity": 30},
    {"id": "3", "name": "الفترة الثالثة", "time": "4:00 م – 6:00 م", "capacity": 30},
    {"id": "4", "name": "الفترة الرابعة", "time": "6:00 م – 8:00 م", "capacity": 30},
    {"id": "5", "name": "الفترة الخامسة", "time": "8:00 م – 10:00 م", "capacity": 30},
    {"id": "6", "name": "الفترة السادسة", "time": "10:00 م – 12:00 ص", "capacity": 30},
  ];

  DashboardTab({Key? key, required this.onPeriodTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberProvider>(
      builder: (context, provider, child) {
        final members = provider.members;
        final expiredCount = members.where((m) => DateFormatter.isExpired(m.endDate)).length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('الفترات اليومية'),
              if (expiredCount > 0)
                _buildNotificationBanner(expiredCount, context),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 80),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: periodsData.length,
                  itemBuilder: (context, index) {
                    final period = periodsData[index];
                    final activeCount = members.where((m) => m.periodId == period['id'] && !DateFormatter.isExpired(m.endDate)).length;

                    return GestureDetector(
                      onTap: () => onPeriodTap(period['id']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.glassBg,
                          border: Border.all(color: AppTheme.glassBorder),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fitness_center, color: AppTheme.primaryColor, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              period['name'],
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              period['time'],
                              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$activeCount ',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: '/ ${period['capacity']}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 50,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBanner(int count, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.15),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'يوجد $count مشتركات منتهية.',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => onPeriodTap('expired'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('عرض المنتهية', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
