class Language {
  final String name;
  final String native;
  final String code;
  bool selected;

  Language({
    required this.name,
    required this.native,
    required this.code,
    this.selected = false
  });
}