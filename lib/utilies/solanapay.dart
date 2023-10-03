class TransactionSolanaPay {
  String recipient;
  double? amount;
  List<String> references = [];
  String? label;
  String? message;
  String? memo;
  String? splToken;
  TransactionSolanaPay({
    required this.recipient,
    this.references = const [],
    this.amount,
    this.label,
    this.message,
    this.memo,
    this.splToken,
  });

  static bool validate(String uriSolanaPay) {
    Uri uri = Uri.parse(uriSolanaPay);
    var scheme = uri.scheme;
    var path = uri.path;
    print("URI: $uri Scheme: $scheme path: $path");
    // ignore: unnecessary_null_comparison
    if (uri.scheme == 'solana' && uri.path != null) {
      return true;
    }
    return false;
  }

  /// Deserialize a Solana Pay uri
  static TransactionSolanaPay parseUri(String uriSolanaPay) {
    Uri uri = Uri.parse(uriSolanaPay);
    print(uri.toString());
    String recipient = uri.path;
    Map<String, dynamic> meta = uri.queryParametersAll;

    return TransactionSolanaPay(
      recipient: recipient,
      references: meta['reference'] ?? [],
      amount: meta["amount"] != null ? double.parse(meta['amount'][0]) : 0.0,
      label: meta["label"] != null ? meta["label"][0] : null,
      message: meta["message"] != null ? meta["message"][0] : null,
      memo: meta["memo"] != null ? meta["memo"][0] : null,
      splToken: meta["spl-token"] != null ? meta["spl-token"][0] : null,
    );
  }

  /// Serialized a Solana transaction into a uri
  String toUri() {
    String baseUri = 'solana:$recipient';
    String uri = appendAttributes(baseUri);
    print(uri);
    return uri;
  }

  String toDeepLink() {
    String baseUri = "https://kitepay.herokuapp.com/";
    String uri = appendAttributes(recipient);
    print(uri);
    uri = baseUri + Uri.encodeComponent(uri);
    print(uri);
    return uri;
  }

  String appendAttributes(String uri) {
    bool addQueryDelimeter = true;

    if (amount != null) {
      uri += "?amount=${amount.toString()}";
      addQueryDelimeter = false;
    }
    for (final ref in references) {
      uri += "${addQueryDelimeter ? "?" : "&"}reference=$ref";
      addQueryDelimeter = false;
    }
    if (label != null) {
      uri += "${addQueryDelimeter ? "?" : "&"}label=$label";
      addQueryDelimeter = false;
    }
    if (message != null) {
      var messageUri = Uri.parse(message!);
      uri += "${addQueryDelimeter ? "?" : "&"}message=$messageUri";
      addQueryDelimeter = false;
    }
    if (memo != null) {
      uri += "${addQueryDelimeter ? "?" : "&"}memo=$memo";
      addQueryDelimeter = false;
    }
    if (splToken != null) {
      uri += "${addQueryDelimeter ? "?" : "&"}spl-token=$splToken";
      addQueryDelimeter = false;
    }

    return uri;
  }
}
