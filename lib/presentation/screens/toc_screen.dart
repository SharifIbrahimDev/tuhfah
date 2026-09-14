import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/hadith_model.dart';
import '../../data/providers/hadith_provider.dart';
import 'detail_screen.dart';

class TocScreen extends ConsumerStatefulWidget {
  const TocScreen({super.key});

  @override
  ConsumerState<TocScreen> createState() => _TocScreenState();
}

class _TocScreenState extends ConsumerState<TocScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final green = theme.colorScheme.primary;
    final gold = theme.colorScheme.secondary;
    final hadithsAsync = ref.watch(hadithListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'فهرس أحاديث الكتاب',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: hadithsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (hadiths) {
          final filtered = hadiths.where((h) {
            if (_filter.isEmpty) return true;
            return h.title.toLowerCase().contains(_filter.toLowerCase()) ||
                h.id.toString().contains(_filter);
          }).toList();

          final part1 = filtered.where((h) => h.id <= 40).toList();
          final part2 = filtered.where((h) => h.id > 40).toList();

          return Column(
            children: [
              // Search input
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF14241D) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: green.withValues(alpha: 0.15),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x2F000000)
                            : const Color(0x0A000000),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _filter = val.trim()),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.tajawal(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن عنوان حديث أو رقمه...',
                      hintStyle: GoogleFonts.tajawal(
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                        fontSize: 13,
                      ),
                      prefixIcon: _filter.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _filter = '');
                              },
                            )
                          : null,
                      suffixIcon: Icon(Icons.search_rounded, color: green),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),

              // Filtered List
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  children: [
                    if (part1.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'الجزء الأول (الأحاديث ١ — ٤٠)',
                        color: green,
                        count: '${part1.length} حديثاً',
                      ),
                      ...part1.map((h) => _TocItem(
                            hadith: h,
                            gold: gold,
                            green: green,
                            isDark: isDark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(hadithId: h.id),
                              ),
                            ),
                          )),
                      const SizedBox(height: 14),
                    ],
                    if (part2.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'الجزء الثاني (الأحاديث ٤١ — ٨٠)',
                        color: gold,
                        count: '${part2.length} حديثاً',
                      ),
                      ...part2.map((h) => _TocItem(
                            hadith: h,
                            gold: gold,
                            green: green,
                            isDark: isDark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(hadithId: h.id),
                              ),
                            ),
                          )),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final String count;

  const _SectionHeader({
    required this.title,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TocItem extends StatelessWidget {
  final HadithModel hadith;
  final Color gold;
  final Color green;
  final bool isDark;
  final VoidCallback onTap;

  const _TocItem({
    required this.hadith,
    required this.gold,
    required this.green,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14241D) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1E3A2E) : const Color(0xFFE8E2D5),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(Icons.chevron_left_rounded,
            color: isDark ? Colors.grey[600] : Colors.grey[400], size: 20),
        title: Text(
          hadith.title,
          style: GoogleFonts.amiri(
            fontSize: 16,
            color: isDark ? const Color(0xFFF0FDF4) : const Color(0xFF1E2522),
          ),
          textAlign: TextAlign.right,
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: green.withValues(alpha: 0.1),
            border: Border.all(color: green.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            '${hadith.id}',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: green,
            ),
          ),
        ),
      ),
    );
  }
}
