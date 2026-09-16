import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/hadith_model.dart';

enum CardThemePreset {
  emeraldGold,
  royalSapphire,
  parchmentWhite,
}

class ShareCardDialog extends StatefulWidget {
  final HadithModel hadith;

  const ShareCardDialog({super.key, required this.hadith});

  static Future<void> show(BuildContext context, HadithModel hadith) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ShareCardDialog(hadith: hadith),
    );
  }

  @override
  State<ShareCardDialog> createState() => _ShareCardDialogState();
}

class _ShareCardDialogState extends State<ShareCardDialog> {
  final GlobalKey _cardKey = GlobalKey();
  CardThemePreset _selectedPreset = CardThemePreset.emeraldGold;
  bool _isGenerating = false;

  Future<void> _captureAndShare() async {
    setState(() => _isGenerating = true);

    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/hadith_${widget.hadith.id}_tuhfah.png');
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              '«${widget.hadith.title}»\n${widget.hadith.text}\n\nالمصدر: ${widget.hadith.source}\n— من كتاب تحفة الولدان\nتأليف: الأستاذ إبراهيم شريف أبوبكر',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء تصدير البطاقة: $e',
              textAlign: TextAlign.right,
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF13221C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header title & close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'مشاركة كبطاقة فاخرة',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance close button
                ],
              ),
              const SizedBox(height: 14),

              // Theme Selector Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildThemeOption(
                    preset: CardThemePreset.emeraldGold,
                    title: 'زمردي وذهب',
                    primaryColor: const Color(0xFF065A35),
                    accentColor: const Color(0xFFF3C766),
                  ),
                  const SizedBox(width: 8),
                  _buildThemeOption(
                    preset: CardThemePreset.royalSapphire,
                    title: 'ياقوتي ملكي',
                    primaryColor: const Color(0xFF0F2B48),
                    accentColor: const Color(0xFFE6AF2E),
                  ),
                  const SizedBox(width: 8),
                  _buildThemeOption(
                    preset: CardThemePreset.parchmentWhite,
                    title: 'مخطوطة أصيلة',
                    primaryColor: const Color(0xFFF9F7F2),
                    accentColor: const Color(0xFF065A35),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // The RepaintBoundary wrapped card preview
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: RepaintBoundary(
                  key: _cardKey,
                  child: _buildLuxuryCardContent(widget.hadith),
                ),
              ),
              const SizedBox(height: 20),

              // Share Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isGenerating ? null : _captureAndShare,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.share_rounded, size: 20),
                  label: Text(
                    _isGenerating ? 'جارٍ إنشاء البطاقة...' : 'مشاركة البطاقة كصورة',
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required CardThemePreset preset,
    required String title,
    required Color primaryColor,
    required Color accentColor,
  }) {
    final isSelected = _selectedPreset == preset;
    return GestureDetector(
      onTap: () => setState(() => _selectedPreset = preset),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 1.5),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? primaryColor : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuxuryCardContent(HadithModel hadith) {
    switch (_selectedPreset) {
      case CardThemePreset.royalSapphire:
        return _buildRoyalSapphireCard(hadith);
      case CardThemePreset.parchmentWhite:
        return _buildParchmentWhiteCard(hadith);
      case CardThemePreset.emeraldGold:
        return _buildEmeraldGoldCard(hadith);
    }
  }

  Widget _buildEmeraldGoldCard(HadithModel hadith) {
    const goldColor = Color(0xFFF3C766);
    const emeraldBg1 = Color(0xFF065A35);
    const emeraldBg2 = Color(0xFF033821);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [emeraldBg1, emeraldBg2],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App Title / Branding Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: goldColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'الحديث ${hadith.id}',
                  style: GoogleFonts.tajawal(
                    color: goldColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'تُحْفَةُ الوِلْدَانِ',
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.auto_stories_rounded, color: goldColor, size: 16),
                    ],
                  ),
                  Text(
                    'تأليف: الأستاذ إبراهيم شريف أبوبكر',
                    style: GoogleFonts.tajawal(
                      color: goldColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hadith Title
          Text(
            hadith.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: goldColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Narrator
          Text(
            hadith.narrator,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Ornamental Ornate Frame around Text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Text(
              hadith.text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                color: const Color(0xFFFFFDF8),
                fontSize: 18,
                height: 1.85,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Source and Center Signature
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تأليف: الأستاذ إبراهيم شريف أبوبكر • مركز عبدالله بن مسعود',
                style: GoogleFonts.tajawal(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hadith.hadithNumber.isNotEmpty
                      ? '${hadith.source} (${hadith.hadithNumber})'
                      : hadith.source,
                  style: GoogleFonts.tajawal(
                    color: goldColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoyalSapphireCard(HadithModel hadith) {
    const goldColor = Color(0xFFE6AF2E);
    const navyBg1 = Color(0xFF0E2540);
    const navyBg2 = Color(0xFF071424);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [navyBg1, navyBg2],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: goldColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'الحديث ${hadith.id}',
                  style: GoogleFonts.tajawal(
                    color: goldColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'تُحْفَةُ الوِلْدَانِ',
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.auto_awesome_rounded, color: goldColor, size: 16),
                    ],
                  ),
                  Text(
                    'تأليف: الأستاذ إبراهيم شريف أبوبكر',
                    style: GoogleFonts.tajawal(
                      color: goldColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            hadith.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: goldColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            hadith.narrator,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: const Color(0xFFCBD5E1),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0x35000000),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Text(
              hadith.text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                color: Colors.white,
                fontSize: 18,
                height: 1.85,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تأليف: الأستاذ إبراهيم شريف أبوبكر • مركز عبدالله بن مسعود',
                style: GoogleFonts.tajawal(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hadith.hadithNumber.isNotEmpty
                      ? '${hadith.source} (${hadith.hadithNumber})'
                      : hadith.source,
                  style: GoogleFonts.tajawal(
                    color: goldColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParchmentWhiteCard(HadithModel hadith) {
    const parchmentBg = Color(0xFFFAF7F0);
    const greenBorder = Color(0xFF065A35);
    const goldAccent = Color(0xFFB88E4F);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: parchmentBg,
        border: Border.all(color: const Color(0xFFE2D9C8), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: greenBorder.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: greenBorder.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'الحديث ${hadith.id}',
                  style: GoogleFonts.tajawal(
                    color: greenBorder,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'تُحْفَةُ الوِلْدَانِ',
                        style: GoogleFonts.tajawal(
                          color: greenBorder,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.menu_book_rounded, color: goldAccent, size: 16),
                    ],
                  ),
                  Text(
                    'تأليف: الأستاذ إبراهيم شريف أبوبكر',
                    style: GoogleFonts.tajawal(
                      color: goldAccent,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            hadith.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: greenBorder,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            hadith.narrator,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: const Color(0xFF555E59),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: goldAccent.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
            child: Text(
              hadith.text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                color: const Color(0xFF1E2522),
                fontSize: 18,
                height: 1.85,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تأليف: الأستاذ إبراهيم شريف أبوبكر • مركز عبدالله بن مسعود',
                style: GoogleFonts.tajawal(
                  color: const Color(0xFF555E59),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: greenBorder.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hadith.hadithNumber.isNotEmpty
                      ? '${hadith.source} (${hadith.hadithNumber})'
                      : hadith.source,
                  style: GoogleFonts.tajawal(
                    color: greenBorder,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
