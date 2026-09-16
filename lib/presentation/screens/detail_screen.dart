import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../data/models/hadith_model.dart';
import '../../data/providers/hadith_provider.dart';
import '../widgets/share_card_dialog.dart';

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

    // Auto-record as last read hadith
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lastReadProvider.notifier).setLastRead(widget.hadithId);
    });
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

  void _showNoteModal(BuildContext context, HadithModel hadith) {
    final currentNote = ref.read(hadithNotesProvider)[hadith.id]?.note ?? '';
    final textController = TextEditingController(text: currentNote);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final theme = Theme.of(modalContext);
        final isDark = theme.brightness == Brightness.dark;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13221C) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                    Text(
                      'ملاحظاتي حول الحديث ${hadith.id}',
                      style: GoogleFonts.tajawal(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (currentNote.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        tooltip: 'حذف الملاحظة',
                        onPressed: () {
                          ref.read(hadithNotesProvider.notifier).deleteNote(hadith.id);
                          Navigator.pop(modalContext);
                        },
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  hadith.title,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 5,
                  textAlign: TextAlign.right,
                  autofocus: true,
                  style: GoogleFonts.tajawal(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'سجل فوائدك وتأملاتك وملاحظاتك حول هذا الحديث...',
                    hintStyle: GoogleFonts.tajawal(fontSize: 13),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1A2D25) : const Color(0xFFF9F7F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      ref.read(hadithNotesProvider.notifier).saveNote(
                            hadith.id,
                            textController.text,
                          );
                      Navigator.pop(modalContext);
                    },
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text(
                      'حفظ الملاحظة',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hadithsAsync = ref.watch(hadithListProvider);
    final favoriteIds = ref.watch(favoritesProvider);
    final notesMap = ref.watch(hadithNotesProvider);
    final audioState = ref.watch(audioPlayerProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final currentFontFamily = ref.watch(fontFamilyProvider);
    final isDark = theme.brightness == Brightness.dark;

    final hasNote = notesMap.containsKey(widget.hadithId);

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
                // Notes Button
                hadithsAsync.when(
                  data: (hadiths) {
                    final hadith =
                        hadiths.firstWhere((h) => h.id == widget.hadithId, orElse: () => hadiths.first);
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        IconButton(
                          icon: Icon(
                            hasNote ? Icons.note_alt_rounded : Icons.note_alt_outlined,
                            color: hasNote ? theme.colorScheme.secondary : null,
                          ),
                          tooltip: hasNote ? 'تعديل ملاحظاتي' : 'إضافة ملاحظة',
                          onPressed: () => _showNoteModal(context, hadith),
                        ),
                        if (hasNote)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (error, stack) => const SizedBox(),
                ),

                // Share as Luxury Image Card
                hadithsAsync.when(
                  data: (hadiths) {
                    final hadith =
                        hadiths.firstWhere((h) => h.id == widget.hadithId, orElse: () => hadiths.first);
                    return IconButton(
                      icon: const Icon(Icons.image_outlined),
                      tooltip: 'مشاركة كبطاقة صورة',
                      onPressed: () => ShareCardDialog.show(context, hadith),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (error, stack) => const SizedBox(),
                ),

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
                        '${hadith.title}\n\n${hadith.narrator}\n\n${hadith.text}\n\nالمصدر: ${hadith.source}${hadith.hadithNumber.isNotEmpty ? " (${hadith.hadithNumber})" : ""}\n\n— من كتاب تحفة الولدان (تأليف: الأستاذ إبراهيم شريف أبوبكر)';

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
                          tooltip: 'مشاركة الحديث نصياً',
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

          final isAudioPlayingThis =
              audioState.isPlaying && audioState.currentHadithId == hadith.id;

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
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'تأليف: الأستاذ إبراهيم شريف أبوبكر',
                                style: GoogleFonts.tajawal(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
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

                // Arabic Audio Playback Bar
                _buildAudioPlayerBar(hadith, audioState, theme),

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
                              color: isAudioPlayingThis
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.primary.withValues(alpha: 0.22),
                              width: isAudioPlayingThis ? 2.0 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isAudioPlayingThis
                                    ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                                    : (isDark
                                        ? const Color(0x3F000000)
                                        : const Color(0x0C000000)),
                                blurRadius: isAudioPlayingThis ? 22 : 18,
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

                        // Source Badge & Note indicator chip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (hasNote)
                              GestureDetector(
                                onTap: () => _showNoteModal(context, hadith),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit_note_rounded,
                                          color: theme.colorScheme.secondary, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'توجد ملاحظة',
                                        style: GoogleFonts.tajawal(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
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
                                  ref.read(audioPlayerProvider.notifier).stop();
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
                                  ref.read(audioPlayerProvider.notifier).stop();
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

  Widget _buildAudioPlayerBar(
    HadithModel hadith,
    AudioPlayerState audioState,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final isCurrentPlaying =
        audioState.isPlaying && audioState.currentHadithId == hadith.id;
    final isCurrentPaused =
        audioState.isPaused && audioState.currentHadithId == hadith.id;

    String statusText;
    if (isCurrentPlaying) {
      if (audioState.repeatCount == -1) {
        statusText = 'تكرار مستمر (الدورة ${audioState.currentRepeatIndex})...';
      } else if (audioState.repeatCount > 1) {
        statusText =
            'تكرار ${audioState.currentRepeatIndex} من ${audioState.repeatCount}...';
      } else {
        statusText = 'جارٍ تلاوة الحديث صوتياً...';
      }
    } else if (isCurrentPaused) {
      statusText = 'التلاوة متوقفة مؤقتاً';
    } else {
      statusText = 'استماع للحديث الصوتي';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14291F) : const Color(0xFFEFF8F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlaying
              ? theme.colorScheme.secondary
              : theme.colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Audio Controls: Speed & Repeat Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Speed Toggle
              PopupMenuButton<double>(
                initialValue: audioState.playbackRate,
                tooltip: 'سرعة القراءة الصوتية',
                onSelected: (rate) =>
                    ref.read(audioPlayerProvider.notifier).setRate(rate),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 0.30,
                    child: Text('٠٫٣٠× بطيء جداً (للتحفيظ)',
                        textAlign: TextAlign.right),
                  ),
                  const PopupMenuItem(
                    value: 0.40,
                    child: Text('٠٫٤٠× بطيء ومرتل',
                        textAlign: TextAlign.right),
                  ),
                  const PopupMenuItem(
                    value: 0.45,
                    child: Text('٠٫٤٥× هادئ ومتأنٍ (افتراضي)',
                        textAlign: TextAlign.right),
                  ),
                  const PopupMenuItem(
                    value: 0.55,
                    child: Text('٠٫٥٥× معتدل',
                        textAlign: TextAlign.right),
                  ),
                  const PopupMenuItem(
                    value: 0.70,
                    child: Text('٠٫٧٠× سريع',
                        textAlign: TextAlign.right),
                  ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${audioState.playbackRate}x',
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Repeat Toggle
              PopupMenuButton<int>(
                initialValue: audioState.repeatCount,
                tooltip: 'تكرار التلاوة للتحفيظ',
                onSelected: (count) => ref
                    .read(audioPlayerProvider.notifier)
                    .setRepeatCount(count),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: Text('مرة واحدة (تشغيل عادي)',
                        textAlign: TextAlign.right),
                  ),
                  const PopupMenuItem(
                    value: 3,
                    child: Text('٣ مرات (تكرار للتحفيظ)',
                        textAlign: TextAlign.right),
                  ),
                  const PopupMenuItem(
                    value: 5,
                    child: Text('٥ مرات (تثبيت الحفظ)',
                        textAlign: TextAlign.right),
                  ),
                  const PopupMenuItem(
                    value: 10,
                    child: Text('١٠ مرات (إتقان تام)',
                        textAlign: TextAlign.right),
                  ),
                  const PopupMenuItem(
                    value: -1,
                    child: Text('تكرار مستمر بلا انقطاع (∞)',
                        textAlign: TextAlign.right),
                  ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: audioState.repeatCount != 1
                        ? theme.colorScheme.secondary.withValues(alpha: 0.18)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: audioState.repeatCount != 1
                        ? Border.all(
                            color: theme.colorScheme.secondary
                                .withValues(alpha: 0.5),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        audioState.repeatCount == 1
                            ? Icons.repeat_rounded
                            : (audioState.repeatCount == -1
                                ? Icons.all_inclusive_rounded
                                : Icons.repeat_one_rounded),
                        size: 13,
                        color: audioState.repeatCount != 1
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        audioState.repeatCount == 1
                            ? '١×'
                            : (audioState.repeatCount == -1
                                ? '∞'
                                : '${audioState.repeatCount}×'),
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: audioState.repeatCount != 1
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Title / Status description
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCurrentPlaying) ...[
                    Icon(Icons.graphic_eq_rounded,
                        color: theme.colorScheme.secondary, size: 16),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      statusText,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isCurrentPlaying
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentPlaying || isCurrentPaused)
                IconButton(
                  icon: const Icon(Icons.stop_rounded, size: 20),
                  tooltip: 'إيقاف',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () =>
                      ref.read(audioPlayerProvider.notifier).stop(),
                ),
              IconButton(
                icon: Icon(
                  isCurrentPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                tooltip: isCurrentPlaying ? 'إيقاف مؤقت' : 'استماع',
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () {
                  if (isCurrentPlaying) {
                    ref.read(audioPlayerProvider.notifier).pause();
                  } else {
                    ref.read(audioPlayerProvider.notifier).playHadith(hadith);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
