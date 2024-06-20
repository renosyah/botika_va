class VaConfig {
  // weebhook
  String? webhookAccessToken;
  String? weebHookId;
  String? weebHookRecipientId;
  String? weebHooksenderId;

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

  bool? isInternal;
  bool? voiceOnly;

  VaConfig({
    this.webhookAccessToken,
    this.weebHookId,
    this.weebHookRecipientId,
    this.weebHooksenderId,
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
    this.isInternal = false,
    this.voiceOnly = false,
  });
}
