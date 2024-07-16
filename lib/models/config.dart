enum RequestVideoType { chunk, internal, none }

enum DownloadVideoMode { chunk, video }

class VaConfig {
  // weebhook
  String? webHookAccessToken;
  String? webHookId;
  String? webHookRecipientId;
  String? webHooksenderId;

  // anima
  String? animaAccessToken;
  String? animaRequestId;
  String? animaTemplate;
  String? animaVoice;
  String? animaLanguage;
  String? animaSenderId;
  Map<String, String>? downloadHeaders;

  // profiling
  String? profilingToken;
  String? profileAccessToken;
  String? profileBotId;

  // extra shenanigans
  // dont ask me, its just work around
  bool? voiceOnly;
  bool? useSSE;

  RequestVideoType? requestVideoType;
  DownloadVideoMode? downloadVideoMode;
  bool? internalDownload;

  VaConfig({
    this.webHookAccessToken,
    this.webHookId,
    this.webHookRecipientId,
    this.webHooksenderId,
    this.animaAccessToken,
    this.animaRequestId,
    this.animaTemplate,
    this.animaVoice,
    this.animaLanguage,
    this.animaSenderId,
    this.downloadHeaders,
    this.profilingToken,
    this.profileAccessToken,
    this.profileBotId,
    this.voiceOnly = false,
    this.useSSE = true,
    this.requestVideoType = RequestVideoType.none,
    this.downloadVideoMode = DownloadVideoMode.video,
    this.internalDownload = false,
  });
}
