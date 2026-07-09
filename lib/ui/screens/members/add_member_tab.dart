import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/member_model.dart';
import '../../../providers/member_provider.dart';

class AddMemberTab extends StatefulWidget {
  final VoidCallback onMemberAdded;

  const AddMemberTab({Key? key, required this.onMemberAdded}) : super(key: key);

  @override
  _AddMemberTabState createState() => _AddMemberTabState();
}

class _AddMemberTabState extends State<AddMemberTab> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String periodId = '1';
  String duration = '30';
  DateTime selectedStartDate = DateTime.now();

  Future<void> _selectStartDate(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Color(0xFF14181E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF14181E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('إضافة مشترك جديد'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 75),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppTheme.glassBg,
                  border: Border.all(color: AppTheme.glassBorder),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('الاسم الرباعي'),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(hint: 'أدخل اسم المشترك', icon: Icons.person_outline),
                        validator: (val) => val == null || val.isEmpty ? 'يرجى إدخال الاسم' : null,
                        onSaved: (val) => name = val!,
                      ),
                      const SizedBox(height: 12),
                      
                      _buildLabel('الفترة المحددة'),
                      DropdownButtonFormField<String>(
                        value: periodId,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF14181E),
                        style: const TextStyle(color: Colors.white, fontFamily: 'Tajawal', fontSize: 13),
                        decoration: _inputDecoration(icon: Icons.access_time),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text('الفترة الأولى: 5:00 ص – 7:00 ص')),
                          DropdownMenuItem(value: '2', child: Text('الفترة الثانية: 7:00 ص – 9:00 ص')),
                          DropdownMenuItem(value: '3', child: Text('الفترة الثالثة: 4:00 م – 6:00 م')),
                          DropdownMenuItem(value: '4', child: Text('الفترة الرابعة: 6:00 م – 8:00 م')),
                          DropdownMenuItem(value: '5', child: Text('الفترة الخامسة: 8:00 م – 10:00 م')),
                          DropdownMenuItem(value: '6', child: Text('الفترة السادسة: 10:00 م – 12:00 ص')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            periodId = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('تاريخ بدء الاشتراك'),
                      InkWell(
                        onTap: () => _selectStartDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.glassBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.date_range, color: AppTheme.textMuted),
                              const SizedBox(width: 10),
                              Text(
                                '${selectedStartDate.year}-${selectedStartDate.month.toString().padLeft(2, '0')}-${selectedStartDate.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('مدة الاشتراك'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDurationOption('30', 'شهر كامل (30 يوم)'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDurationOption('15', 'نصف شهر (15 يوم)'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final endDate = selectedStartDate.add(Duration(days: int.parse(duration)));
                            
                            final member = Member(
                              id: DateTime.now().millisecondsSinceEpoch,
                              name: name,
                              periodId: periodId,
                              duration: duration,
                              startDate: selectedStartDate,
                              endDate: endDate,
                            );
                            
                            try {
                              FocusManager.instance.primaryFocus?.unfocus();
                              await context.read<MemberProvider>().addMember(member);
                              
                              _formKey.currentState!.reset();
                              setState(() {
                                periodId = '1';
                                duration = '30';
                                selectedStartDate = DateTime.now();
                              });
                              
                              AppTheme.showCustomSnackBar(context, 'تمت إضافة المشترك بنجاح!');
                            } catch (e) {
                              AppTheme.showCustomSnackBar(context, e.toString().replaceAll('Exception: ', ''), isError: true);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          shadowColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.person_add_alt_1, color: Colors.white),
                            SizedBox(width: 10),
                            Text('تسجيل وحفظ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 14, color: const Color(0xFFDDDDDD))),
    );
  }

  InputDecoration _inputDecoration({String? hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textMuted),
      prefixIcon: Icon(icon, color: AppTheme.textMuted),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildDurationOption(String value, String label) {
    final isSelected = duration == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          duration = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.glassBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
