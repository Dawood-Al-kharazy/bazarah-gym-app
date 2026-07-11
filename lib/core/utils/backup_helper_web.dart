import 'dart:convert';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';

class BackupHelper {
  static Future<void> backup(String jsonString) async {
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    html.AnchorElement(href: url)
      ..setAttribute("download", "Bazarah_Gym_Backup_${DateTime.now().millisecondsSinceEpoch}.json")
      ..click();
      
    html.Url.revokeObjectUrl(url);
  }

  static Future<String?> restore() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      withData: true, // required on web to load file bytes into memory
    );
    
    if (result != null && result.files.single.bytes != null) {
      return utf8.decode(result.files.single.bytes!);
    }
    return null;
  }
}
