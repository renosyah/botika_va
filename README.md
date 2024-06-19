# Botika VA SDK Flutter

A new Flutter plugin of botika Virtual Avatar, providing component to send text and then receive response text and video 

## Installation

To integrate the plugin in your Flutter App, you need
to add this plugin to your `pubspec.yaml`

## Code

```dart
import 'package:botika_va/handlers/va_handler.dart';
import 'package:botika_va/models/config.dart';
import 'package:botika_va/models/webhook_model.dart';
import 'package:botika_va/models/anima_model.dart';

class _MyAppState extends State<MyApp> implements BotikaVaHandler {
  BotikaVa botikaVa = BotikaVa();
  VaConfig vaConfig = VaConfig(/* you can put your own config here as param */);

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

    // send message to your VA by using 
    // sendMessage() function
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

```