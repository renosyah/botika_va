import 'package:botika_va/handlers/va_handler.dart';
import 'package:botika_va/models/config.dart';
import 'package:botika_va/models/webhook_model.dart';
import 'package:botika_va/models/anima_model.dart';
import 'package:flutter/material.dart';
import 'package:botika_va/botika_va.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements BotikaVaHandler {
  BotikaVa botikaVa = BotikaVa();
  VaConfig vaConfig = VaConfig(
    webhookAccessToken: "YOUR_WEBHOOK_ACCESS_TOKEN",
    weebHookId: "WEBHOOK_ID",
    weebHookRecipientId: "YOUR_WEBHOOK_RECEPIENT_ID",
    weebHooksenderId: "YOUR_WEBHOOK_SENDER_ID",
    animaAccessToken: "YOUR_ANIMA_ACCESS_TOKEN",
    animaRequestId: "YOUR_ANIMA_REQUEST_ID",
    animaTemplate: "AVATAR_TEMPLATE",
    animaVoice: "YOUR_ANIMA_VOICE_ID",
    animaLanguage: "YOUR_ANIMA_VOICE_LANGUAGE",
    animaSenderId: "YOUR_ANIMA_SENDER_ID",
    downloadHeaders: const {
      "Authorization": "Bearer YOUR_ANIMA_ACCESS_TOKEN",
      "Cache-Control": "no-cache",
      "Pragma": "no-cache",
      "Accept": "*/*",
      "Accept-Encoding": "gzip, deflate, br",
      "Connection": "keep-alive",
    },
    profilingToken: "YOUR_PROFILING_TOKEN",
    profileAccessToken: "YOUR_PROFILING_ACCESS_TOKEN",
    profileBotId: "YOUR_PROFILING_BOT_ID",

    // set to false this is for internal only
    isInternal: true,

    // set to true, for response with text + audio
    // set to false, for response with text + video
    voiceOnly: true,
  );

  @override
  void initState() {
    super.initState();

    botikaVa.addSubscriber("MyController", this);
    botikaVa.init("YOUR_USER_ID", vaConfig);
  }

  @override
  void dispose() {
    super.dispose();

    botikaVa.removeSubscriber("MyController");
    botikaVa.dispose();
  }

  void send() {
    botikaVa.sendMessage("hello...");
  }

  @override
  void onVaError(String message) {
    // display error message
  }

  @override
  void onVaResponse(MessageModel msg, List<DownloadVideoModel> videos) {
    // display message get from : msg.value

    for (DownloadVideoModel r in videos) {
      // get data video by using : r.getUri()
      // header can be obtain from : vaConfig.downloadHeaders!

      r.getUri(); // uri of video
    }
  }

  @override
  void onVaResponseVoice(MessageModel msg, List<String?> audios) {
    // display message get from : msg.value

    for (String? url in audios) {
      url; // uri of audio
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
      ),
    );
  }
}
