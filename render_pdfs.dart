// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  final edgePath = r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe';
  final chromePath = r'C:\Program Files\Google\Chrome\Application\chrome.exe';

  String browserPath = '';
  if (File(edgePath).existsSync()) {
    browserPath = edgePath;
  } else if (File(chromePath).existsSync()) {
    browserPath = chromePath;
  } else {
    print('No suitable headless browser found!');
    return;
  }

  print('Using browser for PDF printing: $browserPath');

  final currentDir = Directory.current.path;
  final outputDir = Directory('$currentDir\\pdf_editions');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final targets = [
    {
      'html': 'book1_edition.html',
      'pdf': 'pdf_editions\\تُحْفَةُ_الوِلْدَانِ_الجزء_الأول_Book_1.pdf',
    },
    {
      'html': 'book2_edition.html',
      'pdf': 'pdf_editions\\تُحْفَةُ_الوِلْدَانِ_الجزء_الثاني_Book_2.pdf',
    },
    {
      'html': 'book3_edition.html',
      'pdf': 'pdf_editions\\تُحْفَةُ_الوِلْدَانِ_الجزء_الثالث_Book_3.pdf',
    },
    {
      'html': 'book_combined_edition.html',
      'pdf': 'pdf_editions\\تُحْفَةُ_الوِلْدَانِ_الأجزاء_الثلاثة_المجمعة_Complete_1_to_3.pdf',
    },
  ];

  for (final target in targets) {
    final htmlPath = '$currentDir\\${target['html']}';
    final pdfPath = '$currentDir\\${target['pdf']}';

    print('Building PDF: ${target['pdf']} ...');

    final args = [
      '--headless=new',
      '--disable-gpu',
      '--no-pdf-header-footer',
      '--print-to-pdf=$pdfPath',
      htmlPath,
    ];

    final result = await Process.run(browserPath, args);
    if (result.exitCode == 0 && File(pdfPath).existsSync()) {
      final sizeMb = (File(pdfPath).lengthSync() / (1024 * 1024)).toStringAsFixed(2);
      print('SUCCESS: Created ${target['pdf']} ($sizeMb MB)');
      if (target['html'] == 'book3_edition.html') {
        File(pdfPath).copySync('$currentDir\\assets\\data\\book3.pdf');
        print('SUCCESS: Copied to assets\\data\\book3.pdf');
      } else if (target['html'] == 'book_combined_edition.html') {
        File(pdfPath).copySync('$currentDir\\assets\\data\\book_combined.pdf');
        File(pdfPath).copySync('$currentDir\\assets\\data\\book.pdf');
        print('SUCCESS: Copied to assets\\data\\book_combined.pdf & book.pdf');
      }
    } else {
      print('FAILED for ${target['pdf']}: ${result.stderr}');
    }
  }

  print('All PDF files have been built and saved to pdf_editions folder!');
}
