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
                  title: 'الجزء الثاني (٤١—٨٠)',
                  isSelected: bookSelection == BookSelection.part2,
                  onTap: () => ref.read(bookSelectionProvider.notifier).state =
                      BookSelection.part2,
                  theme: theme,
                ),
                _buildBookSegment(
                  title: 'الجزء الأول (١—٤٠)',
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
                        'الحديث ${hadith.id}: ${hadith.title}',
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
                              'تأليف: الأستاذ إبراهيم شريف أبوبكر\n\n'
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
                          // ID Badge
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.08),
                              border: Border.all(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              hadith.id.toString(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
                        isPart1 ? 'الجزء الأول' : 'الجزء الثاني',
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
                        'تأليف: الأستاذ إبراهيم شريف أبوبكر',
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
              'الحمد لله رب العالمين، وصلى الله على النبي الكريم، وعلى آله وصحبه ومن تبعهم بإحسان إلى يوم الدين.\n\nأما بعد:\n\nفإنه وقع اطّلاعي على الكُتـَيِّب الموسوم "تحفة الولدان من أحاديث النبي صلى الله عليه وسلم عن القرآن" للأخ الأستاذ إبراهيم شريف أبوبكر. وأَلْفَيتُهُ نافعاً لمن صُنِّفَ لأجلهم، وعلى ذلك أنصح مدارس تحفيظ القرآن الكريم بتقرير الكتاب لتلاميذهم وتحفيظهم إياّه.\n\nوالله المسؤول أن ينفع به كل من اعتناه وأن يجزل الثواب لمؤلفه ويجعله في ميزان حسناته. آمين.\n\nبقلم: إبراهيم سليمان إبراهيم باباجي\nمدير دار ابن تيمية\nمندو كدونا، نيجيريا\n2/1/2024 – 24/6/2024.',
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
        const SizedBox(height: 12),

        _buildExpansionCard(
          title: 'مقدمة المؤلف: الأستاذ إبراهيم شريف أبوبكر',
          subtitle: 'مدير مركز عبدالله بن مسعود',
          content:
              'إن الحمد لله نحمده ونستعينه ونستغفره ونستهديه، ونعوذ بالله من شرور أنفسنا وسيئات أعمالنا، من يهده الله فلا مضل له ومن يضلل فلا هادي له، وأشهد أن لا إله إلا الله وحده لا شريك له، وأشهد أن محمداً عبده ورسوله.\n\nأما بعد: فإن أحسن الحديث كلام الله عز وجل وخير الهدي هدي محمد صلى الله عليه وسلم، وشر الأمور محدثاتها وكل محدثة بدعة وكل بدعة ضلالة، وكل ضلالة في النار.\n\nوبعد:\n\nهذه جملة مختصرة من أحاديث النبي صلى الله عليه وسلم حول القرآن الكريم التي جمعتها للطلاب المبتدئين لأهميتها لديهم وقلة الكتب التي جمعت مثل هذا النوع من الأحاديث على مستواهم.\n\nقمت بهذا العمل لإفادة طلاب مدرستنا (مركز عبد الله بن مسعود لتحفيظ القرآن والدراسات الإسلامية) خاصة، وسائر طلاب مدارس تحفيظ القرآن والدراسات الإسلامية عامة.\n\nواشترطت على نفسي أن لا أورد في الكتاب إلا ما صح من الأحاديث.\n\nسميته بـ"تُحْفَةُ الوِلْدَانِ من أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ".\n\nوالله أسأل أن يتقبل مني هذا العمل ويجعله خالصاً لوجهه الكريم وينفع به الأمة الإسلامية وأن يجزي كل من ساعد في إعداده خير الجزاء، إنه ولي ذلك والقادر عليه.\n\nكتبه الفقير إلى عفو ربه\nإبراهيم شريف أبوبكر\nمدير مركز عبدالله بن مسعود\nتَمِينْ نَيْئًا، كدونا، نيجيريا.\n25/07/2023 - 07/01/1445',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 12),

        _buildExpansionCard(
          title: 'التمهيد للكتاب (Foreword)',
          subtitle: 'المنهج المتّبع في عرض الأحاديث',
          content:
              'هذا الكتاب يشتمل على أحاديث النبي صلى الله عليه وسلم حول القرآن الكريم.\n\nأورد الأحاديث على النظام الآتي:\n\nافتتحت الكتاب بحديث إخلاص النية لكونه أساس قبول الأعمال وسلّم وصولها، وفي ذلك يقول تعالى: {وَمَا أُمِرُوا إِلَّا لِيَعْبُدُوا اللَّهَ مُخْلِصِينَ لَهُ الدِّينَ حُنَفَاءَ وَيُقِيمُوا الصَّلَاةَ وَيُؤْتُوا الزَّكَاةَ ۚ وَذَٰلِكَ دِينُ الْقَيِّمَةِ} [البينة: 5].\n\nوتلوت ذلك بذكر الأحاديث التي تحثّ على تعلّم القرآن وتعليمه وقراءته وتحسين الصوت بالقراءة وتزيينه والتغني به وبيان أقل مدة لختمه وسجوده وذكر فضائل حملته وختمت الكتاب بذكر ما يفوز به قرّاءه من شفاعته.\n\nوقد ضَمَّنْتُ الكتاب بعض الحواشي التي تحتوي على التعليقات والبيانات المهمّة على بعض الأحاديث لتساعد المدرّسين في تدريس الكتاب.\n\nواكتفيت بذكر اسم الراوي للحديث بدون التعرّض لذكر درجة الحديث لما قد اشترطت على نفسي من إيراد الأحاديث الصحيحة فقط في الكتاب، وأما الأحاديث التي رواها البخاري ومسلم فأكتفي بذكر مصطلح "متفق عليه" بدون ذكرهما، كما درج على ذلك الحافظ ابن حجر العسقلاني رحمه الله تعالى.\n\nالمؤلف',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 12),

        _buildExpansionCard(
          title: 'الخاتمة للكتاب (Conclusion)',
          subtitle: 'كلمة الختام للجزء الأول من السلسلة',
          content:
              'ما شاء الله لا قوة إلا بالله.\n\nالحمد لله الذي بنعمته تتم الصالحات.\n\nهذا آخر ما قدر الله لي جمعه في الجزء الأول من سلسلة كتاب "تُحْفَةُ الوِلْدَانِ مِنْ أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ".\n\nسبحانك اللهم وبحمدك أشهد أن لا إله إلا أنت، أستغفرك وأتوب إليك.\n\nويليه الجزء الثاني إن شاء الله تعالى.\n\nإبراهيم شريف أبوبكر\nمدير مركز عبدالله بن مسعود\nتَمِينْ نَيْئًا، كدونا، نيجيريا.\n21/08/2023 - 04/02/1445',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
        const SizedBox(height: 12),

        _buildExpansionCard(
          title: 'أهم المراجع والمصادر (Bibliography)',
          subtitle: 'المصادر والكتب المعتمدة في تحقيق الأحاديث وشرحها',
          content:
              '• القرآن الكريم\n• صحيح البخاري — الإمام البخاري\n• صحيح مسلم — الإمام مسلم\n• سنن أبي داود — الإمام أبو داود\n• سنن الترمذي — الإمام الترمذي\n• سنن النسائي — الإمام النسائي\n• سنن ابن ماجه — الإمام ابن ماجه\n• رياض الصالحين — الإمام النووي\n• شرح رياض الصالحين — الشيخ ابن العثيمين\n• دليل الفالفين لطرق رياض الصالحين — الشيخ محمد بن علان الصديقي الشافعي\n• فيض القدير شرح الجامع الصغير — الحافظ المناوي\n• تفسير القرآن العظيم — الحافظ ابن كثير\n• تيسير الكريم الرحمن في تفسير كلام المنان — الشيخ السعدي\n• الوافي في شرح الشاطبية — الشيخ عبد الغني عبد الفتاح القاضي\n• شرح القواعد الحسان في تفسير القرآن — الشيخ ابن العثيمين\n• الإبانة عن معاني القراءات — الإمام المكي بن أبي طالب\n• الفرائد الجليلة في شرح الدرر اللوامع — العلامة عبدالله بن فودي\n• الفصول في سيرة الرسول — الحافظ ابن كثير\n• التبيان في آداب حملة القرآن — الإمام النووي\n• موطأ مالك — الإمام مالك\n• الواضح في علوم القرآن — الشيخ أبو رفيدة السلفي',
          theme: theme,
          bodyStyle: bodyStyle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
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
}
