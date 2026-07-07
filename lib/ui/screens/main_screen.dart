import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/pdf_helper.dart';
import '../../providers/member_provider.dart';
import 'package:flutter/services.dart';
import 'dashboard/dashboard_tab.dart';
import 'members/members_tab.dart';
import 'members/add_member_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  String? currentPeriodFilter;
  String? currentDurationFilter;

  void _setIndex(int index) {
    FocusScope.of(context).unfocus();
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        currentPeriodFilter = null;
        currentDurationFilter = null;
      }
    });
  }

  void _navigateToFilteredMembers(String? periodId) {
    setState(() {
      currentPeriodFilter = periodId;
      currentDurationFilter = null;
      _currentIndex = 1;
    });
  }

  void _navigateToAddMember() {
    _setIndex(1);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Re-apply immersive sticky mode when keyboard closes to hide nav bar
    final bottomInset = View.of(context).viewInsets.bottom;
    if (bottomInset == 0.0) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);

    if (memberProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    final List<Widget> pages = [
      DashboardTab(onPeriodTap: _navigateToFilteredMembers),
      MembersTab(
        initialPeriodFilter: currentPeriodFilter,
        initialDurationFilter: currentDurationFilter,
      ),
      AddMemberTab(onMemberAdded: _navigateToAddMember),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.bgDark.withValues(alpha: 0.8),
                    AppTheme.bgDark.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, AppTheme.primaryColor],
                ).createShader(bounds),
                child: const Text(
                  'جيم سكن بازرعة',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                'نظام الإدارة',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF14181E).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'خيارات النظام',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final provider = Provider.of<MemberProvider>(context, listen: false);
                      final pdfBytes = await PdfHelper.generateMembersPdf(provider.members);
                      
                      await Printing.sharePdf(
                        bytes: pdfBytes,
                        filename: 'gym_members_report.pdf',
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text('تصدير التقرير كـ PDF', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم أخذ نسخة احتياطية بنجاح!', style: TextStyle(fontFamily: 'Tajawal'))),
                      );
                    },
                    icon: const Icon(Icons.backup, color: Colors.white),
                    label: const Text('نسخ احتياطي للبيانات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 15),
                  const Text(
                    'تطوير بواسطة',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Dawood Al-Kharazy',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      // Add url_launcher logic if needed later
                    },
                    child: const Text(
                      'github.com/Dawood-Al-kharazy',
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1115).withValues(alpha: 0.85),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.pie_chart, 'الرئيسية'),
                _buildNavItem(1, Icons.people, 'المشتركين'),
                _buildNavItem(2, Icons.person_add, 'إضافة'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
            size: isSelected ? 24 : 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
