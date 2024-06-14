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
  VaConfig vaConfig = VaConfig();

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
