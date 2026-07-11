import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupHelper {
  static Future<void> backup(String jsonString) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Bazarah_Gym_Backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'نسخة احتياطية لبيانات المشتركين - جيم سكن بازرعة',
    );
  }

  static Future<String?> restore() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
    );
    
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      return await file.readAsString();
    }
    return null;
  }
}
