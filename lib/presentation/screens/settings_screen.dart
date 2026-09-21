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
    final notificationTime = ref.watch(notificationTimeProvider);
    final audioState = ref.watch(audioPlayerProvider);
    final isLight = theme.brightness == Brightness.light;

    String formatTimeArabic(TimeOfDay time) {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'ص' : 'م';
      return '$hour:$minute $period';
    }

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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
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
                              hour: notificationTime.hour,
                              minute: notificationTime.minute,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم تفعيل التذكير اليومي بحديث الصباح (${formatTimeArabic(notificationTime)})',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'يرجى السماح بإذن الإشعارات من إعدادات النظام للتطبيق',
                                    textAlign: TextAlign.right,
                                  ),
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
                            notificationsEnabled
                                ? 'يصلك تنبيه يومياً في تمام الساعة (${formatTimeArabic(notificationTime)})'
                                : 'تفعيل إشعار يومي يذكرك بحديث نبوي شريف',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color:
                                  isLight ? Colors.grey[600] : Colors.grey[400],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.notifications_active_outlined,
                        color: theme.colorScheme.primary),
                  ],
                ),
                if (notificationsEnabled) ...[
                  const Divider(height: 20),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: notificationTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme:
                                  Theme.of(context).colorScheme.copyWith(
                                        primary: theme.colorScheme.primary,
                                      ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        await ref
                            .read(notificationTimeProvider.notifier)
                            .setTime(picked);
                        final scheduledDate = await scheduleDailyNotification(
                          hour: picked.hour,
                          minute: picked.minute,
                        );
                        if (context.mounted) {
                          final now = DateTime.now();
                          final diffMinutes = scheduledDate.difference(now).inMinutes;
                          final isToday = scheduledDate.day == now.day;
                          final timeStr = isToday
                              ? 'اليوم بعد $diffMinutes دقيقة في تمام (${formatTimeArabic(picked)})'
                              : 'غداً في تمام (${formatTimeArabic(picked)})';

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم ضبط التذكير: $timeStr',
                                textAlign: TextAlign.right,
                              ),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 14, color: theme.colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  formatTimeArabic(notificationTime),
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'تغيير وقت التذكير',
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.access_time_rounded,
                              size: 20, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Option A: Instant Test Notification
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await showTestNotification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تم إرسال إشعار فوري الآن — تحقق من شريط الإشعارات لديك',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.touch_app_outlined,
                              size: 16, color: theme.colorScheme.primary),
                          const Spacer(),
                          Text(
                            'إرسال إشعار فوري للتأكد من الصوت والعرض',
                            style: GoogleFonts.tajawal(
                              fontSize: 13.5,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.notifications_active_outlined,
                              size: 20, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Option B: Quick 10-second countdown test
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await scheduleTestCountdownNotification(seconds: 10);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '⏳ تمت جدولة إشعار اختباري سريع ليصلك بعد ١٠ ثوانٍ — أغلق التطبيق أو اقفل الشاشة للتجربة!',
                              textAlign: TextAlign.right,
                            ),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.timer_10_rounded,
                              size: 16, color: theme.colorScheme.secondary),
                          const Spacer(),
                          Text(
                            'تجربة إشعار مجدول بعد ١٠ ثوانٍ (سريع)',
                            style: GoogleFonts.tajawal(
                              fontSize: 13.5,
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.alarm_on_rounded,
                              size: 20, color: theme.colorScheme.secondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Option C: Scheduled Test Notification (60 seconds countdown)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await scheduleTestCountdownNotification(seconds: 60);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '⏳ تمت جدولة إشعار اختباري ليصلك بعد ٦٠ ثانية بدقة — يمكنك إغلاق التطبيق أو قفل الشاشة للتجربة!',
                              textAlign: TextAlign.right,
                            ),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 16, color: theme.colorScheme.secondary),
                          const Spacer(),
                          Text(
                            'تجربة إشعار مجدول بعد دقيقة واحدة (٦٠ ثانية)',
                            style: GoogleFonts.tajawal(
                              fontSize: 13.5,
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.alarm_on_rounded,
                              size: 20, color: theme.colorScheme.secondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Option D: Check Registered Pending Notifications
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final count = await getPendingNotificationCount();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              count > 0
                                  ? '✅ يوجد $count تنبيه مجدول نشط في نظام الهاتف وجاهز للظهور في موعده'
                                  : '⚠️ لا توجد تنبيهات مجدولة حالياً، قم بتفعيل التنبيه لإعادة جدولته',
                              textAlign: TextAlign.right,
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.fact_check_outlined,
                              size: 16, color: theme.colorScheme.primary),
                          const Spacer(),
                          Text(
                            'التحقق من حالة التنبيهات المجدولة في النظام',
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: isLight ? Colors.grey[700] : Colors.grey[300],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle_outline_rounded,
                              size: 18, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],
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
