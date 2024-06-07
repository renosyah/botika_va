class AnimaVideoRequestModel {
  String? id;
  String? text;
  String? template;
  String? voice;
  String? language;
  bool? enhance;

  AnimaVideoRequestModel({
    this.id,
    this.text,
    this.template,
    this.voice,
    this.language,
    this.enhance = false,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['text'] = text;
    data['template'] = template;
    data['voice'] = voice;
    data['language'] = language;
    data['enhance'] = enhance;
    data["chunk_size"] = 60;
    data["type"] = "internal";
    return data;
  }
}

class AnimaVideoResponseModel {
  String? video;
  List<String>? videoChunk;

  AnimaVideoResponseModel({
    this.video,
    this.videoChunk,
  });

  AnimaVideoResponseModel.fromJson(Map<String, dynamic> json) {
    video = json['video'];

    if (json["video_chunk"] != null) {
      videoChunk = [];
      for (dynamic i in json["video_chunk"]) {
        videoChunk!.add("$i");
      }
    }
  }
}

class DownloadVideoModel {
  String? senderId;
  String? chunk;
  String? returnType;

  bool downloaded = false;
  List<int>? result;

  DownloadVideoModel({
    this.senderId,
    this.chunk,
    this.returnType = "blob",
  });

  Uri getUri() {
    return Uri(
      scheme: "https",
      host: "anima.botika.online",
      path: "/api/public/video/download",
      queryParameters: toJson(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = senderId;
    data['chunk'] = chunk;
    data['return'] = returnType;
    data["internal"] = 'true';
    return data;
  }
}
