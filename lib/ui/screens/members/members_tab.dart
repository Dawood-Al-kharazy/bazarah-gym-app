import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/member_model.dart';
import '../../../providers/member_provider.dart';
import '../../widgets/member_card.dart';

class MembersTab extends StatefulWidget {
  final String? initialPeriodFilter;
  final String? initialDurationFilter;

  const MembersTab({
    Key? key,
    this.initialPeriodFilter,
    this.initialDurationFilter,
  }) : super(key: key);

  @override
  _MembersTabState createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  String? periodFilter;
  String? durationFilter;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    periodFilter = widget.initialPeriodFilter;
    durationFilter = widget.initialDurationFilter;
  }

  @override
  void didUpdateWidget(MembersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPeriodFilter != oldWidget.initialPeriodFilter) {
      periodFilter = widget.initialPeriodFilter;
    }
    if (widget.initialDurationFilter != oldWidget.initialDurationFilter) {
      durationFilter = widget.initialDurationFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberProvider>(
      builder: (context, provider, child) {
        List<Member> filteredMembers = provider.members;

        if (searchQuery.isNotEmpty) {
          filteredMembers = filteredMembers.where((m) => m.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
        } else {
          if (periodFilter == 'expired') {
            filteredMembers = filteredMembers.where((m) => DateFormatter.isExpired(m.endDate)).toList();
          } else if (periodFilter != null && periodFilter != 'all') {
            filteredMembers = filteredMembers.where((m) => m.periodId == periodFilter).toList();
          }
          
          if (durationFilter != null && durationFilter != 'all') {
            filteredMembers = filteredMembers.where((m) => m.duration == durationFilter).toList();
          }
        }

        filteredMembers.sort((a, b) => b.id.compareTo(a.id));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('قائمة المشتركين'),
              _buildSearchBar(),
              const SizedBox(height: 15),
              _buildFilters(),
              const SizedBox(height: 15),
              Expanded(
                child: filteredMembers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 60, color: Colors.white.withValues(alpha: 0.2)),
                            const SizedBox(height: 15),
                            const Text('لا يوجد مشتركين مطابقين للبحث.', style: TextStyle(color: AppTheme.textMuted)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, index) {
                          return MemberCard(member: filteredMembers[index]);
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
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (val) {
        setState(() {
          searchQuery = val;
        });
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'ابحث عن مشترك بالاسم...',
        hintStyle: const TextStyle(color: AppTheme.textMuted),
        prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.glassBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 65,
          child: _buildDropdown(
            value: periodFilter == 'expired' ? 'all' : (periodFilter ?? 'all'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('جميع الفترات')),
              DropdownMenuItem(value: '1', child: Text('الفترة الأولى: 5 ص – 7 ص')),
              DropdownMenuItem(value: '2', child: Text('الفترة الثانية: 7 ص – 9 ص')),
              DropdownMenuItem(value: '3', child: Text('الفترة الثالثة: 4 م – 6 م')),
              DropdownMenuItem(value: '4', child: Text('الفترة الرابعة: 6 م – 8 م')),
              DropdownMenuItem(value: '5', child: Text('الفترة الخامسة: 8 م – 10 م')),
              DropdownMenuItem(value: '6', child: Text('الفترة السادسة: 10 م – 12 ص')),
            ],
            onChanged: (val) {
              setState(() {
                periodFilter = val;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 35,
          child: _buildDropdown(
            value: durationFilter ?? 'all',
            items: const [
              DropdownMenuItem(value: 'all', child: Text('الإشتراكات')),
              DropdownMenuItem(value: '15', child: Text('نصف شهر')),
              DropdownMenuItem(value: '30', child: Text('شهر كامل')),
            ],
            onChanged: (val) {
              setState(() {
                durationFilter = val;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({required String value, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.glassBg,
        border: Border.all(color: AppTheme.glassBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF14181E),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textMuted),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Tajawal'),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
