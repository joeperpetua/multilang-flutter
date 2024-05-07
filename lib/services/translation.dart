class Translation {
  final String source;
  final String target;
  final String service;
  final String text;

  const Translation({
    required this.source,
    required this.target,
    required this.service,
    required this.text
  });

  Translation.fromMap(Map<String, dynamic> item):
    source = item["source"],
    target = item["target"],
    service = item["service"],
    text = item["result"];

  @override
  String toString() {
    return 'Translation{source: $source, target: $target, service: $service, text: $text}';
  }
}