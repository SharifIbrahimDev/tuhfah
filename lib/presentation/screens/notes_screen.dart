import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/providers/hadith_provider.dart';
import 'detail_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditNoteDialog(BuildContext context, int hadithId, String hadithTitle, String currentNote) {
    final textController = TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            'تعديل الملاحظة • الحديث $hadithId',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hadithTitle,
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 4,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'اكتب ملاحظتك أو فائدتك حول هذا الحديث...',
                  hintStyle: GoogleFonts.tajawal(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('إلغاء', style: GoogleFonts.tajawal()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ref.read(hadithNotesProvider.notifier).saveNote(hadithId, textController.text);
                Navigator.pop(dialogContext);
              },
              child: Text('حفظ', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteNote(BuildContext context, int hadithId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'حذف الملاحظة',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف هذه الملاحظة؟',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('إلغاء', style: GoogleFonts.tajawal()),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                ref.read(hadithNotesProvider.notifier).deleteNote(hadithId);
                Navigator.pop(dialogContext);
              },
              child: Text('حذف', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notesMap = ref.watch(hadithNotesProvider);
    final hadithsAsync = ref.watch(hadithListProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ملاحظاتي وتأملاتي',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: hadithsAsync.when(
        data: (allHadiths) {
          final hadithsWithNotes = allHadiths.where((h) => notesMap.containsKey(h.id)).toList();

          final filteredHadiths = hadithsWithNotes.where((h) {
            if (_searchQuery.isEmpty) return true;
            final note = notesMap[h.id]?.note ?? '';
            final query = _searchQuery.toLowerCase();
            return note.toLowerCase().contains(query) ||
                h.title.toLowerCase().contains(query) ||
                h.text.toLowerCase().contains(query);
          }).toList();

          if (hadithsWithNotes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'لا توجد ملاحظات مسجلة بعد',
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يمكنك تدوين الفوائد والشروح والخواطر التربوية أثناء تصفح أي حديث من خلال زر "الملاحظات".',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Search in notes
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.tajawal(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'ابحث في ملاحظاتك وعناوين الأحاديث...',
                    hintStyle: GoogleFonts.tajawal(fontSize: 13),
                    prefixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    suffixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF15261F) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),
              ),

              // Notes List
              Expanded(
                child: filteredHadiths.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد ملاحظات مطابقة لبحثك',
                          style: GoogleFonts.tajawal(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredHadiths.length,
                        itemBuilder: (context, index) {
                          final hadith = filteredHadiths[index];
                          final noteItem = notesMap[hadith.id];
                          if (noteItem == null) return const SizedBox.shrink();

                          final dateStr =
                              '${noteItem.updatedAt.year}/${noteItem.updatedAt.month.toString().padLeft(2, '0')}/${noteItem.updatedAt.day.toString().padLeft(2, '0')}';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF14241D) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? const Color(0xFF1E3A2E) : const Color(0xFFE8E2D5),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Header Row: Hadith ID, Title, and Actions
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18),
                                            tooltip: 'تعديل الملاحظة',
                                            onPressed: () => _showEditNoteDialog(
                                              context,
                                              hadith.id,
                                              hadith.title,
                                              noteItem.note,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded,
                                                color: Colors.redAccent, size: 18),
                                            tooltip: 'حذف الملاحظة',
                                            onPressed: () =>
                                                _confirmDeleteNote(context, hadith.id),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                hadith.title,
                                                textAlign: TextAlign.right,
                                                style: GoogleFonts.tajawal(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '#${hadith.id}',
                                                style: TextStyle(
                                                  color: theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Note Content Card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF192C23)
                                          : const Color(0xFFF9F7F2),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border(
                                        right: BorderSide(
                                          color: theme.colorScheme.secondary,
                                          width: 3.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      noteItem.note,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 14,
                                        height: 1.6,
                                        color: isDark ? Colors.white : const Color(0xFF1E2522),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Footer: Date and Jump to Hadith button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DetailScreen(hadithId: hadith.id),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.arrow_back_rounded, size: 16),
                                        label: Text(
                                          'عرض الحديث',
                                          style: GoogleFonts.tajawal(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'آخر تعديل: $dateStr',
                                        style: GoogleFonts.tajawal(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}
