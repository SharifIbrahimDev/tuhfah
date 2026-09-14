import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/pdf_service.dart';
import 'pdf_viewer_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1E15) : const Color(0xFFFAF7F0);
    final green = const Color(0xFF006B3F);
    final gold = const Color(0xFFC5A880);
    final textColor = isDark ? const Color(0xFFECE6D9) : const Color(0xFF1a1a1a);

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            text,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: gold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        );

    Widget sectionBody(String text, {double fontSize = 16}) => Text(
          text,
          style: GoogleFonts.amiri(
            fontSize: fontSize,
            color: textColor,
            height: 1.9,
          ),
          textAlign: TextAlign.center,
        );

    Widget divider() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: gold.withValues(alpha: 0.3), thickness: 0.8),
        );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'عن الكتاب',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold, width: 2.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset('assets/data/logo.png', fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              'تُحْفَةُ الوِلْدَانِ',
              style: GoogleFonts.tajawal(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'مِنْ أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ',
              style: GoogleFonts.amiri(fontSize: 17, color: gold),
              textAlign: TextAlign.center,
            ),

            divider(),

            // PDF Download Card
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14241B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: gold.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Color(0xFFE74C3C),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نسخة الكتاب الأصلية (PDF)',
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'حجم الملف: ٣.٢ ميجابايت • جاهز للتنزيل والطباعة',
                              style: GoogleFonts.tajawal(
                                fontSize: 11,
                                color: gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => PdfService.showDownloadModal(context),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: Text(
                            'تنزيل الكتاب',
                            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PdfViewerScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.menu_book_rounded, size: 18),
                        label: Text(
                          'قراءة',
                          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: green,
                          side: BorderSide(color: green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            divider(),

            // About
            sectionTitle('عن الكتاب'),
            sectionBody(
              'هذا الكتاب يشتمل على ثمانين حديثاً من أحاديث النبي ﷺ المتعلقة بالقرآن الكريم، '
              'مرتبةً ومحققةً مع شروحات وتعليقات مفيدة لتساعد المدرسين والطلاب.',
            ),

            divider(),

            // Author
            sectionTitle('تَأْلِيفُ'),
            sectionBody('الأستاذ إبراهيم شريف أبوبكر\nمدير مركز عبدالله بن مسعود'),

            divider(),

            // Presenter
            sectionTitle('تَقْدِيمُ'),
            sectionBody('فضيلة الشيخ الحافظ\n(أبو محمد) محمد أبوبكر'),

            divider(),

            // Reviewers
            sectionTitle('مُرَاجَعَةُ أَسَانِيدِ الفَضِيلَةِ المَشَايِخِ'),
            sectionBody(
              'إبراهيم سليمان إبراهيم (تَاتَاجِي)\nعبدالله بن عمر\nأبوبكر شريف أبوبكر',
            ),

            divider(),

            // Publisher
            sectionTitle('النَّاشِرُ'),
            sectionBody(
              'مركز عبدالله بن مسعود لتحفيظ القرآن الكريم والدراسات الإسلامية\nكدونا — نيجيريا',
            ),

            divider(),

            // Edition
            sectionTitle('الطَّبْعَةُ'),
            sectionBody('الطبعة الأولى\n١٤٤٥ هـ / ٢٠٢٤ م'),

            divider(),

            // App info
            sectionTitle('التطبيق'),
            sectionBody('النسخة ١.٠.٠', fontSize: 14),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
