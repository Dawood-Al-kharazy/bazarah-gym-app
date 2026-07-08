import 'package:flutter/material.dart';
import '../data/models/member_model.dart';
import '../data/local/storage_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class MemberProvider extends ChangeNotifier {
  List<Member> _members = [];
  bool _isLoading = true;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;

  MemberProvider() {
    loadMembers();
  }

  Future<void> loadMembers() async {
    _isLoading = true;
    notifyListeners();
    _members = await StorageService.getMembers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMember(Member member) async {
    final nameExists = _members.any((m) => m.name.trim().toLowerCase() == member.name.trim().toLowerCase());
    if (nameExists) {
      throw Exception('هذا المشترك موجود مسبقاً');
    }
    _members.add(member);
    await StorageService.saveMembers(_members);
    notifyListeners();
  }

  Future<void> editMember({
    required int id,
    required String newPeriodId,
    int? renewDays,
  }) async {
    final index = _members.indexWhere((m) => m.id == id);
    if (index != -1) {
      DateTime startDate = _members[index].startDate;
      DateTime endDate = _members[index].endDate;
      String duration = _members[index].duration;

      if (renewDays != null) {
        startDate = DateTime.now();
        endDate = startDate.add(Duration(days: renewDays));
        duration = renewDays.toString();
      }

      _members[index] = _members[index].copyWith(
        periodId: newPeriodId,
        startDate: startDate,
        endDate: endDate,
        duration: duration,
      );
      await StorageService.saveMembers(_members);
      notifyListeners();
    }
  }

  Future<void> renewMember(int id, int days) async {
    final index = _members.indexWhere((m) => m.id == id);
    if (index != -1) {
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: days));
      _members[index] = _members[index].copyWith(
        startDate: startDate,
        endDate: endDate,
        duration: days.toString(),
      );
      await StorageService.saveMembers(_members);
      notifyListeners();
    }
  }

  Future<void> deleteMember(int id) async {
    _members.removeWhere((m) => m.id == id);
    await StorageService.saveMembers(_members);
    notifyListeners();
  }

  Future<void> backupData() async {
    final jsonString = await StorageService.exportDataAsJson();
    if (jsonString == null || jsonString.isEmpty) {
      throw Exception('لا توجد بيانات للنسخ الاحتياطي');
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Bazarah_Gym_Backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'نسخة احتياطية لبيانات المشتركين - جيم سكن بازرعة',
    );
  }

  Future<void> restoreData() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      
      try {
        await StorageService.importDataFromJson(jsonString);
        await loadMembers();
      } catch (e) {
        throw Exception('ملف النسخة الاحتياطية غير صالح أو تالف');
      }
    } else {
      throw Exception('تم إلغاء اختيار الملف');
    }
  }
}
