import 'dart:convert';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

class SseService {
  final Map<String, SseServiceHandler> _subscribers =
      <String, SseServiceHandler>{};

  void addSseSubscriber(String name, SseServiceHandler handler) {
    if (hasSubscriber(name)) {
      return;
    }
    _subscribers[name] = handler;
  }

  bool hasSubscriber(String name) {
    return _subscribers.containsKey(name);
  }

  void removeSseSubscriber(String name) {
    if (!hasSubscriber(name)) {
      return;
    }
    _subscribers.remove(name);
  }

  Future<void> init({
    required String userId,
    required String weebHookId,
  }) async {
    String url =
        'https://webhook.botika.online/webhook/webhook_sse.php?id=$weebHookId&user=$userId';
    Map<String, String> header = {
      "Accept": "text/event-stream",
      "Cache-Control": "no-cache",
    };
    SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: url,
      header: header,
    ).listen(onData, onDone: onDone, onError: onError, cancelOnError: false);
  }

  void onError(error) {
    _subscribers.forEach((_, value) {
      value.onSseError(error);
    });
  }

  void onDone() {}

  void onData(SSEModel event) {
    String dataString = event.data ?? "";
    if (dataString.isEmpty) {
      return;
    }

    Map<String, dynamic>? data;

    try {
      Map<String, dynamic> json = jsonDecode(dataString);
      data = json["data"];
    } catch (_) {}

    if (data == null) return;

    _subscribers.forEach((_, value) {
      value.onSseEvent(data!);
    });
  }

  void dispose() {
    SSEClient.unsubscribeFromSSE();
  }
}

abstract class SseServiceHandler {
  void onSseEvent(Map<String, dynamic> data);
  void onSseError(error);
}
