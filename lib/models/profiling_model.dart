class ProfilingModel {
  String? accessToken;
  String? action;
  Data? data;

  ProfilingModel({
    this.accessToken,
    this.action = "set",
    this.data,
  });

  ProfilingModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    action = json['action'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['action'] = action;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? botId;
  String? userId;
  OtherInfo? otherInfo;
  dynamic otherInfoDynamic;

  Data({
    this.botId,
    this.userId,
    this.otherInfo,
  });

  Data.fromJson(Map<String, dynamic> json) {
    botId = json['botId'];
    userId = json['userId'];
    otherInfoDynamic = json['otherInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['botId'] = botId;
    data['userId'] = userId;
    if (otherInfo != null) {
      data['otherInfo'] = otherInfo!.toJson();
    }
    return data;
  }
}

class OtherInfo {
  Coordination? coordination;

  OtherInfo({
    this.coordination,
  });

  OtherInfo.fromJson(Map<String, dynamic> json) {
    coordination = json['coordination'] != null
        ? Coordination.fromJson(json['coordination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (coordination != null) {
      data['coordination'] = coordination!.toJson();
    }
    return data;
  }
}

class Coordination {
  double? latitude;
  double? longitude;

  Coordination({this.latitude, this.longitude});

  Coordination.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
