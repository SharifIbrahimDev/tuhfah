import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../data/providers/hadith_provider.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final int hadithId;
  final String? searchQuery;

  const DetailScreen({
    super.key,
    required this.hadithId,
    this.searchQuery,
  });

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _isImmersionMode = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  TextStyle _getHadithTextStyle(String family, double size, Color color) {
    switch (family) {
      case 'Scheherazade New':
        return GoogleFonts.scheherazadeNew(
          fontSize: size + 2,
          height: 1.85,
          color: color,
          fontWeight: FontWeight.w500,
        );
      case 'Noto Naskh Arabic':
        return GoogleFonts.notoNaskhArabic(
          fontSize: size,
          height: 1.85,
          color: color,
          fontWeight: FontWeight.w500,
        );
      case 'Amiri':
      default:
        return GoogleFonts.amiri(
          fontSize: size,
          height: 1.85,
          color: color,
          fontWeight: FontWeight.w500,
        );
    }
  }

  TextSpan _buildHighlightedText(
    String text,
    String? query,
    TextStyle baseStyle,
    Color highlightBg,
  ) {
    if (query == null || query.trim().isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final cleanQuery = query.trim().toLowerCase();
    final lowerText = text.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(cleanQuery, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        }
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: baseStyle));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + cleanQuery.length),
          style: baseStyle.copyWith(
            backgroundColor: highlightBg,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + cleanQuery.length;
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hadithsAsync = ref.watch(hadithListProvider);
    final favoriteIds = ref.watch(favoritesProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final currentFontFamily = ref.watch(fontFamilyProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: _isImmersionMode
          ? null
          : AppBar(
              title: Text(
                'الحديث ${widget.hadithId}',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                // Immersion Mode Toggle
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded),
                  tooltip: 'وضع القراءة المركزة',
                  onPressed: () {
                    setState(() => _isImmersionMode = true);
                  },
                ),
                // Bookmark Toggle
                IconButton(
                  icon: Icon(
                    favoriteIds.contains(widget.hadithId)
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: favoriteIds.contains(widget.hadithId)
                        ? theme.colorScheme.secondary
                        : null,
                  ),
                  tooltip: 'حفظ في المفضلة',
                  onPressed: () {
                    ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(widget.hadithId);
                  },
                ),
                // Copy & Share buttons
                hadithsAsync.when(
                  data: (hadiths) {
                    final hadith =
                        hadiths.firstWhere((h) => h.id == widget.hadithId);
                    final textToShare =
                        '${hadith.title}\n\n${hadith.narrator}\n\n${hadith.text}\n\nالمصدر: ${hadith.source}${hadith.hadithNumber.isNotEmpty ? " (${hadith.hadithNumber})" : ""}\n\n— من تطبيق تحفة الولدان';

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy_rounded),
                          tooltip: 'نسخ الحديث',
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: textToShare));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم نسخ الحديث إلى الحافظة',
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.tajawal(),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded),
                          tooltip: 'مشاركة الحديث',
                          onPressed: () {
                            Share.share(textToShare);
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (err, stack) => const SizedBox(),
                ),
              ],
            ),
      body: hadithsAsync.when(
        data: (hadiths) {
          final hadithIndex =
              hadiths.indexWhere((h) => h.id == widget.hadithId);
          if (hadithIndex == -1) {
            return const Center(child: Text('الحديث غير موجود'));
          }
          final hadith = hadiths[hadithIndex];
          final bodyColor = isDark
              ? const Color(0xFFF0FDF4)
              : const Color(0xFF1E2522);
          final baseStyle =
              _getHadithTextStyle(currentFontFamily, fontSize, bodyColor);
          final highlightBg =
              theme.colorScheme.secondary.withValues(alpha: 0.35);
          final isPart1 = hadith.id <= 40;
          final tagColor =
              isPart1 ? theme.colorScheme.primary : theme.colorScheme.secondary;

          return SafeArea(
            child: Column(
              children: [
                // Reading progress indicator line
                LinearProgressIndicator(
                  value: (hadithIndex + 1) / hadiths.length,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                  minHeight: 3,
                ),

                // Immersion mode exit bar
                if (_isImmersionMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => setState(() => _isImmersionMode = false),
                          icon: const Icon(Icons.fullscreen_exit_rounded, size: 20),
                          label: Text(
                            'إنهاء وضع التركيز',
                            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'الحديث ${hadith.id} من ${hadiths.length}',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Font size quick adjust header (shown when not in immersion mode)
                if (!_isImmersionMode)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: tagColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isPart1 ? 'الجزء الأول' : 'الجزء الثاني',
                                style: GoogleFonts.tajawal(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: tagColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'حجم الخط: ${fontSize.toInt()}',
                              style: GoogleFonts.tajawal(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                              tooltip: 'تصغير الخط',
                              onPressed: fontSize > 16
                                  ? () => ref
                                      .read(fontSizeProvider.notifier)
                                      .setFontSize(fontSize - 2)
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                              tooltip: 'تكبير الخط',
                              onPressed: fontSize < 36
                                  ? () => ref
                                      .read(fontSizeProvider.notifier)
                                      .setFontSize(fontSize + 2)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 1),

                // Main scrolling viewport
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Hadith Title Card
                        Text(
                          hadith.title,
                          textAlign: TextAlign.right,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Narrator box with gold/emerald right border
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.06),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                            border: Border(
                              right: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 4,
                              ),
                            ),
                          ),
                          width: double.infinity,
                          child: Text(
                            hadith.narrator,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Beautiful Double-Frame Calligraphy Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF13221C)
                                : const Color(0xFFF9F7F2),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.22),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? const Color(0x3F000000)
                                    : const Color(0x0C000000),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                            ),
                            child: SelectableText.rich(
                              _buildHighlightedText(
                                hadith.text,
                                widget.searchQuery,
                                baseStyle,
                                highlightBg,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Source Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  hadith.hadithNumber.isNotEmpty
                                      ? '${hadith.source} (${hadith.hadithNumber})'
                                      : hadith.source,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Explanations/Footnotes Section (If any exist)
                        if (hadith.footnotes.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'التعليقات والإيضاحات',
                                style: GoogleFonts.tajawal(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.lightbulb_outline_rounded,
                                  color: theme.colorScheme.secondary, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...hadith.footnotes.map((footnote) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1A2D25)
                                    : const Color(0xFFF3EEE3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.secondary.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              width: double.infinity,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      footnote,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 15,
                                        height: 1.65,
                                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: theme.colorScheme.secondary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),

                // Modern Floating Dock Navigation Bar
                SafeArea(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? const Color(0x3F000000)
                              : const Color(0x0C000000),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Next Hadith
                        hadithIndex < hadiths.length - 1
                            ? TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        hadithId: hadiths[hadithIndex + 1].id,
                                        searchQuery: widget.searchQuery,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chevron_left_rounded),
                                label: Text(
                                  'الحديث التالي',
                                  style: GoogleFonts.tajawal(
                                      fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              )
                            : const SizedBox.shrink(),
                        // Page indicator
                        Text(
                          '${hadithIndex + 1} / ${hadiths.length}',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                        // Previous Hadith
                        hadithIndex > 0
                            ? TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        hadithId: hadiths[hadithIndex - 1].id,
                                        searchQuery: widget.searchQuery,
                                      ),
                                    ),
                                  );
                                },
                                icon: const SizedBox.shrink(),
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'الحديث السابق',
                                      style: GoogleFonts.tajawal(
                                          fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('خطأ في تحميل البيانات: $err')),
      ),
    );
  }
}
