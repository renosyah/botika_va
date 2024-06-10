import 'package:botika_va/handlers/va_handler.dart';
import 'package:botika_va/models/anima_model.dart';
import 'package:botika_va/models/config.dart';
import 'package:botika_va/models/webhook_model.dart';
import 'package:botika_va/providers/anima_provider.dart';
import 'package:botika_va/providers/webhook_provider.dart';
import 'package:botika_va/services/sse_service.dart';
import 'package:botika_va/utils/async_queue.dart';
import 'package:uuid/uuid.dart';
import 'botika_va_platform_interface.dart';

class BotikaVa implements SseServiceHandler {
  Future<String?> getPlatformVersion() {
    return BotikaVaPlatform.instance.getPlatformVersion();
  }

  final SseService _sseService = SseService();
  final WebHookProvider _webHookProvider = WebHookProvider();
  final AnimaProvider _animaProvider = AnimaProvider();
  final AsyncQueue<void> _taskQueue = AsyncQueue<void>();

  String? _userId;
  VaConfig? _config;
  String? _uniqueInstanceId;

  BotikaVa() {
    _uniqueInstanceId = const Uuid().v1();
  }

  void init(String userId, VaConfig config) {
    _userId = userId;
    _config = config;

    _sseService.addSseSubscriber("botika_va_$_uniqueInstanceId", this);
    _sseService.init(userId: userId, weebHookId: _config!.weebHookId ?? "");
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
    _sseService.removeSseSubscriber("botika_va_$_uniqueInstanceId");
    _sseService.dispose();
  }

  void sendMessage(String text) async {
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

    if (_config != null) {
      WebHookModel? resp = await _webHookProvider.send(_config!, payload);
      if (resp != null) {
        _subscribers.forEach(
          (_, value) => value.onVaError(_webHookProvider.errorMessage ?? ""),
        );
      }
    }
  }

  @override
  void onSseError(error) {
    _subscribers.forEach((_, value) => value.onVaError(error));
  }

  @override
  void onSseEvent(Map<String, dynamic> data) {
    WebHookModel? msg;

    try {
      msg = WebHookModel.fromJson(data);
    } catch (_) {}
    if (msg == null) {
      return;
    }

    List<MessageModel> messages = msg.data!.message ?? [];
    if (messages.isEmpty) {
      return;
    }

    for (MessageModel msg in messages) {
      _taskQueue.add(() async => await _generateResponse(msg));
    }
  }

  Future<void> _generateResponse(MessageModel msg) async {
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
}
