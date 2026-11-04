// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  final file = File('book.html');
  if (!file.existsSync()) {
    print('book.html not found!');
    return;
  }

  final fullHtml = await file.readAsString();

  // Normalize line endings
  final normalizedHtml = fullHtml.replaceAll('\r\n', '\n');

  // Extract shared CSS and head
  final headEndIndex = normalizedHtml.indexOf('</head>') + 7;
  final headHtml = normalizedHtml.substring(0, headEndIndex);

  // Common CSS enhancements for ultra-professional print layout
  final enhancedHeadHtml = headHtml.replaceFirst('</style>', '''
        @page {
            size: A4 portrait;
            margin: 20mm 15mm 20mm 15mm;
            @bottom-center {
                content: counter(page);
                font-family: 'Tajawal', sans-serif;
                font-size: 10pt;
                color: #777;
            }
        }
        @media print {
            body {
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }
            .cover-page {
                page-break-after: always;
                height: 100vh;
            }
            .hadith-card {
                page-break-inside: avoid;
                break-inside: avoid;
            }
        }
    </style>''');

  const book2SearchTerm = 'مقدمة الجزء الثاني: إبراهيم شريف أبوبكر';
  final termIndex = normalizedHtml.indexOf(book2SearchTerm);

  if (termIndex == -1) {
    print('Could not find Book 2 search term');
    return;
  }

  // Find the preceding <div class="page-break">
  final book2Index = normalizedHtml.lastIndexOf('<div class="page-break">', termIndex);

  // Content for Book 1
  final bodyTagIndex = normalizedHtml.indexOf('<body>') + 6;
  var book1Body = normalizedHtml.substring(bodyTagIndex, book2Index).trim();

  // Update Book 1 cover badge from "١ - ٢" to "١"
  book1Body = book1Body.replaceFirst(
    '<div class="badge-number">١ - ٢</div>',
    '<div class="badge-number">١</div>',
  );

  final book1Html = '''<!DOCTYPE html>
<html lang="ar" dir="rtl">
${enhancedHeadHtml.substring(enhancedHeadHtml.indexOf('<head>'))}
<body>
$book1Body
</body>
</html>''';

  await File('book1_edition.html').writeAsString(book1Html);
  print('Generated book1_edition.html');

  // Content for Book 2
  var book2Content = normalizedHtml.substring(book2Index).trim();
  // Cut closing tags from book2Content
  if (book2Content.endsWith('</body>\n</html>') || book2Content.endsWith('</body></html>')) {
    book2Content = book2Content.replaceAll('</body>', '').replaceAll('</html>', '').trim();
  }

  // Generate Book 2 Cover
  final book2Cover = '''
    <div class="cover-page">
        <div class="cover-border">
            <div class="cover-header">
                <div class="original-title">تُحْفَةُ الوِلْدَانِ</div>
                <div class="original-from">مِنْ</div>
                <div class="original-subtitle">أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ</div>
            </div>
            <div class="cover-part-badge">
                <div class="badge-label">الْجُزْءُ</div>
                <div class="badge-number">٢</div>
            </div>
            <div class="cover-people-section">
                <div class="people-col right-col">
                    <div class="people-title">تَأْلِيفُ</div>
                    <div class="people-name">إِبْرَاهِيم شَرِيف أَبُوبَكْر</div>
                </div>
                <div class="people-col left-col">
                    <div class="people-title">تَقْدِيمُ</div>
                    <div class="people-name">فَضِيلَة الشَّيْخ الحَافِظ</div>
                    <div class="people-subname">(أَبُو مُحَمَّد) مُحَمَّد أَبُوبَكْر</div>
                </div>
            </div>
            <div class="cover-reviewers-section">
                <div class="reviewers-title">مُرَاجَعَةُ أَسَانِيدِ الفَضِيلَةِ المَشَايِخِ</div>
                <div class="reviewers-names">
                    <span>إِبْرَاهِيم سُلَيْمَان إِبْرَاهِيم (بَابَاجِي)</span>
                    <span>عَبْدُاللهِ بن عُمَر</span>
                    <span>أَبُوبَكْر شَرِيف أَبُوبَكْر</span>
                </div>
            </div>
            <div class="cover-footer">
                <div class="footer-edition">الطَّبْعَةُ الأُولَى (١٤٤٥ هـ / ٢٠٢٤ م)</div>
                <div class="footer-date">مركز عبدالله بن مسعود • كدونا، نيجيريا</div>
            </div>
        </div>
    </div>
''';

  final book2Html = '''<!DOCTYPE html>
<html lang="ar" dir="rtl">
${enhancedHeadHtml.substring(enhancedHeadHtml.indexOf('<head>'))}
<body>
$book2Cover
$book2Content
</body>
</html>''';

  await File('book2_edition.html').writeAsString(book2Html);
  print('Generated book2_edition.html');

  // Combined Book (Book 1 & 2)
  final combinedHtml = '''<!DOCTYPE html>
<html lang="ar" dir="rtl">
${enhancedHeadHtml.substring(enhancedHeadHtml.indexOf('<head>'))}
<body>
${normalizedHtml.substring(bodyTagIndex)}
''';

  await File('book_combined_edition.html').writeAsString(combinedHtml);
  print('Generated book_combined_edition.html');

  print('All 3 HTML files created successfully!');
}
