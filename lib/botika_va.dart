import 'package:botika_va/handlers/va_handler.dart';
import 'package:botika_va/models/anima_model.dart';
import 'package:botika_va/models/config.dart';
import 'package:botika_va/models/webhook_model.dart';
import 'package:botika_va/providers/anima_provider.dart';
import 'package:botika_va/providers/webhook_provider.dart';
import 'package:botika_va/services/sse_service.dart';
import 'package:botika_va/utils/async_queue.dart';

class BotikaVa implements SseServiceHandler {
  final SseService _sseService = SseService();
  final WebHookProvider _webHookProvider = WebHookProvider();
  final AnimaProvider _animaProvider = AnimaProvider();
  final AsyncQueue<void> _taskQueue = AsyncQueue<void>();

  String? _userId;
  VaConfig? _config;
  String? _uniqueId;

  BotikaVa() {
    _uniqueId = "$identityHashCode";
  }

  void init(String userId, VaConfig config) {
    _userId = userId;
    _config = config;

    if (_config!.useSSE!) {
      _sseService.addSseSubscriber("botika_va_$_uniqueId", this);
      _sseService.init(userId: userId, weebHookId: _config!.weebHookId ?? "");
    }
  }

  final Map<String, BotikaVaHandler> _subscribers = <String, BotikaVaHandler>{};

  void addSubscriber(String name, BotikaVaHandler handler) {
    if (hasSubscriber(name)) {
      return;
    }
    _subscribers[name] = handler;
  }

  bool hasSubscriber(String name) {
    return _subscribers.containsKey(name);
  }

  void removeSubscriber(String name) {
    if (!hasSubscriber(name)) {
      return;
    }
    _subscribers.remove(name);
  }

  void dispose() {
    _sseService.removeSseSubscriber("botika_va_$_uniqueId");
    _sseService.dispose();
  }

  void sendMessage(String text) async {
    if (_config == null) {
      return;
    }

    if (text.trim().isEmpty) {
      return;
    }

    WebHookModel payload = WebHookModel(
      time: getTimeStamp(),
    );
    WebHookDataModel data = WebHookDataModel(
      recipientId: null,
      senderId: _userId,
    );
    MessageModel msg = MessageModel(
      time: payload.time,
      value: text,
    );

    msg.isUser = true;

    data.message = [msg];
    payload.data = data;

    WebHookModel? resp = await _webHookProvider.send(_config!, payload);
    if (resp == null) {
      _subscribers.forEach(
        (_, value) => value.onVaError(_webHookProvider.errorMessage ?? ""),
      );
      return;
    }

    if (_config!.useSSE!) {
      return;
    }

    _handleResponse(resp);
  }

  @override
  void onSseError(error) {
    _subscribers.forEach((_, value) => value.onVaError(error));
  }

  @override
  void onSseEvent(Map<String, dynamic> data) {
    if (_config == null) {
      return;
    }

    WebHookModel? msg;

    try {
      msg = WebHookModel.fromJson(data);
    } catch (_) {}
    if (msg == null) {
      return;
    }

    _handleResponse(msg);
  }

  void _handleResponse(WebHookModel msg) {
    List<MessageModel> messages = msg.data!.message ?? [];
    if (messages.isEmpty) {
      return;
    }

    for (MessageModel msg in messages) {
      if (_config!.voiceOnly!) {
        _taskQueue.add(() async => await _generateAudioResponse(msg));
      } else {
        _taskQueue.add(() async => await _generateVideoResponse(msg));
      }
    }
  }

  Future<void> _generateAudioResponse(MessageModel msg) async {
    List<String?> generateResults = [];
    if (_config == null) {
      return;
    }
    List<String> chunks = msg.getChunk();
    for (String chunk in chunks) {
      String? url = await _animaProvider.generateAudio(
        _config!,
        chunk,
      );
      generateResults.add(url);
    }

    _subscribers.forEach(
      (_, value) => value.onVaResponseVoice(msg, generateResults),
    );
  }

  Future<void> _generateVideoResponse(MessageModel msg) async {
    List<DownloadVideoModel> generateResults = [];
    if (_config == null) {
      return;
    }

    List<String> chunks = msg.getChunk();
    for (String chunk in chunks) {
      List<DownloadVideoModel> list = await _animaProvider.generateVideos(
        _config!,
        chunk,
      );
      generateResults.addAll(list);
    }

    _subscribers.forEach(
      (_, value) => value.onVaResponse(msg, generateResults),
    );
  }

  Future<String?> getVideoUrl(DownloadVideoModel data) async {
    if (_config == null) {
      return null;
    }

    return _animaProvider.getVideoUrl(_config!, data);
  }
}
