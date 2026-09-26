import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/providers/hadith_provider.dart';
import '../../data/models/hadith_model.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';
import 'toc_screen.dart';
import 'pdf_viewer_screen.dart';
import 'quiz_screen.dart';
import 'notes_screen.dart';
import 'references_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/share_card_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredHadithsAsync = ref.watch(filteredHadithListProvider);
    final favoriteIds = ref.watch(favoritesProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: AppDrawer(tabController: _tabController),
      appBar: AppBar(
        title: Text(
          'تُحْفَةُ الوِلْدَانِ',
          style: GoogleFonts.tajawal(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          // Table of Contents
          IconButton(
            icon: const Icon(Icons.format_list_bulleted_rounded),
            tooltip: 'فهرس الأحاديث',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TocScreen()),
              );
            },
          ),
          // PDF Book Reader
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'كتاب PDF المطبوع',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PdfViewerScreen()),
              );
            },
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'الإعدادات والتخصيص',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_tabController.index == 1 ? 54 : 116),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                if (_tabController.index != 1) ...[
                  // Modern Search Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF15261F) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? const Color(0x2F000000)
                              : const Color(0x0A000000),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) =>
                          ref.read(searchQueryProvider.notifier).state = val,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.tajawal(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'ابحث في نصوص الأحاديث، العناوين، الرواة...',
                        hintStyle: GoogleFonts.tajawal(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 13,
                        ),
                        prefixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(searchQueryProvider.notifier).state =
                                      '';
                                },
                              )
                            : null,
                        suffixIcon: Icon(
                          Icons.search_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                // Modern Tab selectors (Pill shaped segmented control)
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      width: 1.2,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: theme.colorScheme.onPrimary,
                    unselectedLabelColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    labelStyle: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    unselectedLabelStyle: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    tabs: const [
                      Tab(text: 'الأحاديث'),
                      Tab(text: 'المقدمات والتمهيد'),
                      Tab(text: 'المفضلة'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Tab 1: All Hadiths
            _buildHadithList(filteredHadithsAsync, theme, favoriteIds),
            // Tab 2: Introductions & Foreword
            _buildIntroductionsView(theme),
            // Tab 3: Bookmarked Hadiths
            _buildBookmarksList(filteredHadithsAsync, theme, favoriteIds),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithList(
    AsyncValue<List<HadithModel>> asyncList,
    ThemeData theme,
    Set<int> favoriteIds,
  ) {
    final bookSelection = ref.watch(bookSelectionProvider);
    final lastReadId = ref.watch(lastReadProvider);
    final hadithOfTheDayState = ref.watch(hadithOfTheDayProvider);
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Column(
      children: [
        // Book Selector Switch
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Container(
            height: 40,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                _buildBookSegment(
                  title: 'الكل (٨٠)',
                  isSelected: bookSelection == BookSelection.all,
                  onTap: () => ref.read(bookSelectionProvider.notifier).state =
                      BookSelection.all,
                  theme: theme,
                ),
                _buildBookSegment(
                  title: 'الجزء الثاني (١—٤٠/٢)',
                  isSelected: bookSelection == BookSelection.part2,
                  onTap: () => ref.read(bookSelectionProvider.notifier).state =
                      BookSelection.part2,
                  theme: theme,
                ),
                _buildBookSegment(
                  title: 'الجزء الأول (١—٤٠/١)',
                  isSelected: bookSelection == BookSelection.part1,
                  onTap: () => ref.read(bookSelectionProvider.notifier).state =
                      BookSelection.part1,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),

        // Quick Access Feature Chips (When not searching)
        if (!isSearching)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionChip(
                    icon: Icons.quiz_rounded,
                    label: 'اختبر حفظك',
                    color: const Color(0xFF00897B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuizScreen()),
                      );
                    },
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionChip(
                    icon: Icons.edit_note_rounded,
                    label: 'ملاحظاتي',
                    color: theme.colorScheme.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotesScreen()),
                      );
                    },
                    theme: theme,
                  ),
                ),
              ],
            ),
          ),

        // Expanded List View
        Expanded(
          child: asyncList.when(
            data: (hadiths) {
              // Apply book filtering
              final filteredByBook = hadiths.where((h) {
                if (bookSelection == BookSelection.part1) return h.id <= 40;
                if (bookSelection == BookSelection.part2) return h.id > 40;
                return true;
              }).toList();

              if (filteredByBook.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 64, color: theme.hintColor),
                      const SizedBox(height: 16),
                      Text(
                        'لم يتم العثور على نتائج للبحث',
                        style: GoogleFonts.tajawal(
                            fontSize: 17, color: theme.hintColor),
                      ),
                    ],
                  ),
                );
              }

              // Selected or Daily Hadith
              HadithModel dailyHadith;
              if (hadithOfTheDayState.selectedHadithId != null) {
                dailyHadith = hadiths.firstWhere(
                  (h) => h.id == hadithOfTheDayState.selectedHadithId,
                  orElse: () => hadiths.first,
                );
              } else {
                final dayOfYear = DateTime.now()
                    .difference(DateTime(DateTime.now().year, 1, 1))
                    .inDays;
                final dailyHadithIndex = (dayOfYear % hadiths.length);
                dailyHadith = hadiths[dailyHadithIndex];
              }

              // Last read hadith model
              HadithModel? lastReadHadith;
              if (lastReadId != null) {
                try {
                  lastReadHadith = hadiths.firstWhere((h) => h.id == lastReadId);
                } catch (_) {}
              }

              final headerCount = !isSearching ? (lastReadHadith != null ? 2 : 1) : 0;

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredByBook.length + headerCount,
                itemBuilder: (context, index) {
                  if (!isSearching) {
                    if (lastReadHadith != null && index == 0) {
                      return _buildContinueReadingCard(lastReadHadith, theme);
                    }
                    if ((lastReadHadith != null && index == 1) ||
                        (lastReadHadith == null && index == 0)) {
                      return _buildDailyHadithSpotlight(
                        dailyHadith,
                        hadithOfTheDayState.isRandomized,
                        hadiths,
                        theme,
                      );
                    }
                  }

                  final actualIndex = index - headerCount;
                  final hadith = filteredByBook[actualIndex];
                  final isFav = favoriteIds.contains(hadith.id);
                  return _buildHadithCard(hadith, isFav, theme);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('خطأ في تحميل الأحاديث: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueReadingCard(HadithModel hadith, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2F25) : const Color(0xFFE8F5EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(hadithId: hadith.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(hadithId: hadith.id),
                      ),
                    );
                  },
                  child: Text(
                    'متابعة ←',
                    style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'متابعة القراءة من حيث توقفت',
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.history_rounded,
                              color: theme.colorScheme.primary, size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الحديث ${hadith.formattedNumber}: ${hadith.title}',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyHadithSpotlight(
    HadithModel hadith,
    bool isRandomized,
    List<HadithModel> allHadiths,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final gold = theme.colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [const Color(0xFF143324), const Color(0xFF0D2117)]
              : [const Color(0xFF065A35), const Color(0xFF044227)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF065A35))
                .withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(hadithId: hadith.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Shuffle / Randomizer action
                        IconButton(
                          icon: const Icon(Icons.shuffle_rounded,
                              color: Colors.white70, size: 20),
                          tooltip: 'حديث عشوائي',
                          onPressed: () {
                            ref
                                .read(hadithOfTheDayProvider.notifier)
                                .shuffle(allHadiths);
                          },
                        ),
                        // Share Card Action
                        IconButton(
                          icon: const Icon(Icons.image_outlined,
                              color: Colors.white70, size: 20),
                          tooltip: 'مشاركة كبطاقة صورة',
                          onPressed: () {
                            ShareCardDialog.show(context, hadith);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded,
                              color: Colors.white70, size: 20),
                          tooltip: 'مشاركة نصياً',
                          onPressed: () {
                            Share.share(
                              '🌟 حديث من تحفة الولدان\n'
                              'تأليف: إبراهيم شريف أبوبكر\n\n'
                              '${hadith.title}\n\n'
                              '${hadith.narrator}\n\n'
                              '${hadith.text}\n\n'
                              'المصدر: ${hadith.source}',
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: gold.withValues(alpha: 0.5), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isRandomized ? 'حديث مختار عشوائياً' : 'حديث اليوم',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: gold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isRandomized
                                ? Icons.auto_awesome_rounded
                                : Icons.calendar_today_rounded,
                            color: gold,
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  hadith.title,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.tajawal(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hadith.text,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.amiri(
                    fontSize: 17,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'اضغط للقراءة الكاملة ←',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: gold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookSegment({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.22),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: GoogleFonts.tajawal(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.65),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksList(
    AsyncValue<List<HadithModel>> asyncList,
    ThemeData theme,
    Set<int> favoriteIds,
  ) {
    return asyncList.when(
      data: (hadiths) {
        final favHadiths =
            hadiths.where((h) => favoriteIds.contains(h.id)).toList();
        if (favHadiths.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_outline_rounded,
                    size: 64, color: theme.hintColor),
                const SizedBox(height: 16),
                Text(
                  'لا توجد أحاديث في المفضلة',
                  style: GoogleFonts.tajawal(
                      fontSize: 18, color: theme.hintColor),
                ),
                const SizedBox(height: 6),
                Text(
                  'اضغط على أيقونة الإشارة المرجعية داخل أي حديث لإضافته هنا',
                  style: GoogleFonts.tajawal(
                      fontSize: 13, color: theme.hintColor),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: favHadiths.length,
          itemBuilder: (context, index) {
            final hadith = favHadiths[index];
            return _buildHadithCard(hadith, true, theme);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('خطأ: $err')),
    );
  }

  Widget _buildHadithCard(HadithModel hadith, bool isFav, ThemeData theme) {
    final isLight = theme.brightness == Brightness.light;
    final isPart1 = hadith.id <= 40;
    final tagColor = isPart1 ? theme.colorScheme.primary : theme.colorScheme.secondary;
    final notesMap = ref.watch(hadithNotesProvider);
    final hasNote = notesMap.containsKey(hadith.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isLight ? Colors.white : const Color(0xFF14241D),
        border: Border.all(
          color: isLight ? const Color(0xFFE8E2D5) : const Color(0xFF1E3A2E),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isLight ? const Color(0x06000000) : const Color(0x1F000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  hadithId: hadith.id,
                  searchQuery: _searchController.text.isNotEmpty
                      ? _searchController.text
                      : null,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Action controls (Bookmark & Note icon)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: isFav
                                ? theme.colorScheme.secondary
                                : theme.hintColor,
                          ),
                          tooltip: 'حفظ في المفضلة',
                          onPressed: () {
                            ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(hadith.id);
                          },
                        ),
                        if (hasNote)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.edit_note_rounded,
                              color: theme.colorScheme.secondary,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    // Hadith Title and ID Badge
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              hadith.title,
                              textAlign: TextAlign.right,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ID Badge in 1-40/1 and 1-40/2 format
                          Container(
                            constraints: const BoxConstraints(minWidth: 42),
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: tagColor.withValues(alpha: 0.1),
                              border: Border.all(
                                color: tagColor.withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              hadith.formattedNumber,
                              style: TextStyle(
                                color: tagColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Narrator
                Text(
                  hadith.narrator,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                // Teaser of the Hadith
                Text(
                  hadith.text,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 12),
                // Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Part Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${hadith.partLabel} (${hadith.formattedNumber})',
                        style: GoogleFonts.tajawal(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: tagColor,
                        ),
                      ),
                    ),
                    // Source Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hadith.hadithNumber.isNotEmpty
                            ? '${hadith.source} (${hadith.hadithNumber})'
                            : hadith.source,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroductionsView(ThemeData theme) {
    final titleStyle = GoogleFonts.tajawal(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: theme.colorScheme.onSurface,
    );
    final subtitleStyle = GoogleFonts.tajawal(
      fontSize: 13,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );
    final bodyStyle = GoogleFonts.amiri(
      fontSize: 18,
      height: 1.8,
      color: theme.colorScheme.onSurface,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome Card
        Card(
          elevation: 0,
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Icon(Icons.menu_book_rounded,
                    size: 40, color: theme.colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  'المقدمات والتمهيد لكتاب تحفة الولدان',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تحتوي هذه الصفحة على تقديم الشيوخ الأفاضل ومقدمة وتمهيد المؤلف للكتاب',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_pin_rounded,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'تأليف: إبراهيم شريف أبوبكر',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildExpansionCard(
          title: 'التقديم الأول: الشيخ محمد أبوبكر',
          subtitle: 'عميد مركز عبدالله بن مسعود ومحاضر بجامعة كدونا',
          content:
              'الحمد لله رب العالمين والصلاة والسلام على أشرف الأنبياء والمرسلين نبينا محمد وعلى آله وصحبه أجمعين.\n\nوبعد:\n\nفقد اطّلعت على هذا الكتاب المفيد الموسوم بـ"تحفة الولدان من أحاديث النبي صلى الله عليه وسلم عن القرآن" الذي كتبه الأخ إبراهيم شريف أبوبكر، ووجدته نافعاً ومفيداً وخاصة لطلاب مرحلة الابتدائية في مدارس التحفيظ لما احتوى عليه من الأحاديث المتعلقة بالقرآن الكريم.\n\nوالله أسأل أن يقيد له القبول ويجعله خالصاً لوجهه الكريم، إنه ولي ذلك والقادر عليه.\n\nكتبه: (أبو محمد) محمد أبوبكر\nعميد مركز عبدالله بن مسعود\nمحاضر بقسم اللغة العربية، جامعة ولاية كدونا\n3/6/1445 – 16/12/2023',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 12),

        _buildExpansionCard(
          title: 'التقديم الثاني: الشيخ إبراهيم سليمان باباجي',
          subtitle: 'مدير دار ابن تيمية - مندو كدونا',
          content:
              'الحمد لله رب العالمين، وصلى الله على النبي الكريم، وعلى آله وصحبه ومن تبعهم بإحسان إلى يوم الدين.\n\nأما بعد:\n\nفإنه وقع اطّلاعي على الكُتـَيِّب الموسوم "تحفة الولدان من أحاديث النبي صلى الله عليه وسلم عن القرآن" للأخ إبراهيم شريف أبوبكر. وأَلْفَيتُهُ نافعاً لمن صُنِّفَ لأجلهم، وعلى ذلك أنصح مدارس تحفيظ القرآن الكريم بتقرير الكتاب لتلاميذهم وتحفيظهم إياّه.\n\nوالله المسؤول أن ينفع به كل من اعتناه وأن يجزل الثواب لمؤلفه ويجعله في ميزان حسناته. آمين.\n\nبقلم: إبراهيم سليمان إبراهيم باباجي\nمدير دار ابن تيمية\nمندو كدونا، نيجيريا\n2/1/2024 – 24/6/2024.',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 12),

        _buildExpansionCard(
          title: 'التقديم الثالث: الشيخ أبوبكر شريف أبوبكر',
          subtitle: 'مدير مركز عبدالله بن مسعود - كاوو كدونا',
          content:
              'الحمد لله والصلاة والسلام على رسول الله، وأهله وصحبه ومن تبعهم بإحسان إلى يوم الدين.\n\nأما بعد:\n\nفقد تصفّحت هذا الكتاب "تحفة الولدان" الذي ألّفه إبراهيم شريف أبوبكر وأنعمت النظر فيه فوجدته قد احتوى جماً غفيراً من أحاديث النبي صلى الله عليه وسلم عن القرآن على تنظيم وأسلوب لائق بالولدان.\n\nفجزى الله مؤلفه عن القرآن وأهله خير الجزاء.\n\nأبوبكر شريف أبوبكر\nمدير مركز عبدالله بن مسعود\nكاوو كدونا، نيجيريا\n17/05/1445 – 30/11/2023',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 20),

        // Section: Book 1 Headers
        _buildIntroSectionBadge(
          title: 'الكتاب الأول: الجزء الأول (الأحاديث ١/١ — ٤٠/١)',
          icon: Icons.bookmark_added_rounded,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 10),

        _buildExpansionCard(
          title: 'مقدمة الجزء الأول: إبراهيم شريف أبوبكر',
          subtitle: 'مدير مركز عبدالله بن مسعود',
          content:
              'إن الحمد لله نحمده ونستعينه ونستغفره ونستهديه، ونعوذ بالله من شرور أنفسنا ومن سيئات أعمالنا، من يهده الله فلا مضل له ومن يضلل فلا هادي له، وأشهد أن لا إله إلا الله وحده لا شريك له، وأشهد أن محمداً عبده ورسوله.\n\nأما بعد: فإن أحسن الحديث كلام الله عز وجل وخير الهدي هدي محمد صلى الله عليه وسلم، وشر الأمور محدثاتها وكل محدثة بدعة وكل بدعة ضلالة، وكل ضلالة في النار.\n\nوبعد:\n\nهذه جملة مختصرة من أحاديث النبي صلى الله عليه وسلم حول القرآن الكريم التي جمعتها للطلاب المبتدئين لأهميتها لديهم وقلة الكتب التي جمعت مثل هذا النوع من الأحاديث على مستواهم.\n\nقمت بهذا العمل لإفادة طلاب مدرستنا (مركز عبد الله بن مسعود لتحفيظ القرآن والدراسات الإسلامية) خاصة، وسائر طلاب مدارس تحفيظ القرآن والدراسات الإسلامية عامة.\n\nواشترطت على نفسي أن لا أورد في الكتاب إلا ما صح من الأحاديث.\n\nسميته بـ"تُحْفَةُ الوِلْدَانِ من أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ".\n\nوالله أسأل أن يتقبل مني هذا العمل ويجعله خالصاً لوجهه الكريم وينفع به الأمة الإسلامية وأن يجزي كل من ساعد في إعداده خير الجزاء، إنه ولي ذلك والقادر عليه.\n\nكتبه الفقير إلى عفو ربه\nإبراهيم شريف أبوبكر\nمدير مركز عبدالله بن مسعود\nتَمِينْ نَيْئًا، كدونا، نيجيريا.\n25/07/2023 - 07/01/1445',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 12),

        _buildExpansionCard(
          title: 'تمهيد الجزء الأول: المنهج المتّبع في عرض الأحاديث',
          subtitle: 'نظام ترتيب الأحاديث والضوابط العلمية',
          content:
              'هذا الكتاب يشتمل على أحاديث النبي صلى الله عليه وسلم حول القرآن الكريم.\n\nأورد الأحاديث على النظام الآتي:\n\nافتتحت الكتاب بحديث إخلاص النية لكونه أساس قبول الأعمال وسلّم وصولها، وفي ذلك يقول تعالى: {وَمَا أُمِرُوا إِلَّا لِيَعْبُدُوا اللَّهَ مُخْلِصِينَ لَهُ الدِّينَ حُنَفَاءَ وَيُقِيمُوا الصَّلَاةَ وَيُؤْتُوا الزَّكَاةَ ۚ وَذَٰلِكَ دِينُ الْقَيِّمَةِ} [البينة: 5].\n\nوتلوت ذلك بذكر الأحاديث التي تحثّ على تعلّم القرآن وتعليمه وقراءته وتحسين الصوت بالقراءة وتزيينه والتغني به وبيان أقل مدة لختمه وسجوده وذكر فضائل حملته وختمت الكتاب بذكر ما يفوز به قُرّاؤه من شفاعته.\n\nوقد ضَمَّنْتُ الكتاب بعض الحواشي التي تحتوي على التعليقات والبيانات المهمّة على بعض الأحاديث لتساعد المدرّسين في تدريس الكتاب.\n\nواكتفيت بذكر اسم الراوي للحديث بدون التعرّض لذكر درجة الحديث لما قد اشترطت على نفسي من إيراد الأحاديث الصحيحة فقط في الكتاب، وأما الأحاديث التي رواها البخاري ومسلم فأكتفي بذكر مصطلح "متفق عليه" بدون ذكرهما، كما درج على ذلك الحافظ ابن حجر العسقلاني رحمه الله تعالى.\n\nالمؤلف',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 12),

        _buildExpansionCard(
          title: 'خاتمة الجزء الأول: كلمة الختام',
          subtitle: 'نهاية الأحاديث الأربعين الأولى',
          content:
              'ما شاء الله لا قوة إلا بالله.\n\nالحمد لله الذي بنعمته تتم الصالحات.\n\nهذا آخر ما قدر الله لي جمعه في الجزء الأول من سلسلة كتاب "تُحْفَةُ الوِلْدَانِ مِنْ أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ".\n\nسبحانك اللهم وبحمدك أشهد أن لا إله إلا أنت، أستغفرك وأتوب إليك.\n\nويليه الجزء الثاني إن شاء الله تعالى.\n\nإبراهيم شريف أبوبكر\nمدير مركز عبدالله بن مسعود\nتَمِينْ نَيْئًا، كدونا، نيجيريا.\n21/08/2023 - 04/02/1445',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 12),

        _buildExpansionCard(
          title: 'أهم مراجع ومصادر الجزء الأول (Bibliography - Book 1)',
          subtitle: 'المصادر والكتب المعتمدة في تخريج وتحقيق وشرح الجزء الأول',
          content:
              'المصادر والمراجع المستفاد منها في أحاديث وحواشي الجزء الأول مرتبة فنياً:\n\n'
              'أولاً: أمهات كتب الحديث المسندة:\n'
              '١. القرآن الكريم (كلام الله المعجز المنزّل على نبيه ﷺ).\n'
              '٢. صحيح البخاري (الجامع الصحيح المختصر) — الإمام محمد بن إسماعيل البخاري (ت ٢٥٦ هـ).\n'
              '٣. صحيح مسلم (المسند الصحيح المختصر) — الإمام مسلم بن الحجاج النيسابوري (ت ٢٦١ هـ).\n'
              '٤. سنن أبي داود — الإمام سليمان بن الأشعث السجستاني (ت ٢٧٥ هـ).\n'
              '٥. جامع الترمذي (السنن) — الإمام محمد بن عيسى الترمذي (ت ٢٧٩ هـ).\n'
              '٦. سنن النسائي (المجتبى) — الإمام أحمد بن شعيب النسائي (ت ٣٠٣ هـ).\n'
              '٧. سنن ابن ماجه — الإمام محمد بن يزيد القزويني (ت ٢٧٥ هـ).\n'
              '٨. موطأ الإمام مالك — إمام دار الهجرة مالك بن أنس الأصبحي (ت ١٧٩ هـ).\n'
              '٩. سنن الدارمي — الإمام عبد الله بن عبد الرحمن الدارمي (ت ٢٥٥ هـ).\n'
              '١٠. صحيح الجامع الصغير وسلسلة الأحاديث الصحيحة — العلامة الألباني (ت ١٤٢٠ هـ).\n\n'
              'ثانياً: شروح الحديث النبوي المعتمدة:\n'
              '١١. فتح الباري شرح صحيح البخاري — الحافظ ابن حجر العسقلاني (ت ٨٥٢ هـ).\n'
              '١٢. المنهاج شرح صحيح مسلم — الإمام محيي الدين يحيى بن شرف النووي (ت ٦٧٦ هـ).\n'
              '١٣. جامع العلوم والحكم في شرح خمسين حديثاً — الحافظ ابن رجب الحنبلي (ت ٧٩٥ هـ).\n'
              '١٤. لطائف المعارف فيما لمواسم العام من الوظائف — الحافظ ابن رجب الحنبلي (ت ٧٩٥ هـ).\n'
              '١٥. تحفة الأحوذي بشرح جامع الترمذي — العلامة محمد عبد الرحمن المباركفوري (ت ١٣٥٣ هـ).\n'
              '١٦. عون المعبود شرح سنن أبي داود — العلامة محمد أشرف العظيم آبادي (ت ١٣٢٩ هـ).\n'
              '١٧. فيض القدير شرح الجامع الصغير — الحافظ زين الدين المناوي (ت ١٠٣١ هـ).\n'
              '١٨. شرح رياض الصالحين — فضيلة الشيخ محمد بن صالح العثيمين (ت ١٤٢١ هـ).\n'
              '١٩. دليل الفالحين لطرق رياض الصالحين — الشيخ ابن علان الشافعي (ت ١٠٥٧ هـ).\n'
              '٢٠. التمهيد لما في الموطأ من المعاني والأسانيد — الإمام ابن عبد البر (ت ٤٦٣ هـ).\n'
              '٢١. المجموع شرح المهذب — الإمام محيي الدين يحيى بن شرف النووي (ت ٦٧٦ هـ).\n'
              '٢٢. الشرح الممتع على زاد المستقنع — فضيلة الشيخ ابن عثيمين (ت ١٤٢١ هـ).\n\n'
              'ثالثاً: كتب علوم القرآن والتفسير والقراءات:\n'
              '٢٣. التبيان في آداب حملة القرآن — الإمام محيي الدين يحيى بن شرف النووي (ت ٦٧٦ هـ).\n'
              '٢٤. تفسير القرآن العظيم وفضائل القرآن — الحافظ عماد الدين ابن كثير (ت ٧٧٤ هـ).\n'
              '٢٥. تيسير الكريم الرحمن في تفسير كلام المنان — العلامة عبد الرحمن بن ناصر السعدي (ت ١٣٧٦ هـ).\n'
              '٢٦. الجامع لأحكام القرآن (تفسير القرطبي) — الإمام أبو عبد الله القرطبي (ت ٦٧١ هـ).\n'
              '٢٧. الإبانة عن معاني القراءات — الإمام مكي بن أبي طالب القيسي (ت ٤٣٧ هـ).\n'
              '٢٨. الوافي في شرح الشاطبية في القراءات السبع — فضيلة الشيخ عبد الفتاح القاضي (ت ١٤٠٣ هـ).\n'
              '٢٩. حرز الأماني ووجه التهاني (الشاطبية) — الإمام القاسم بن فيرُّه الشاطبي (ت ٥٩٠ هـ).\n'
              '٣٠. الفرائد الجليلة في شرح الدرر اللوامع — العلامة المحدث عبد الله بن فودي (ت ١٢٤٥ هـ).\n'
              '٣١. شرح القواعد الحسان في تفسير القرآن — فضيلة الشيخ ابن عثيمين (ت ١٤٢١ هـ).\n'
              '٣٢. الواضح في علوم القرآن — فضيلة الشيخ د. مصطفى ديب البغا ود. محيي الدين مستو، ومصنفات الشيخ أبي رفيدة السلفي.\n\n'
              'رابعاً: كتب العقيدة وهدي السلف والرقائق والأذكار:\n'
              '٣٣. جواب أهل العلم والإيمان بأن «قل هو الله أحد» تعدل ثلث القرآن — شيخ الإسلام ابن تيمية (ت ٧٢٨ هـ).\n'
              '٣٤. زاد المعاد في هدي خير العباد — الإمام شمس الدين ابن قيم الجوزية (ت ٧٥١ هـ).\n'
              '٣٥. بدائع الفوائد — الإمام شمس الدين ابن قيم الجوزية (ت ٧٥١ هـ).\n'
              '٣٦. إغاثة اللهفان من مصائد الشيطان — الإمام شمس الدين ابن قيم الجوزية (ت ٧٥١ هـ).\n'
              '٣٧. الأذكار المنتخبة من كلام سيد الأبرار — الإمام محيي الدين يحيى بن شرف النووي (ت ٦٧٦ هـ).\n'
              '٣٨. رياض الصالحين من كلام سيد المرسلين — الإمام محيي الدين يحيى بن شرف النووي (ت ٦٧٦ هـ).\n'
              '٣٩. الفصول في سيرة الرسول ﷺ — الحافظ عماد الدين إسماعيل بن كثير (ت ٧٧٤ هـ).',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 20),

        // Section: Book 2 Headers
        _buildIntroSectionBadge(
          title: 'الكتاب الثاني: الجزء الثاني (الأحاديث ١/٢ — ٤٠/٢)',
          icon: Icons.menu_book_rounded,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(height: 10),

        _buildExpansionCard(
          title: 'مقدمة الجزء الثاني: إبراهيم شريف أبوبكر',
          subtitle: 'مدير مركز عبدالله بن مسعود',
          content:
              'بسم الله الرحمن الرحيم\n\nإن الحمد لله، نحمده ونستعينه ونستغفره، ونعوذ بالله من شرور أنفسنا ومن سيئات أعمالنا، من يهده الله فلا مضل له، ومن يضلل فلا هادي له، وأشهد أن لا إله إلا الله وحده لا شريك له، وأشهد أن محمداً عبده ورسوله، الذي كانت وصيته الخالدة لأمته: «أَوْصَى بِكِتَابِ اللَّهِ»، وجعل خير الناس من اتصل به تعلماً وتعليماً وعملاً.\n\nأما بعد:\nفبعد أن مَنّ الله تعالى بإتمام ونشر الجزء الأول من «تُحْفَةُ الوِلْدَانِ مِنْ أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ»، وما لاقاه بحمد الله من إقبال ونفع في صفوف الناشئة وحلقات التحفيظ، يسرني أن أضع بين يدي القراء والمعلمين وطلاب العلم هذا «الجزء الثاني» المتمم للسلسلة، والمشتمل على أربعين حديثاً نبوياً شريفاً (من الحديث ١/٢ إلى الحديث ٤٠/٢).\n\nوقد عنيتُ في هذا الجزء بانتقاء أحاديث صحيحة تكشف للناشئ حقيقة الوحي ونزوله، وتغرس فيه تعظيم كلام الله، وتوقفه على أسرار التلاوة النبوية من الترتيل والمد والبكاء والتدبر، وترشده إلى الآداب القلبية في حلقات المدارسة، وتعرّفه بفضائل أعظم السور والآيات وما أودع الله فيها من البركة والتحصين والشفاء، مع التحذير من آفات القراء كالرياء والتكسب بالقرآن.\n\nوأسأل الله العلي القدير أن يجعل هذا الجزء كسابقه خالصاً لوجهه الكريم، وسبباً لرسوخ القرآن في قلوب أبنائنا وبناتنا، وأن ينفع به كل من قرأه أو حفظه أو علّمه، إنه نعم المولى ونعم النصير.\n\nكتبه:\nإبراهيم شريف أبوبكر\nمدير مركز عبدالله بن مسعود لتحفيظ القرآن والدراسات الإسلامية\nتَمِينْ نَيْئًا — كدونا، نيجيريا.',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 12),

        _buildExpansionCard(
          title: 'تمهيد الجزء الثاني: المنهج العلمي ومحاور الأحاديث',
          subtitle: 'المسار الموضوعي للأحاديث الأربعين (١/٢ — ٤٠/٢)',
          content:
              'يشتمل الجزء الثاني على أربعين حديثاً نبوياً شريفاً رُتبت ترتيباً تربوياً دقيقاً يتناول أبعاداً تفصيلية في علاقة المسلم بالقرآن الكريم:\n\n١. أصالة الوحي وعظمة القرآن (الأحاديث ١/٢ — ٦/٢):\nافتتح الجزء بالتأكيد على تجديد النية والإخلاص، ثم بيان كيفية نزول الوحي الشريف على النبي ﷺ، والتذكير بوصيته ﷺ بكتاب الله وأنه كلام الله المعجز، ورخصة الأحرف السبعة، ومثل المؤمن الذي يقرأ القرآن كالأترجة طيبة الريح والطعم.\n\n٢. التلقي والتعليم وآداب التلاوة النبوية (الأحاديث ٧/٢ — ١٥/٢):\nبيان فضل التعليم في الصغر وتلقي القرآن مشافهة عن المقرئين، وسنة النبي ﷺ في مد التلاوة والترتيل، والبكاء والخشوع عند سماع الآيات، واستحباب تحسين الصوت بالقرآن، والإنصات لقراءة الإمام، وفضل اجتماع الحلقات في بيوت الله لنزول السكينة وغشيان الرحمة وحفوف الملائكة.\n\n٣. أجر التلاوة وأحوال القائمين بالليل (الأحاديث ١٦/٢ — ٢٥/٢):\nمضاعفة الحسنات بعشر أمثالها لكل حرف، ووصية تعاهد القرآن كالإبل المعقلة، وفضل الماهر وتضعيف الأجر للمتعتع، وسنة النبي ﷺ في صلاة الليل بالتفاعل مع آيات الرحمة والعذاب، وترديد الآية الواحدة طلباً للتدبر، وتفاوت أجور القائمين بعشر آيات ومائة آية وألف آية.\n\n٤. صفات القراء والتحذير من الآفات المفسدة (الأحاديث ٢٦/٢ — ٣٢/٢):\nسنة سجود التلاوة، وسعة علم الصحابة بأسباب النزول كابن مسعود، وشفاعة القرآن لصاحبه وإلباسه تاج وحلة الكرامة، ثم التحذير الصريح من الجدال والفرقة، والرياء، وقراءة الحناجر بلا فهم، والنهي عن اتخاذ القرآن وسيلة لسؤال أموال الناس.\n\n٥. فضائل السور المخصوصة والرقية والتحصين (الأحاديث ٣٣/٢ — ٤٠/٢):\nعظمة سورة الفاتحة المقسمة مع الله، وآية الكرسي أعظم آية، وبركة سورة البقرة في طرد الشياطين، وتنزل السكينة لقارئ الكهف، والنهي عن التشويش برفع الصوت، ومكانة سورة الإخلاص الموجبة للجنة بكونها ثلث القرآن، وختام الجزء بسنة الرقية والتعوذ والتحصين الليلي بالمعوذات.\n\nالمؤلف',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 12),

        _buildExpansionCard(
          title: 'خاتمة الجزء الثاني وخاتمة الكتاب كاملاً',
          subtitle: 'كلمة الختام والدعاء بتمام ثمانين حديثاً شريفاً',
          content:
              'ما شاء الله لا قوة إلا بالله، والحمد لله الذي بنعمته تتم الصالحات، وبتوفيقه تُنال الرغائب وتُستكمل الغايات.\n\nبهذا الحديث المبارك في الرقية بالمعوذات ومسح الجسد بها رجاء بركتها نكون قد استوفينا بحمد الله تعالى ثمانين حديثاً نبوياً شريفاً من أصح ما ورد عن رسول الله ﷺ في فضائل القرآن الكريم، وآداب حملته، وأسرار تلاوته، وخواص سوره وآياته؛ أربعون منها في الجزء الأول، وأربعون في هذا الجزء الثاني.\n\nلقد طفنا في هذه السلسلة المباركة بين هدي النبي ﷺ ووصيته، من صفاء النية وبدء الوحي، مروراً بحلقات التلقي والمد والبكاء ومجالس السكينة، ووصولاً إلى مقامات الشفاعة وتيجان الكرامة في الدار الآخرة.\n\nفنسأل الله العظيم، رب العرش العظيم، بأسمائه الحسنى وصفاته العلى:\n• أن يجعل القرآن العظيم ربيع قلوبنا، ونور صدورنا، وجلاء أحزاننا، وذهاب همومنا وغمومنا.\n• وأن يجعله شاهداً لنا وحجة لنا لا علينا، وأن يرزقنا تلاوته آناء الليل وأطراف النهار على الوجه الذي يرضيه عنا.\n• وأن يجزي مشايخنا الأفاضل الذين قرظوا هذا الكتاب وراجعوا أسانيده خير الجزاء، وأن يبارك في أبنائنا وبناتنا من حفظة كتاب الله.\n• وأن يجعل هذا العمل وقفاً خالصاً متقبلاً مباركاً إلى يوم الدين.\n\nسبحانك اللهم وبحمدك، أشهد أن لا إله إلا أنت، أستغفرك وأتوب إليك.\nوصلى الله وسلم وبارك على عبدك ورسولك ونبيك محمد، وعلى آله وصحبه أجمعين، والحمد لله رب العالمين.\n\nويليه الجزء الثالث إن شاء الله تعالى.\n\nإبراهيم شريف أبوبكر\nمدير مركز عبدالله بن مسعود لتحفيظ القرآن والدراسات الإسلامية\nتَمِينْ نَيْئًا، كدونا، نيجيريا.',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 20),

        // Section: Bibliography
        _buildIntroSectionBadge(
          title: 'المراجع والمصادر العامة (السلسلة كاملة)',
          icon: Icons.library_books_rounded,
          color: const Color(0xFF00897B),
        ),
        const SizedBox(height: 10),

        _buildExpansionCard(
          title: 'أهم المراجع والمصادر الشاملة (Bibliography)',
          subtitle: 'المصادر والكتب المعتمدة عند أهل السنة والجماعة لكامل السلسلة',
          content:
              'أولاً: أمهات كتب الحديث المسندة:\n'
              '• صحيح البخاري — الإمام البخاري (ت ٢٥٦ هـ)\n'
              '• صحيح مسلم — الإمام مسلم (ت ٢٦١ هـ)\n'
              '• سنن أبي داود — الإمام أبو داود (ت ٢٧٥ هـ)\n'
              '• جامع الترمذي — الإمام الترمذي (ت ٢٧٩ هـ)\n'
              '• سنن النسائي — الإمام النسائي (ت ٣٠٣ هـ)\n'
              '• سنن ابن ماجه — الإمام ابن ماجه (ت ٢٧٥ هـ)\n'
              '• مسند الإمام أحمد — إمام أهل السنة أحمد بن حنبل (ت ٢٤١ هـ)\n'
              '• موطأ مالك — إمام دار الهجرة مالك بن أنس (ت ١٧٩ هـ)\n'
              '• سنن الدارمي — الإمام عبد الله بن عبد الرحمن الدارمي (ت ٢٥٥ هـ)\n'
              '• صحيح الجامع وسلسلة الأحاديث الصحيحة — العلامة الألباني (ت ١٤٢٠ هـ)\n\n'
              'ثانياً: شروح الحديث المعتمدة:\n'
              '• فتح الباري شرح صحيح البخاري — الحافظ ابن حجر العسقلاني (ت ٨٥٢ هـ)\n'
              '• المنهاج شرح صحيح مسلم — الإمام النووي (ت ٦٧٦ هـ)\n'
              '• جامع العلوم والحكم ولطائف المعارف — الحافظ ابن رجب الحنبلي (ت ٧٩٥ هـ)\n'
              '• تحفة الأحوذي بشرح جامع الترمذي — العلامة المباركفوري (ت ١٣٥٣ هـ)\n'
              '• عون المعبود شرح سنن أبي داود — العلامة العظيم آبادي (ت ١٣٢٩ هـ)\n'
              '• شرح رياض الصالحين والشرح الممتع — الشيخ ابن عثيمين (ت ١٤٢١ هـ)\n'
              '• دليل الفالحين لطرق رياض الصالحين — الشيخ ابن علان الشافعي (ت ١٠٥٧ هـ)\n'
              '• فيض القدير شرح الجامع الصغير — الحافظ المناوي (ت ١٠٣١ هـ)\n'
              '• التمهيد لما في الموطأ — الإمام ابن عبد البر (ت ٤٦٣ هـ)\n'
              '• المجموع شرح المهذب — الإمام النووي (ت ٦٧٦ هـ)\n'
              '• شرح صحيح البخاري — الإمام ابن بطال القرطبي (ت ٤٤٩ هـ)\n'
              '• نيل الأوطار — الإمام الشوكاني (ت ١٢٥٠ هـ)\n'
              '• حاشية السندي على سنن ابن ماجه — العلامة السندي (ت ١١٣٨ هـ)\n\n'
              'ثالثاً: كتب التفسير وعلوم القرآن والقراءات:\n'
              '• التبيان في آداب حملة القرآن — الإمام النووي (ت ٦٧٦ هـ)\n'
              '• تفسير القرآن العظيم وفضائل القرآن — الحافظ ابن كثير (ت ٧٧٤ هـ)\n'
              '• تيسير الكريم الرحمن وبهجة قلوب الأبرار — الشيخ السعدي (ت ١٣٧٦ هـ)\n'
              '• الجامع لأحكام القرآن — الإمام القرطبي (ت ٦٧١ هـ)\n'
              '• الإبانة عن معاني القراءات — الإمام مكي بن أبي طالب (ت ٤٣٧ هـ)\n'
              '• الوافي في شرح الشاطبية — الشيخ عبد الفتاح القاضي (ت ١٤٠٣ هـ)\n'
              '• النشر في القراءات العشر ومنجد المقرئين — الإمام ابن الجزري (ت ٨٣٣ هـ)\n'
              '• الفرائد الجليلة في شرح الدرر اللوامع — العلامة عبد الله بن فودي (ت ١٢٤٥ هـ)\n'
              '• الإتقان في علوم القرآن — الحافظ السيوطي (ت ٩١١ هـ)\n'
              '• التحديد في الإتقان والتجويد — الإمام أبو عمرو الداني (ت ٤٤٤ هـ)\n'
              '• حرز الأماني (الشاطبية) — الإمام الشاطبي (ت ٥٩٠ هـ)\n'
              '• شرح القواعد الحسان — الشيخ ابن عثيمين (ت ١٤٢١ هـ)\n'
              '• الواضح في علوم القرآن — الشيخ د. مصطفى ديب البغا ود. محيي الدين مستو\n\n'
              'رابعاً: كتب العقيدة والسيرة وهدي السلف والرقائق:\n'
              '• جواب أهل العلم والإيمان ومجموع الفتاوى — شيخ الإسلام ابن تيمية (ت ٧٢٨ هـ)\n'
              '• زاد المعاد ومدارج السالكين وبدائع الفوائد — الإمام ابن القيم (ت ٧٥١ هـ)\n'
              '• إغاثة اللهفان ومفتاح دار السعادة — الإمام ابن القيم (ت ٧٥١ هـ)\n'
              '• الأذكار ورياض الصالحين — الإمام النووي (ت ٦٧٦ هـ)\n'
              '• الفصول في سيرة الرسول ﷺ — الحافظ ابن كثير (ت ٧٧٤ هـ)\n'
              '• مجموع فتاوى ومقالات وفتاوى نور على الدرب — الشيخ ابن باز (ت ١٤٢٠ هـ)',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReferencesScreen()),
              );
            },
            icon: const Icon(Icons.library_books_rounded, size: 18),
            label: Text(
              'استعراض قائمة المراجع والمصادر التفاعلية (مع التفاصيل)',
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpansionCard({
    required String title,
    required String subtitle,
    required String content,
    required ThemeData theme,
    required TextStyle bodyStyle,
    required TextStyle titleStyle,
    required TextStyle subtitleStyle,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.1), width: 1),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            textAlign: TextAlign.right,
            style: titleStyle,
          ),
          subtitle: Text(
            subtitle,
            textAlign: TextAlign.right,
            style: subtitleStyle,
          ),
          leading: Icon(Icons.keyboard_arrow_down_rounded,
              color: theme.colorScheme.primary),
          trailing: const SizedBox.shrink(),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05)),
                ),
                child: SelectableText(
                  content,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: bodyStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSectionBadge({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: color),
        ],
      ),
    );
  }
}
