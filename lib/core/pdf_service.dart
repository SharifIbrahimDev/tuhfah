import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../presentation/screens/pdf_viewer_screen.dart';

class PdfService {
  static const String assetPath = 'assets/data/book.pdf';

  static String getFileName(int part) {
    if (part == 1) {
      return 'تحفة_الولدان_الجزء_الأول.pdf';
    } else if (part == 2) {
      return 'تحفة_الولدان_الجزء_الثاني.pdf';
    }
    return 'تحفة_الولدان_الجزآن_الأول_والثاني.pdf';
  }

  static String getPartTitle(int part) {
    if (part == 1) {
      return 'الجزء الأول (الأحاديث ١/١ — ٤٠/١)';
    } else if (part == 2) {
      return 'الجزء الثاني (الأحاديث ١/٢ — ٤٠/٢)';
    }
    return 'الكتاب كاملاً (الجزآن الأول والثاني — ٨٠ حديثاً)';
  }

  /// Extracts the PDF bytes from the asset bundle.
  static Future<Uint8List> getPdfBytes() async {
    final byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
  }

  /// Saves the PDF to the device's Downloads or Documents directory.
  static Future<File?> savePdfToDownloads(
    BuildContext context, {
    int part = 0,
  }) async {
    try {
      final bytes = await getPdfBytes();
      final fileName = getFileName(part);
      final partTitle = getPartTitle(part);

      Directory? targetDir;

      if (!kIsWeb) {
        if (Platform.isAndroid) {
          final publicDownload = Directory('/storage/emulated/0/Download');
          if (await publicDownload.exists()) {
            targetDir = publicDownload;
          } else {
            targetDir = await getDownloadsDirectory() ??
                await getExternalStorageDirectory() ??
                await getApplicationDocumentsDirectory();
          }
        } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          targetDir = await getDownloadsDirectory() ??
              await getApplicationDocumentsDirectory();
        } else {
          targetDir = await getApplicationDocumentsDirectory();
        }
      }

      if (targetDir == null) {
        throw Exception('تعذر العثور على مجلد التنزيل');
      }

      final filePath = '${targetDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF006B3F),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تم تنزيل $partTitle بنجاح!',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        'المسار: $filePath',
                        style: GoogleFonts.tajawal(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'مشاركة',
              textColor: const Color(0xFFC5A880),
              onPressed: () {
                sharePdf(context, part: part);
              },
            ),
          ),
        );
      }

      return file;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'حدث خطأ أثناء تنزيل الكتاب: $e',
                    style: GoogleFonts.tajawal(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return null;
    }
  }

  /// Shares the PDF file via the system share sheet.
  static Future<void> sharePdf(
    BuildContext context, {
    int part = 0,
  }) async {
    try {
      final bytes = await getPdfBytes();
      final fileName = getFileName(part);
      final partTitle = getPartTitle(part);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes, flush: true);

      final xFile = XFile(
        tempFile.path,
        mimeType: 'application/pdf',
        name: fileName,
      );

      await Share.shareXFiles(
        [xFile],
        text:
            'كتاب: تُحْفَةُ الوِلْدَانِ مِنْ أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ ($partTitle)\nتأليف: إبراهيم شريف أبوبكر',
        subject: 'كتاب تُحْفَةُ الوِلْدَانِ ($partTitle) PDF',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade800,
            content: Text(
              'تعذر مشاركة الملف: $e',
              style: GoogleFonts.tajawal(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  /// Opens a modern modal bottom sheet with download & share options for Book 1, Book 2, and Complete.
  static void showDownloadModal(BuildContext context, {int initialPart = 0}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final green = const Color(0xFF006B3F);
    final gold = const Color(0xFFC5A880);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF14241B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.picture_as_pdf_rounded, color: green, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'كتاب تُحْفَةُ الوِلْدَانِ (PDF)',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'تأليف: إبراهيم شريف أبوبكر • متوفر بالجزءين الأول والثاني',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: gold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Option 1: Book 1 (الجزء الأول)
                _buildPartTile(
                  context: context,
                  title: 'الكتاب الأول: الجزء الأول',
                  subtitle: 'الأحاديث ١/١ — ٤٠/١ (نسخة PDF جاهزة للتحميل والقراءة)',
                  badgeColor: green,
                  partNumber: 1,
                  onRead: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PdfViewerScreen(initialPart: 1),
                      ),
                    );
                  },
                  onDownload: () {
                    Navigator.pop(ctx);
                    savePdfToDownloads(context, part: 1);
                  },
                  onShare: () {
                    Navigator.pop(ctx);
                    sharePdf(context, part: 1);
                  },
                ),

                const Divider(height: 16),

                // Option 2: Book 2 (الجزء الثاني)
                _buildPartTile(
                  context: context,
                  title: 'الكتاب الثاني: الجزء الثاني',
                  subtitle: 'الأحاديث ١/٢ — ٤٠/٢ (نسخة PDF جاهزة للتحميل والقراءة)',
                  badgeColor: gold,
                  partNumber: 2,
                  onRead: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PdfViewerScreen(initialPart: 2),
                      ),
                    );
                  },
                  onDownload: () {
                    Navigator.pop(ctx);
                    savePdfToDownloads(context, part: 2);
                  },
                  onShare: () {
                    Navigator.pop(ctx);
                    sharePdf(context, part: 2);
                  },
                ),

                const Divider(height: 16),

                // Option 3: Complete Book (كلا الجزأين)
                _buildPartTile(
                  context: context,
                  title: 'الكتاب كاملاً (الجزآن ١ و ٢)',
                  subtitle: 'جميع الأحاديث الثمانين مع التقاريظ والمقدمات',
                  badgeColor: const Color(0xFF00897B),
                  partNumber: 0,
                  onRead: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PdfViewerScreen(initialPart: 0),
                      ),
                    );
                  },
                  onDownload: () {
                    Navigator.pop(ctx);
                    savePdfToDownloads(context, part: 0);
                  },
                  onShare: () {
                    Navigator.pop(ctx);
                    sharePdf(context, part: 0);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildPartTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color badgeColor,
    required int partNumber,
    required VoidCallback onRead,
    required VoidCallback onDownload,
    required VoidCallback onShare,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                partNumber == 0
                    ? '٨٠ حديثاً'
                    : '٤٠ حديثاً',
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 11.5,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onShare,
              icon: const Icon(Icons.share_rounded, size: 15),
              label: Text('مشاركة', style: GoogleFonts.tajawal(fontSize: 12)),
            ),
            const SizedBox(width: 6),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onDownload,
              icon: const Icon(Icons.download_rounded, size: 15),
              label: Text('تنزيل', style: GoogleFonts.tajawal(fontSize: 12)),
            ),
            const SizedBox(width: 6),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: badgeColor,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onRead,
              icon: const Icon(Icons.menu_book_rounded, size: 15),
              label: Text(
                'قراءة',
                style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
