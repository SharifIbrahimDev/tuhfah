import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/pdf_service.dart';
import 'pdf_viewer_screen.dart';
import 'references_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1E15) : const Color(0xFFFAF7F0);
    const green = Color(0xFF006B3F);
    const gold = Color(0xFFC5A880);
    final cardBg = isDark ? const Color(0xFF16261E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E362A) : const Color(0xFFEBE3D5);
    final textColor = isDark ? const Color(0xFFECE6D9) : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? const Color(0xFF9EABA2) : const Color(0xFF5A6660);

    Widget buildInfoCard({
      required String title,
      required IconData icon,
      required Widget content,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: gold),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: gold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, size: 16, color: gold),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'عن الكتاب والناشر',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            // Book Cover Logo
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset('assets/data/logo.png', fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 14),

            // Book Title
            Text(
              'تُحْفَةُ الوِلْدَانِ',
              style: GoogleFonts.tajawal(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              'مِنْ أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ',
              style: GoogleFonts.amiri(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: gold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // PDF Download & Read Card
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
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
                          size: 26,
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
                                color: textColor,
                              ),
                            ),
                            Text(
                              'حجم الملف: ٣.٢ ميجابايت • جاهز للتحميل والطباعة',
                              style: GoogleFonts.tajawal(
                                fontSize: 11.5,
                                color: subTextColor,
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
                          side: const BorderSide(color: green),
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

            // Section 1: Overview
            buildInfoCard(
              title: 'نُبْذَةٌ عَنِ الكِتَابِ',
              icon: Icons.menu_book_rounded,
              content: Text(
                'هذا الكُتيّب يشتمل على ثمانين حديثاً من أحاديث النبي ﷺ المتعلقة بالقرآن الكريم، '
                'جمعت ورتبت وحققت مع شروحات وتعليقات ميسرة لتساعد المدرسين والطلاب في مدارس تحفيظ القرآن الكريم والدراسات الإسلامية.',
                style: GoogleFonts.amiri(
                  fontSize: 16.5,
                  color: textColor,
                  height: 1.85,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Section 2: Author
            buildInfoCard(
              title: 'تَأْلِيفُ الكِتَابِ',
              icon: Icons.edit_note_rounded,
              content: Column(
                children: [
                  Text(
                    'إبراهيم شريف أبوبكر',
                    style: GoogleFonts.amiri(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'مدير مركز عبدالله بن مسعود لتحفيظ القرآن والدراسات الإسلامية',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: subTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Section 3: Foreword / Taqdim
            buildInfoCard(
              title: 'تَقْدِيمُ الكِتَابِ وَتَقْرِيظُهُ',
              icon: Icons.verified_user_outlined,
              content: Column(
                children: [
                  Text(
                    'فضيلة الشيخ الحافظ (أبو محمد) محمد أبوبكر',
                    style: GoogleFonts.amiri(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'عميد مركز عبدالله بن مسعود ومحاضر بجامعة ولاية كدونا',
                    style: GoogleFonts.tajawal(
                      fontSize: 12.5,
                      color: subTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    child: Divider(height: 1),
                  ),
                  Text(
                    'فضيلة الشيخ إبراهيم سليمان إبراهيم (باباجي)',
                    style: GoogleFonts.amiri(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'مدير دار ابن تيمية — مندو، كدونا',
                    style: GoogleFonts.tajawal(
                      fontSize: 12.5,
                      color: subTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Section 4: Hadith Reviewers & Sanad Verification
            buildInfoCard(
              title: 'مُرَاجَعَةُ الأَسَانِيدِ وَالتَّدْقِيقُ',
              icon: Icons.fact_check_outlined,
              content: Column(
                children: [
                  Text(
                    'فضيلة الشيخ إبراهيم سليمان إبراهيم (باباجي)',
                    style: GoogleFonts.amiri(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'فضيلة الشيخ عبدالله بن عمر',
                    style: GoogleFonts.amiri(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الأستاذ أبوبكر شريف أبوبكر',
                    style: GoogleFonts.amiri(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Section 5: Publisher
            buildInfoCard(
              title: 'النَّاشِرُ',
              icon: Icons.domain_rounded,
              content: Column(
                children: [
                  Text(
                    'مركز عبدالله بن مسعود لتحفيظ القرآن الكريم والدراسات الإسلامية',
                    style: GoogleFonts.amiri(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تَمِينْ نَيْئًا — كدونا، نيجيريا',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: subTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Section: Major References
            buildInfoCard(
              title: 'أَهَمُّ مَصَادِرِ وَمَرَاجِعِ الكِتَابِ',
              icon: Icons.library_books_rounded,
              content: Column(
                children: [
                  Text(
                    'اعتمد مؤلف الكتاب في جمع الأحاديث وتخريجها وضبط رواياتها وتحرير حواشيها وتعليقاتها على أمهات كتب الحديث وشروحها المعتمدة عند أهل السنة والجماعة:',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      height: 1.6,
                      color: textColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3427) : const Color(0xFFF7F3EB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '• الصحيحان (البخاري ومسلم) والسنن الأربعة والمسند والموطأ\n'
                          '• فتح الباري لابن حجر وشرح صحيح مسلم للنووي\n'
                          '• التبيان في آداب حملة القرآن للنووي وفضائل القرآن لابن كثير\n'
                          '• جامع العلوم والحكم لابن رجب وزاد المعاد لابن القيم',
                          style: GoogleFonts.amiri(
                            fontSize: 14.5,
                            height: 1.7,
                            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF2D3748),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReferencesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                      label: Text(
                        'استعراض قائمة المراجع والمصادر كاملة',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: green,
                        side: const BorderSide(color: green, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Section 6: Edition & App Info
            buildInfoCard(
              title: 'الطَّبْعَةُ وَالتَّطْبِيقُ',
              icon: Icons.info_outline_rounded,
              content: Column(
                children: [
                  Text(
                    'الطبعة الأولى (١٤٤٥ هـ / ٢٠٢٤ م)',
                    style: GoogleFonts.amiri(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تطبيق تحفة الولدان الإلكتروني • الإصدار ١.٠.٠',
                    style: GoogleFonts.tajawal(
                      fontSize: 12.5,
                      color: subTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Section 7: Privacy Policy & Data Safety
            buildInfoCard(
              title: 'سِيَاسَةُ الخُصُوصِيَّةِ وَأَمَانُ البَيَانَاتِ',
              icon: Icons.shield_outlined,
              content: Column(
                children: [
                  Text(
                    'تطبيق «تُحْفَةُ الوِلْدَانِ» تطبيق إسلامي مجاني بالكامل وخالٍ من الإعلانات تماماً. نحن نلتزم بحماية خصوصية المستخدمين التزاماً تاماً:',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      height: 1.6,
                      color: textColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 10),
                  _PrivacyPoint(
                    icon: Icons.lock_outline_rounded,
                    title: 'عدم جمع أي بيانات شخصية',
                    desc: 'لا يجمع التطبيق ولا يشارك أي بيانات شخصية، أو موقع جغرافي، أو معلومات عن الجهاز أو المستخدم.',
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  const SizedBox(height: 8),
                  _PrivacyPoint(
                    icon: Icons.phone_android_rounded,
                    title: 'حفظ محلي كامل 100%',
                    desc: 'جميع الملاحظات، والمفضلات، وسجلات القراءة تُخزن محلياً فقط على جهازك وتُحذف تلقائياً عند حذف التطبيق.',
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  const SizedBox(height: 8),
                  _PrivacyPoint(
                    icon: Icons.notifications_none_rounded,
                    title: 'تنبيهات محلية بدون تتبع',
                    desc: 'تعمل الإشعارات اليومية عبر مجدول النظام الداخلي للجهاز مباشرة بدون خوادم خارجية.',
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static void showPrivacyPolicyDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF16261E) : Colors.white;
    final textColor = isDark ? const Color(0xFFECE6D9) : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? const Color(0xFF9EABA2) : const Color(0xFF5A6660);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'سياسة الخصوصية',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: const Color(0xFF006B3F),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.shield_outlined, color: Color(0xFF006B3F)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تطبيق «تُحْفَةُ الوِلْدَانِ» يحترم خصوصيتك بالكامل:',
                style: GoogleFonts.tajawal(fontSize: 13.5, fontWeight: FontWeight.w600, color: textColor),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              _PrivacyPoint(
                icon: Icons.lock_outline_rounded,
                title: 'لا جمع للبيانات',
                desc: 'لا يتطلب التطبيق أي تسجيل دخول ولا يجمع أي معلومات شخصية أو معرفات تتبع.',
                textColor: textColor,
                subTextColor: subTextColor,
              ),
              const SizedBox(height: 8),
              _PrivacyPoint(
                icon: Icons.storage_rounded,
                title: 'تخزين محلي آمن',
                desc: 'بيانات القراءة والمفضلات والملاحظات محفوظة على جهازك فقط.',
                textColor: textColor,
                subTextColor: subTextColor,
              ),
              const SizedBox(height: 8),
              _PrivacyPoint(
                icon: Icons.block_rounded,
                title: 'خالٍ من الإعلانات',
                desc: 'التطبيق وقف لوجه الله تعالى وخالٍ تماماً من الإعلانات والمكتبات التتبعية.',
                textColor: textColor,
                subTextColor: subTextColor,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text('حسناً', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color textColor;
  final Color subTextColor;

  const _PrivacyPoint({
    required this.icon,
    required this.title,
    required this.desc,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF006B3F).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF006B3F).withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.tajawal(
                    fontSize: 11.5,
                    height: 1.4,
                    color: subTextColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: const Color(0xFF006B3F)),
        ],
      ),
    );
  }
}
