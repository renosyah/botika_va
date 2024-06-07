import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseProvider {
  int? statusCode;
  String? errorMessage;

  Future<Map<String, dynamic>?> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? header,
  }) async {
    Map<String, dynamic>? responseBody;
    http.Response? res;

    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    if (header != null) {
      headers.addAll(header);
    }

    try {
      res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      errorMessage = "$e";
    }

    if (res == null) {
      return null;
    }

    statusCode = res.statusCode;

    try {
      String bodyString = utf8.decode(res.bodyBytes);
      responseBody = jsonDecode(bodyString.trim());
    } catch (e) {
      errorMessage = "$e";
      return null;
    }

    return responseBody;
  }
}
