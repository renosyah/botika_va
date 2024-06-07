# Botika VA SDK Flutter

This is the Botika VA SDK Flutter

## Installation

To integrate the plugin in your Flutter App, you need
to add the plugin to your `pubspec.yaml` (for right now, just local ya.. hehe):

```yaml

dependencies:
  botika_va : 
    path: ./../../botika_va/

```

## Initialization

```dart

import 'package:botika_va/botika_va.dart';
import 'package:botika_va/handlers/va_handler.dart';
import 'package:botika_va/models/anima_model.dart';
import 'package:botika_va/models/config.dart';
import 'package:botika_va/models/profiling_model.dart';
import 'package:botika_va/models/webhook_model.dart';

class MyController extends GetxController implements BotikaVaHandler {

  BotikaVa botikaVa = BotikaVa();
  VaConfig vaConfig = VaConfig(
    // you can put your own config here as param
  );

  @override
  void onInit() {
    super.onInit();

    botikaVa.addSubscriber("MyController", this);
    botikaVa.init("YOUR_USER_ID", vaConfig);
  }


  @override
  void onClose() {
    super.onClose();

    botikaVa.removeSubscriber("MyController");
    botikaVa.dispose();
  }

  void onSendMessage() async {
    botikaVa.sendMessage("hay, how are you?");
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
}

```