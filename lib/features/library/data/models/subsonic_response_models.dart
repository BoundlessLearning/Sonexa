typedef JsonMap = Map<String, dynamic>;
typedef SubsonicResponseMap = Map<String, dynamic>;

extension SubsonicResponseModelsX on Map<String, dynamic> {
  JsonMap? get subsonicResponseBody {
    final response = this['subsonic-response'];
    if (response is JsonMap) {
      return response;
    }

    if (response is Map) {
      return response.cast<String, dynamic>();
    }

    return null;
  }

  JsonMap? get subsonicErrorBody {
    final response = subsonicResponseBody;
    final error = response?['error'];

    if (error is JsonMap) {
      return error;
    }

    if (error is Map) {
      return error.cast<String, dynamic>();
    }

    return null;
  }

  String? get subsonicStatus => subsonicResponseBody?['status'] as String?;

  JsonMap? payloadFor(String key) {
    final payload = subsonicResponseBody?[key];

    if (payload is JsonMap) {
      return payload;
    }

    if (payload is Map) {
      return payload.cast<String, dynamic>();
    }

    return null;
  }
}
