import 'package:botika_va/utils/util.dart';
import 'package:uuid/uuid.dart';

class WebHookModel {
  String? id;
  String? time;
  WebHookDataModel? data;

  WebHookModel({
    this.id,
    this.time,
    this.data,
  });

  WebHookModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> app = json["app"];
    id = app["id"];
    time = app["time"];
    if (app["data"] != null) {
      data = WebHookDataModel.fromJson(app["data"]);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> d = <String, dynamic>{};
    Map<String, dynamic> app = <String, dynamic>{};
    d["app"] = app;

    app["id"] = id;
    app["time"] = time;

    if (data != null) {
      app["data"] = data!.toJson();
    }
    return d;
  }
}

String getTimeStamp() {
  return "${DateTime.now().millisecondsSinceEpoch}";
}

class WebHookDataModel {
  String? recipientId;
  String? senderId;
  List<MessageModel>? message;

  WebHookDataModel({
    this.recipientId,
    this.senderId,
    this.message,
  });

  WebHookDataModel.fromJson(Map<String, dynamic> json) {
    if (json["recipient"] != null) {
      recipientId = json["recipient"]["id"];
    }

    if (json["sender"] != null) {
      senderId = json["sender"]["id"];
    }

    if (json["message"] != null) {
      message = [];
      for (dynamic i in json["message"]) {
        message!.add(MessageModel.fromJson(i));
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    if (recipientId != null) {
      data["recipient"] = {
        "id": recipientId,
      };
    }

    if (senderId != null) {
      data["sender"] = {
        "id": senderId,
      };
    }

    if (message != null) {
      data["message"] = [];
      for (MessageModel i in message!) {
        data["message"].add(i.toJson());
      }
    }
    return data;
  }
}

class MessageModel {
  String? id;
  String? time;
  String? type;
  dynamic value;

  String uniqueID = "";
  String? lang;
  bool isUser = false;

  MessageModel({this.time, this.type = "text", this.value}) {
    id = "${time}981m5Qqw";
    uniqueID = const Uuid().v4();
  }

  MessageModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    time = json['time'];
    type = json['type'];
    value = json['value'];
    uniqueID = const Uuid().v4();

    if (type == "text") {
      value = removeHtmlTagFromString("$value");
      if ((value as String).contains("**id**")) {
        value = (value as String).replaceAll("**id**", "");
        lang = "id";
      } else

      //
      if ((value as String).contains("**en**")) {
        value = (value as String).replaceAll("**en**", "");
        lang = "en";
      }

      //
      else {
        lang = "id";
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data['time'] = time;
    data['type'] = type;
    data['value'] = value;

    return data;
  }

  List<String> getChunk() {
    if (type != "text") {
      return [];
    }

    return splitTextAtNearestDot(value ?? "");
  }

  List<String> splitTextAtNearestDot(String text, {int? chunkSize = 10}) {
    List<String> result = [];
    var currentChunk = [];
    var listChar = ['.', ',', ':', ';', '!', '?'];

    var words = text.split(' ');
    for (String word in words) {
      currentChunk.add(word);
      if (currentChunk.length >= chunkSize!) {
        if (containEndWith(word, listChar)) {
          result.add(currentChunk.join(' '));
          currentChunk = [];
        }
      }
    }
    if (currentChunk.isNotEmpty) {
      result.add(currentChunk.join(' '));
    }

    return result;
  }

  bool containEndWith(String word, List<String> list) {
    for (String char in list) {
      if (word.endsWith(char)) {
        return true;
      }
    }
    return false;
  }
}
