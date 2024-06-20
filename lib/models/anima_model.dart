class AnimaVideoRequestModel {
  String? id;
  String? text;
  String? template;
  String? voice;
  String? language;
  bool? enhance;

  bool isInternal;

  AnimaVideoRequestModel({
    this.id,
    this.text,
    this.template,
    this.voice,
    this.language,
    this.enhance = false,
    required this.isInternal,
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

    if (isInternal) {
      data["type"] = "internal";
    }

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

  bool isInternal;
  bool downloaded = false;
  List<int>? result;

  DownloadVideoModel({
    this.senderId,
    this.chunk,
    this.returnType = "blob",
    required this.isInternal,
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

    if (isInternal) {
      data["internal"] = 'true';
    }

    return data;
  }
}

class AnimaAudioRequestModel {
  String? filetype;
  String? language;
  bool? paidPlan;
  String? returnType;
  String? text;
  String? voice;

  AnimaAudioRequestModel({
    this.filetype = "mpeg",
    this.paidPlan = false,
    this.returnType = "url",
    this.language,
    this.text,
    this.voice,
  });

  AnimaAudioRequestModel.fromJson(Map<String, dynamic> json) {
    filetype = json['filetype'];
    language = json['language'];
    paidPlan = json['paid_plan'];
    returnType = json['return'];
    text = json['text'];
    voice = json['voice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filetype'] = filetype;
    data['language'] = language;
    data['paid_plan'] = paidPlan;
    data['return'] = returnType;
    data['text'] = text;
    data['voice'] = voice;
    return data;
  }
}
