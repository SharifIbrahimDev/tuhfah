import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/pdf_service.dart';
import '../../data/providers/hadith_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/toc_screen.dart';
import '../screens/pdf_viewer_screen.dart';
import '../screens/about_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/notes_screen.dart';

class AppDrawer extends ConsumerWidget {
  final TabController tabController;

  const AppDrawer({super.key, required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final green = theme.colorScheme.primary;
    final gold = theme.colorScheme.secondary;
    final favoriteIds = ref.watch(favoritesProvider);
    final notesMap = ref.watch(hadithNotesProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Luxury Header Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [const Color(0xFF143023), const Color(0xFF09140E)]
                    : [const Color(0xFF065A35), const Color(0xFF033821)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Theme Quick-Toggle
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 20,
                      ),
                      tooltip: 'تبديل المظهر',
                      onPressed: () {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                              currentThemeMode == ThemeMode.dark
                                  ? ThemeMode.light
                                  : ThemeMode.dark,
                            );
                      },
                    ),
                    // App Logo
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.35),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/data/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance the row
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'تُحْفَةُ الوِلْدَانِ',
                  style: GoogleFonts.tajawal(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'مِنْ أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ',
                  style: GoogleFonts.amiri(
                    fontSize: 14,
                    color: gold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'تأليف: الأستاذ إبراهيم شريف أبوبكر',
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),

                // Live Stats Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(label: 'الأحاديث', value: '٨٠'),
                      Container(height: 18, width: 1, color: Colors.white.withValues(alpha: 0.2)),
                      _StatChip(label: 'المفضلة', value: '${favoriteIds.length}'),
                      Container(height: 18, width: 1, color: Colors.white.withValues(alpha: 0.2)),
                      _StatChip(label: 'الملاحظات', value: '${notesMap.length}'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              children: [
                _DrawerTile(
                  title: 'قائمة الأحاديث الشريفة',
                  icon: Icons.auto_stories_rounded,
                  iconColor: green,
                  isSelected: tabController.index == 0,
                  onTap: () {
                    Navigator.pop(context);
                    tabController.animateTo(0);
                  },
                ),
                _DrawerTile(
                  title: 'اختبر حفظك ومعلوماتك',
                  icon: Icons.quiz_rounded,
                  iconColor: const Color(0xFF00897B),
                  badge: 'جديد',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizScreen()),
                    );
                  },
                ),
                _DrawerTile(
                  title: 'ملاحظاتي وتأملاتي',
                  icon: Icons.edit_note_rounded,
                  iconColor: gold,
                  badge: notesMap.isNotEmpty ? '${notesMap.length}' : null,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotesScreen()),
                    );
                  },
                ),
                _DrawerTile(
                  title: 'فهرس الأحاديث (جدول المحتويات)',
                  icon: Icons.format_list_bulleted_rounded,
                  iconColor: gold,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TocScreen()),
                    );
                  },
                ),
                _DrawerTile(
                  title: 'المقدمات والتمهيد',
                  icon: Icons.history_edu_rounded,
                  iconColor: green,
                  isSelected: tabController.index == 1,
                  onTap: () {
                    Navigator.pop(context);
                    tabController.animateTo(1);
                  },
                ),
                _DrawerTile(
                  title: 'الأحاديث المحفوظة (المفضلة)',
                  icon: Icons.bookmark_rounded,
                  iconColor: gold,
                  badge: favoriteIds.isNotEmpty ? '${favoriteIds.length}' : null,
                  isSelected: tabController.index == 2,
                  onTap: () {
                    Navigator.pop(context);
                    tabController.animateTo(2);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                _DrawerTile(
                  title: 'قراءة الكتاب (PDF)',
                  icon: Icons.menu_book_rounded,
                  iconColor: const Color(0xFFE74C3C),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PdfViewerScreen()),
                    );
                  },
                ),
                _DrawerTile(
                  title: 'تحميل ومشاركة الكتاب (PDF)',
                  icon: Icons.download_for_offline_rounded,
                  iconColor: const Color(0xFF00897B),
                  onTap: () {
                    Navigator.pop(context);
                    PdfService.showDownloadModal(context);
                  },
                ),
                _DrawerTile(
                  title: 'الإعدادات والتخصيص',
                  icon: Icons.tune_rounded,
                  iconColor: green,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                _DrawerTile(
                  title: 'عن الكتاب والناشر',
                  icon: Icons.info_outline_rounded,
                  iconColor: gold,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                _DrawerTile(
                  title: 'مشاركة التطبيق',
                  icon: Icons.share_rounded,
                  iconColor: green,
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(
                      'تطبيق تُحْفَةُ الوِلْدَانِ مِنْ أَحَادِيثِ النَّبِيِّ ﷺ عَنِ القُرْآنِ\n'
                      'لطلاب ومدرسي حلقات تحفيظ القرآن الكريم.\n'
                      'تأليف الأستاذ إبراهيم شريف أبوبكر — مركز عبدالله بن مسعود.',
                    );
                  },
                ),
              ],
            ),
          ),

          // Modern Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              children: [
                Text(
                  'تأليف: الأستاذ إبراهيم شريف أبوبكر',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: green,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'مركز عبدالله بن مسعود • كدونا، نيجيريا',
                  style: GoogleFonts.tajawal(
                    fontSize: 10,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.tajawal(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.tajawal(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isSelected;
  final String? badge;

  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isSelected = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25))
            : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        trailing: Icon(icon, color: iconColor, size: 22),
        leading: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              )
            : null,
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B)),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
