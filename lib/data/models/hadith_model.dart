class HadithModel {
  final int id;
  final String title;
  final String narrator;
  final String text;
  final String source;
  final String hadithNumber;
  final List<String> footnotes;

  HadithModel({
    required this.id,
    required this.title,
    required this.narrator,
    required this.text,
    required this.source,
    required this.hadithNumber,
    required this.footnotes,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      narrator: json['narrator'] as String? ?? '',
      text: json['text'] as String? ?? '',
      source: json['source'] as String? ?? '',
      hadithNumber: json['hadith_number'] as String? ?? '',
      footnotes: json['footnotes'] != null
          ? List<String>.from(json['footnotes'] as List)
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'narrator': narrator,
      'text': text,
      'source': source,
      'hadith_number': hadithNumber,
      'footnotes': footnotes,
    };
  }
}
