import 'dart:io';
import 'package:dio/dio.dart';

class DownloadService {
  Dio dio = Dio();

  String url;
  String downloadPath;
  ProgressCallback? onReceiveProgress;
  String? error;
  Map<String, String> downloadHeader;

  DownloadService({
    required this.url,
    required this.downloadPath,
    this.onReceiveProgress,
    required this.downloadHeader,
  });

  Future<File?> downloadFile() async {
    File? downloadedFile;

    try {
      File file = File(downloadPath);
      bool isExist = await file.exists();
      if (isExist) {
        await file.delete();
      }
    } catch (_) {}

    try {
      dio.options.headers = downloadHeader;

      await dio.download(
        url,
        downloadPath,
        onReceiveProgress: onReceiveProgress,
      );

      //
    } catch (e) {
      error = "Download Failed! Reason : $e";
    }

    downloadedFile = File(downloadPath);

    if (!await downloadedFile.exists()) {
      error = "Download Failed!";
      return null;
    }

    return downloadedFile;
  }
}
