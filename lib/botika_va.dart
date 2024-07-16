import 'package:botika_va/handlers/va_handler.dart';
import 'package:botika_va/models/anima_model.dart';
import 'package:botika_va/models/config.dart';
import 'package:botika_va/models/webhook_model.dart';
import 'package:botika_va/providers/anima_provider.dart';
import 'package:botika_va/providers/webhook_provider.dart';
import 'package:botika_va/services/sse_service.dart';
import 'package:botika_va/utils/future_queue.dart';
import 'package:botika_va/utils/util.dart';

class BotikaVa implements SseServiceHandler {
  final SseService _sseService = SseService();
  final WebHookProvider _webHookProvider = WebHookProvider();
  final AnimaProvider _animaProvider = AnimaProvider();
  final FutureQueue<void> _taskQueue = FutureQueue<void>();

  String? _userId;
  VaConfig? _config;
  String? _uniqueId;

  String? currentMessageStop;
  String? currentMessage;

  BotikaVa() {
    _uniqueId = "$identityHashCode";
  }

  void init(String userId, VaConfig config) {
    _userId = userId;
    _config = config;

    if (_config!.useSSE!) {
      _sseService.addSseSubscriber("botika_va_$_uniqueId", this);
      _sseService.init(userId: userId, weebHookId: _config!.webHookId ?? "");
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

  void stopResponse() {
    _taskQueue.stop();
    currentMessageStop = currentMessage;
  }

  String getUserId() {
    return _userId!;
  }

  void dispose() {
    stopResponse();
    _sseService.removeSseSubscriber("botika_va_$_uniqueId");
    _sseService.dispose();
  }

  Future<void> sendMessage(String text) async {
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
    if (_config!.useSSE!) {
      return;
    }

    if (resp == null) {
      _subscribers.forEach(
         (_, value) => value.onVaError(_webHookProvider.errorMessage ?? ""),
      );
      return;
    }

    _handleResponse(idGenerator(), resp);
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

    _handleResponse(idGenerator(), msg);
  }

  void _handleResponse(String responseId, WebHookModel msg) {
    currentMessage = responseId;

    List<MessageModel> messages = msg.data!.message ?? [];
    if (messages.isEmpty) {
      return;
    }

    for (MessageModel m in messages) {
      if (_config!.voiceOnly!) {
        _taskQueue.add(
          () async => await _generateAudioResponse(
            responseId,
            msg.data!.recipientId!,
            m,
          ),
        );
      }

      //
      else {
        _taskQueue.add(
          () async => await _generateVideoResponse(
            responseId,
            msg.data!.recipientId!,
            m,
          ),
        );
      }
    }

    _taskQueue.run();
  }

  Future<void> _generateAudioResponse(
      String responseId, String userId, MessageModel msg) async {
    List<String?> generateResults = [];
    if (_config == null) {
      return;
    }

    if (_userId != userId) {
      return;
    }

    List<String> chunks = msg.getChunk();
    for (String chunk in chunks) {
      String? url = await _animaProvider.generateAudio(
        _config!,
        chunk,
      );

      if (_userId != userId) {
        return;
      }

      generateResults.add(url);
    }

    _subscribers.forEach(
      (_, value) {
        if (currentMessageStop == responseId) {
          return;
        }

        value.onVaResponseVoice(responseId, msg, generateResults);
      },
    );
  }

  Future<void> _generateVideoResponse(
      String responseId, String userId, MessageModel msg) async {
    List<DownloadVideoModel> generateResults = [];
    if (_config == null) {
      return;
    }

    if (_userId != userId) {
      return;
    }

    List<String> chunks = msg.getChunk();
    for (String chunk in chunks) {
      List<DownloadVideoModel> list = await _animaProvider.generateVideos(
        _config!,
        chunk,
      );

      if (_userId != userId) {
        return;
      }

      generateResults.addAll(list);
    }

    _subscribers.forEach(
      (_, value) {
        if (currentMessageStop == responseId) {
          return;
        }

        value.onVaResponse(responseId, msg, generateResults);
      },
    );
  }

  Future<String?> getVideoUrl(DownloadVideoModel data) async {
    if (_config == null) {
      return null;
    }

    return _animaProvider.getVideoUrl(_config!, data);
  }
}
