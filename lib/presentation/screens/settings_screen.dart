import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/notifications.dart';
import '../../data/providers/hadith_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeModeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final currentFontFamily = ref.watch(fontFamilyProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final audioState = ref.watch(audioPlayerProvider);
    final isLight = theme.brightness == Brightness.light;

    final cardDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF16211E),
      border: Border.all(
        color: isLight ? const Color(0xFFEFE8DD) : const Color(0xFF1E2E28),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: isLight ? const Color(0x06000000) : const Color(0x1F000000),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

    TextStyle getPreviewStyle(String family, double size) {
      switch (family) {
        case 'Scheherazade New':
          return GoogleFonts.scheherazadeNew(fontSize: size, height: 1.8);
        case 'Noto Naskh Arabic':
          return GoogleFonts.notoNaskhArabic(fontSize: size, height: 1.8);
        case 'Amiri':
        default:
          return GoogleFonts.amiri(fontSize: size, height: 1.8);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإعدادات والتخصيص',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        children: [
          // Section 1: Themes
          Text(
            'المظهر واللون',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: cardDecoration,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
            child: Column(
              children: [
                _ThemeOptionTile(
                  title: 'المظهر الفاتح (ورقي كريمي)',
                  icon: Icons.light_mode_outlined,
                  isSelected: currentThemeMode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.light),
                  activeColor: theme.colorScheme.primary,
                ),
                _ThemeOptionTile(
                  title: 'المظهر الداكن (زمردي ليلي)',
                  icon: Icons.dark_mode_outlined,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.dark),
                  activeColor: theme.colorScheme.primary,
                ),
                _ThemeOptionTile(
                  title: 'تلقائي حسب نظام الجهاز',
                  icon: Icons.settings_brightness_outlined,
                  isSelected: currentThemeMode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.system),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Notifications
          Text(
            'التنبيهات اليومية',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: cardDecoration,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Switch.adaptive(
                  value: notificationsEnabled,
                  activeTrackColor: theme.colorScheme.primary,
                  onChanged: (val) async {
                    if (val) {
                      final granted = await requestNotificationPermission();
                      if (granted) {
                        await ref
                            .read(notificationsEnabledProvider.notifier)
                            .setEnabled(true);
                        await scheduleDailyNotification(
                          title: 'تُحْفَةُ الوِلْدَانِ — حديث اليوم',
                          body: 'قال رسول الله ﷺ: «خَيْرُكُمْ مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ»',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تفعيل التذكير اليومي بحديث الصباح (7:00 ص)'),
                            ),
                          );
                        }
                      }
                    } else {
                      await ref
                          .read(notificationsEnabledProvider.notifier)
                          .setEnabled(false);
                      await cancelDailyNotification();
                    }
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'تذكير حديث اليوم',
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'إشعار يومي صباحاً (٧:٠٠ ص) بحديث نبوي شريف',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: isLight ? Colors.grey[600] : Colors.grey[400],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 3: Font Family Picker
          Text(
            'نوع خط الأحاديث',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: cardDecoration,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _FontOptionTile(
                  fontName: 'خط الأميري (الافتراضي)',
                  fontKey: 'Amiri',
                  previewText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  isSelected: currentFontFamily == 'Amiri',
                  textStyle: GoogleFonts.amiri(fontSize: 18),
                  onTap: () => ref
                      .read(fontFamilyProvider.notifier)
                      .setFontFamily('Amiri'),
                  activeColor: theme.colorScheme.primary,
                ),
                const Divider(height: 12),
                _FontOptionTile(
                  fontName: 'خط شهرزاد الجديد',
                  fontKey: 'Scheherazade New',
                  previewText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  isSelected: currentFontFamily == 'Scheherazade New',
                  textStyle: GoogleFonts.scheherazadeNew(fontSize: 19),
                  onTap: () => ref
                      .read(fontFamilyProvider.notifier)
                      .setFontFamily('Scheherazade New'),
                  activeColor: theme.colorScheme.primary,
                ),
                const Divider(height: 12),
                _FontOptionTile(
                  fontName: 'خط نوتو نسخ عربي',
                  fontKey: 'Noto Naskh Arabic',
                  previewText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  isSelected: currentFontFamily == 'Noto Naskh Arabic',
                  textStyle: GoogleFonts.notoNaskhArabic(fontSize: 16),
                  onTap: () => ref
                      .read(fontFamilyProvider.notifier)
                      .setFontFamily('Noto Naskh Arabic'),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 4: Font Size Adjustment
          Text(
            'حجم خط القراءة',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: cardDecoration,
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${fontSize.toInt()} نقطة',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text('حجم الخط الحالي', style: GoogleFonts.tajawal(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: fontSize,
                  min: 16.0,
                  max: 36.0,
                  divisions: 10,
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  onChanged: (val) {
                    ref.read(fontSizeProvider.notifier).setFontSize(val);
                  },
                ),
                const SizedBox(height: 8),
                // Font preview panel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFFAF7F0) : const Color(0xFF131D1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
                    textAlign: TextAlign.center,
                    style: getPreviewStyle(currentFontFamily, fontSize),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 5: Audio Recitation Speed
          Text(
            'سرعة القراءة الصوتية',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: cardDecoration,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
            child: Column(
              children: [
                _SpeedOptionTile(
                  title: 'بطيء جداً (٠٫٣٠×) — مناسب للتحفيظ والتكرار',
                  isSelected: audioState.playbackRate == 0.30,
                  onTap: () => ref
                      .read(audioPlayerProvider.notifier)
                      .setRate(0.30),
                  activeColor: theme.colorScheme.primary,
                ),
                _SpeedOptionTile(
                  title: 'بطيء ومرتل (٠٫٤٠×)',
                  isSelected: audioState.playbackRate == 0.40,
                  onTap: () => ref
                      .read(audioPlayerProvider.notifier)
                      .setRate(0.40),
                  activeColor: theme.colorScheme.primary,
                ),
                _SpeedOptionTile(
                  title: 'هادئ ومتأنٍ (٠٫٤٥×) — الافتراضي الموصى به',
                  isSelected: audioState.playbackRate == 0.45,
                  onTap: () => ref
                      .read(audioPlayerProvider.notifier)
                      .setRate(0.45),
                  activeColor: theme.colorScheme.primary,
                ),
                _SpeedOptionTile(
                  title: 'معتدل (٠٫٥٥×)',
                  isSelected: audioState.playbackRate == 0.55,
                  onTap: () => ref
                      .read(audioPlayerProvider.notifier)
                      .setRate(0.55),
                  activeColor: theme.colorScheme.primary,
                ),
                _SpeedOptionTile(
                  title: 'سريع (٠٫٧٠×)',
                  isSelected: audioState.playbackRate == 0.70,
                  onTap: () => ref
                      .read(audioPlayerProvider.notifier)
                      .setRate(0.70),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 6: Audio Repeat for Memorization
          Text(
            'تكرار التلاوة للتحفيظ',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: cardDecoration,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
            child: Column(
              children: [
                _RepeatOptionTile(
                  title: 'مرة واحدة (تشغيل عادي بدون تكرار)',
                  icon: Icons.repeat_rounded,
                  isSelected: audioState.repeatCount == 1,
                  onTap: () => ref
                      .read(audioPlayerProvider.notifier)
                      .setRepeatCount(1),
                  activeColor: theme.colorScheme.primary,
                ),
                _RepeatOptionTile(
                  title: '٣ مرات — تكرار أولي للتحفيظ',
                  icon: Icons.repeat_one_rounded,
                  isSelected: audioState.repeatCount == 3,
                  onTap: () => ref
                      .read(audioPlayerProvider.notifier)
                      .setRepeatCount(3),
                  activeColor: theme.colorScheme.primary,
                ),
                _RepeatOptionTile(
                  title: '٥ مرات — تثبيت الحفظ ومراجعته',
                  icon: Icons.repeat_one_rounded,
                  isSelected: audioState.repeatCount == 5,
                  onTap: () => ref
                      .read(audioPlayerProvider.notifier)
                      .setRepeatCount(5),
                  activeColor: theme.colorScheme.primary,
                ),
                _RepeatOptionTile(
                  title: '١٠ مرات — إتقان ورسوخ تام',
                  icon: Icons.repeat_one_rounded,
                  isSelected: audioState.repeatCount == 10,
                  onTap: () => ref
                      .read(audioPlayerProvider.notifier)
                      .setRepeatCount(10),
                  activeColor: theme.colorScheme.primary,
                ),
                _RepeatOptionTile(
                  title: 'تكرار مستمر بلا انقطاع (∞)',
                  icon: Icons.all_inclusive_rounded,
                  isSelected: audioState.repeatCount == -1,
                  onTap: () => ref
                      .read(audioPlayerProvider.notifier)
                      .setRepeatCount(-1),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 7: About Screen Navigation
          Container(
            decoration: cardDecoration,
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
              leading: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
              trailing: Icon(Icons.info_outline, color: theme.colorScheme.primary),
              title: Text(
                'عن الكتاب والناشر',
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Text(
                'المؤلف، التقديم، المراجعون، والناشر',
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: isLight ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SpeedOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _SpeedOptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
        child: Row(
          children: [
            if (isSelected)
              Icon(Icons.check_circle, color: activeColor, size: 20)
            else
              Icon(Icons.circle_outlined,
                  color: Colors.grey.withValues(alpha: 0.4), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.speed_rounded,
                color: isSelected
                    ? activeColor
                    : Colors.grey.withValues(alpha: 0.45),
                size: 20),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _ThemeOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            if (isSelected)
              Icon(Icons.check_circle, color: activeColor, size: 20)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.withValues(alpha: 0.5), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: activeColor, size: 22),
          ],
        ),
      ),
    );
  }
}

class _FontOptionTile extends StatelessWidget {
  final String fontName;
  final String fontKey;
  final String previewText;
  final bool isSelected;
  final TextStyle textStyle;
  final VoidCallback onTap;
  final Color activeColor;

  const _FontOptionTile({
    required this.fontName,
    required this.fontKey,
    required this.previewText,
    required this.isSelected,
    required this.textStyle,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          children: [
            if (isSelected)
              Icon(Icons.check_circle, color: activeColor, size: 20)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.withValues(alpha: 0.4), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fontName,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    previewText,
                    style: textStyle.copyWith(
                      color: isSelected ? activeColor : Colors.grey[700],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RepeatOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _RepeatOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
        child: Row(
          children: [
            if (isSelected)
              Icon(Icons.check_circle, color: activeColor, size: 20)
            else
              Icon(Icons.circle_outlined,
                  color: Colors.grey.withValues(alpha: 0.4), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon,
                color: isSelected
                    ? activeColor
                    : Colors.grey.withValues(alpha: 0.45),
                size: 20),
          ],
        ),
      ),
    );
  }
}
