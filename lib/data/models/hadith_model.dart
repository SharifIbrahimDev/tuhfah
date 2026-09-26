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

  /// Returns 1 for Hadiths 1-40 (Book 1), and 2 for Hadiths 41-80 (Book 2)
  int get partNumber => id <= 40 ? 1 : 2;

  /// Returns 1..40 within its respective Part/Book
  int get numberInPart => id <= 40 ? id : (id - 40);

  /// Returns the formatted count e.g. "1/1" up to "40/1", and "1/2" up to "40/2"
  String get formattedNumber => '$numberInPart/$partNumber';

  /// Arabic label for the part: "الجزء الأول" or "الجزء الثاني"
  String get partLabel => id <= 40 ? 'الجزء الأول' : 'الجزء الثاني';

  /// Full Arabic display title e.g. "الحديث 1/1"
  String get fullDisplayNumber => 'الحديث $formattedNumber';

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

