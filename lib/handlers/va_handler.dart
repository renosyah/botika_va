import 'package:botika_va/models/anima_model.dart';
import 'package:botika_va/models/webhook_model.dart';

abstract class BotikaVaHandler {
  void onVaError(String message);
  void onVaResponse(MessageModel msg, List<DownloadVideoModel> videos);
  void onVaResponseVoice(MessageModel msg, List<String?> audios);
}
