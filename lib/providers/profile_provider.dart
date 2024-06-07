import 'dart:convert';

import 'package:botika_va/models/config.dart';
import 'package:botika_va/models/profiling_model.dart';
import 'package:botika_va/providers/base_provider.dart';

class ProfileProvider extends BaseProvider {
  Future<bool> updateProfiling(VaConfig config, ProfilingModel payload) async {
    payload.accessToken = config.profileAccessToken;

    if (payload.data != null) {
      payload.data!.botId = config.profileBotId;
    }

    String url =
        "http://api.botika.online/public/botika/user-profiling/index.php";
    Map<String, dynamic> body = payload.toJson();
    Map<String, String> header = {
      "Authorization": "Bearer ${config.profilingToken}",
    };

    Map<String, dynamic>? response = await post(
      url,
      body,
      header: header,
    );
    if (response == null) {
      return false;
    }

    return true;
  }

  Future<Map<String, dynamic>?> getTimerData(
      VaConfig config, ProfilingModel payload) async {
    Map<String, dynamic>? otherInfoDynamic;

    payload.accessToken = config.profileAccessToken;
    if (payload.data != null) {
      payload.data!.botId = config.profileBotId;
    }

    String url =
        "http://api.botika.online/public/botika/user-profiling/index.php";
    Map<String, dynamic> body = payload.toJson();
    Map<String, String> header = {
      "Authorization": "Bearer ${payload.accessToken}",
    };

    Map<String, dynamic>? response = await post(
      url,
      body,
      header: header,
    );
    if (response == null) {
      return null;
    }

    try {
      ProfilingModel data = ProfilingModel.fromJson(response);
      otherInfoDynamic = jsonDecode(
        data.data!.otherInfoDynamic,
      );
    } catch (e) {
      //
      errorMessage = "$e";
      return null;
    }

    return otherInfoDynamic;
  }
}
