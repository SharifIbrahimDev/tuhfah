import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static const String assetPath = 'assets/data/book.pdf';
  static const String fileName = 'تحفة_الولدان_من_أحاديث_القرآن.pdf';

  /// Extracts the PDF bytes from the asset bundle.
  static Future<Uint8List> getPdfBytes() async {
    final byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
  }

  /// Saves the PDF to the device's Downloads or Documents directory.
  static Future<File?> savePdfToDownloads(BuildContext context) async {
    try {
      final bytes = await getPdfBytes();

      Directory? targetDir;

      if (!kIsWeb) {
        if (Platform.isAndroid) {
          // Attempt standard Android public Downloads directory
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
          // iOS and other platforms
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
                        'تم تنزيل الكتاب بنجاح!',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
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
                sharePdf(context);
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
  static Future<void> sharePdf(BuildContext context) async {
    try {
      final bytes = await getPdfBytes();
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
            'كتاب: تُحْفَةُ الوِلْدَانِ مِنْ أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ\nتأليف: إبراهيم شريف أبوبكر',
        subject: 'كتاب تُحْفَةُ الوِلْدَانِ PDF',
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

  /// Opens a modern modal bottom sheet with download & share options.
  static void showDownloadModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final green = const Color(0xFF006B3F);
    final gold = const Color(0xFFC5A880);

    showModalBottomSheet(
      context: context,
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
                            'كتاب تُحْفَةُ الوِلْدَانِ',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'تأليف: إبراهيم شريف أبوبكر • PDF (٣.٢ ميجابايت)',
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

                // Option 1: Direct Save
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.download_rounded, color: green),
                  ),
                  title: Text(
                    'تنزيل وحفظ في الجهاز',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'حفظ نسخة PDF في مجلد التنزيلات بالجهاز',
                    style: GoogleFonts.tajawal(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(ctx);
                    savePdfToDownloads(context);
                  },
                ),

                const SizedBox(height: 6),

                // Option 2: Share / Save to Apps
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.share_rounded, color: gold),
                  ),
                  title: Text(
                    'مشاركة أو إرسال عبر التطبيقات',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'إرسال الكتاب عبر واتساب، تيليجرام، البريد، أو حفظ في درايف',
                    style: GoogleFonts.tajawal(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(ctx);
                    sharePdf(context);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
