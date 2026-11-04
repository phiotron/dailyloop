import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Cổng tới bảng chia sẻ và trình chọn file của hệ điều hành (Android + iOS).
/// App không xin quyền bộ nhớ (AC-42). Test dùng [FakeFileGateway].
abstract class FileGateway {
  /// Ghi file tạm rồi mở bảng chia sẻ. [origin] là vùng nút bấm, iPad cần để
  /// neo bảng chia sẻ.
  Future<void> share(
    String name,
    String content,
    String mimeType, {
    Rect? origin,
  });

  /// Mở trình chọn file, trả về nội dung chữ UTF-8; null nếu người dùng hủy.
  /// Ném [FormatException] nếu file không phải UTF-8.
  Future<String?> pickText();
}

class PluginFileGateway implements FileGateway {
  const PluginFileGateway();

  @override
  Future<void> share(
    String name,
    String content,
    String mimeType, {
    Rect? origin,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsString(content, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        sharePositionOrigin: origin,
      ),
    );
  }

  @override
  Future<String?> pickText() async {
    final picked = await FilePicker.pickFile();
    if (picked == null) return null;
    return utf8.decode(await picked.readAsBytes());
  }
}

/// Bản giả cho test: ghi lại file đã chia sẻ, trả về nội dung đặt sẵn.
class FakeFileGateway implements FileGateway {
  final shared = <({String name, String content, String mimeType})>[];

  /// Nội dung "người dùng chọn"; null là hủy. [pickError] giả lập file không đọc được.
  String? toPick;
  bool pickError = false;

  @override
  Future<void> share(
    String name,
    String content,
    String mimeType, {
    Rect? origin,
  }) async {
    shared.add((name: name, content: content, mimeType: mimeType));
  }

  @override
  Future<String?> pickText() async {
    if (pickError) throw const FormatException('không đọc được file');
    return toPick;
  }
}
