import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/notifications.dart';

/// Interactive Live Notification Monitor & Real-Time Countdown Widget
class NotificationLiveMonitorCard extends ConsumerStatefulWidget {
  final bool isDailyEnabled;
  final TimeOfDay dailyTime;
  final bool canExactAlarms;
  final VoidCallback onRefreshStatus;
  final VoidCallback onOpenExactSettings;

  const NotificationLiveMonitorCard({
    super.key,
    required this.isDailyEnabled,
    required this.dailyTime,
    required this.canExactAlarms,
    required this.onRefreshStatus,
    required this.onOpenExactSettings,
  });

  @override
  ConsumerState<NotificationLiveMonitorCard> createState() =>
      _NotificationLiveMonitorCardState();
}

class _NotificationLiveMonitorCardState
    extends ConsumerState<NotificationLiveMonitorCard> {
  Timer? _tickerTimer;
  DateTime _currentClock = DateTime.now();

  // Active Live Test State
  bool _isTestActive = false;
  int _testTotalSeconds = 0;
  int _testRemainingSeconds = 0;
  DateTime? _testTargetClock;
  String _testTitle = '';
  String? _testTriggerStatus; // 'countdown', 'success', 'failed'
  String? _testErrorMessage;

  // OS Pending Alarms Cache
  int _pendingAlarmsCount = 0;
  bool _isCheckingPending = false;

  @override
  void initState() {
    super.initState();
    _startClockTicker();
    _checkPendingCount();
  }

  @override
  void didUpdateWidget(covariant NotificationLiveMonitorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDailyEnabled != widget.isDailyEnabled ||
        oldWidget.dailyTime != widget.dailyTime) {
      _checkPendingCount();
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  void _startClockTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _currentClock = DateTime.now();

        // Handle Active Test Countdown
        if (_isTestActive && _testTargetClock != null) {
          final diff = _testTargetClock!.difference(_currentClock);
          if (diff.isNegative || diff.inSeconds <= 0) {
            _testRemainingSeconds = 0;
            _isTestActive = false;
            _testTriggerStatus = 'success';
          } else {
            _testRemainingSeconds = diff.inSeconds;
          }
        }
      });
    });
  }

  Future<void> _checkPendingCount() async {
    if (!mounted || _isCheckingPending) return;
    _isCheckingPending = true;
    try {
      final count = await getPendingNotificationCount();
      if (mounted) {
        setState(() {
          _pendingAlarmsCount = count;
        });
      }
    } catch (_) {} finally {
      _isCheckingPending = false;
    }
  }

  String _formatTimeArabic(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  String _formatClockArabic(DateTime dt) {
    final hourOfPeriod = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'م' : 'ص';
    return '$hourOfPeriod:$min:$sec $period';
  }

  Duration _calculateDailyRemainingDuration() {
    final now = DateTime.now();
    var target = DateTime(
      now.year,
      now.month,
      now.day,
      widget.dailyTime.hour,
      widget.dailyTime.minute,
      0,
    );

    if (target.isBefore(now) || target.difference(now).inSeconds <= 5) {
      target = target.add(const Duration(days: 1));
    }

    return target.difference(now);
  }

  Future<void> _startLiveTest({required int seconds, required String label}) async {
    final target = DateTime.now().add(Duration(seconds: seconds));

    setState(() {
      _isTestActive = true;
      _testTotalSeconds = seconds;
      _testRemainingSeconds = seconds;
      _testTargetClock = target;
      _testTitle = label;
      _testTriggerStatus = 'countdown';
      _testErrorMessage = null;
    });

    final res = await scheduleTestCountdownNotification(
      seconds: seconds,
      notificationId: seconds == 10
          ? kTestTenSecondsNotificationId
          : kTestScheduledNotificationId,
    );

    await _checkPendingCount();

    if (!mounted) return;

    setState(() {
      if (!res.success) {
        _testTriggerStatus = 'failed';
        _testErrorMessage = res.errorMessage ?? 'تعذر تسجيل التنبيه في النظام';
        _isTestActive = false;
      }
    });
  }

  Future<void> _pickCustomMinutesTest() async {
    final now = TimeOfDay.now();
    // Default: current time + 3 minutes
    final defaultMinute = (now.minute + 3) % 60;
    final defaultHour = now.minute + 3 >= 60 ? (now.hour + 1) % 24 : now.hour;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: defaultHour, minute: defaultMinute),
      helpText: 'اختر وقت التنبيه التجريبي الدقيق',
      confirmText: 'بدء العد التنازلي',
      cancelText: 'إلغاء',
    );

    if (picked != null) {
      final nowDt = DateTime.now();
      var targetDt = DateTime(
        nowDt.year,
        nowDt.month,
        nowDt.day,
        picked.hour,
        picked.minute,
        0,
      );

      if (targetDt.isBefore(nowDt)) {
        targetDt = targetDt.add(const Duration(days: 1));
      }

      final diffSeconds = targetDt.difference(nowDt).inSeconds;
      if (diffSeconds <= 0) return;

      final label = 'اختبار مخصص في تمام (${_formatTimeArabic(picked)})';
      await _startLiveTest(seconds: diffSeconds, label: label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final dailyRemaining = _calculateDailyRemainingDuration();

    final cardBg = isLight ? const Color(0xFFF9F7F3) : const Color(0xFF131D1A);
    final borderColor = isLight
        ? const Color(0xFFE4DCCE)
        : const Color(0xFF22352E);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Live Clock and Status Title
          Row(
            children: [
              Icon(Icons.timer_outlined,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'مراقب التنبيهات والعد التنازلي',
                  style: GoogleFonts.tajawal(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_filled_rounded,
                        size: 11, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      _formatClockArabic(_currentClock),
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Card 1: Daily Reminder Real-Time Ticker
          if (widget.isDailyEnabled) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : const Color(0xFF182622),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'موعد حديث اليوم: ${_formatTimeArabic(widget.dailyTime)}',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _pendingAlarmsCount > 0
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _pendingAlarmsCount > 0
                                  ? Icons.check_circle_rounded
                                  : Icons.info_outline_rounded,
                              size: 11,
                              color: _pendingAlarmsCount > 0
                                  ? Colors.green[700]
                                  : Colors.orange[800],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _pendingAlarmsCount > 0
                                  ? 'مسجل بالنظام'
                                  : 'جاري التأكيد',
                              style: GoogleFonts.tajawal(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _pendingAlarmsCount > 0
                                  ? Colors.green[800]
                                  : Colors.orange[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Digital countdown box
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFFAF8F5)
                          : const Color(0xFF111A17),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CountdownUnit(
                          value: (dailyRemaining.inSeconds % 60)
                              .toString()
                              .padLeft(2, '0'),
                          label: 'ثانية',
                          color: theme.colorScheme.primary,
                        ),
                        _ColonSeparator(color: theme.colorScheme.primary),
                        _CountdownUnit(
                          value: (dailyRemaining.inMinutes % 60)
                              .toString()
                              .padLeft(2, '0'),
                          label: 'دقيقة',
                          color: theme.colorScheme.primary,
                        ),
                        _ColonSeparator(color: theme.colorScheme.primary),
                        _CountdownUnit(
                          value: dailyRemaining.inHours
                              .toString()
                              .padLeft(2, '0'),
                          label: 'ساعة',
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Card 2: Active Real-time Test Section
          if (_testTriggerStatus != null) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _testTriggerStatus == 'success'
                    ? Colors.green.withValues(alpha: 0.12)
                    : _testTriggerStatus == 'failed'
                        ? Colors.red.withValues(alpha: 0.12)
                        : theme.colorScheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _testTriggerStatus == 'success'
                      ? Colors.green.withValues(alpha: 0.4)
                      : _testTriggerStatus == 'failed'
                          ? Colors.red.withValues(alpha: 0.4)
                          : theme.colorScheme.secondary.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _testTitle,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isTestActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'يرن: ${_testTargetClock != null ? _formatClockArabic(_testTargetClock!) : ""}',
                            style: GoogleFonts.tajawal(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (_testTriggerStatus == 'countdown') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'متبقي على إطلاق المنبه: ',
                          style: GoogleFonts.tajawal(fontSize: 12),
                        ),
                        Text(
                          '$_testRemainingSeconds ثوانٍ',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: _testTotalSeconds > 0
                          ? 1.0 - (_testRemainingSeconds / _testTotalSeconds)
                          : 0.0,
                      backgroundColor: theme.colorScheme.secondary
                          .withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.secondary),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ] else if (_testTriggerStatus == 'success') ...[
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() {
                              _testTriggerStatus = null;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '🎉 حان موعد التنبيه وتم إطلاقه بنجاح على جهازك! ✅',
                            style: GoogleFonts.tajawal(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.check_circle_rounded,
                            color: Colors.green[700], size: 18),
                      ],
                    ),
                  ] else if (_testTriggerStatus == 'failed') ...[
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            _startLiveTest(
                              seconds: _testTotalSeconds > 0
                                  ? _testTotalSeconds
                                  : 10,
                              label: _testTitle,
                            );
                          },
                          child: Text('إعادة المحاولة',
                              style: GoogleFonts.tajawal(fontSize: 11)),
                        ),
                        const Spacer(),
                        Expanded(
                          child: Text(
                            '❌ تعذر الجدولة: ${_testErrorMessage ?? "خطأ غير معروف"}',
                            style: GoogleFonts.tajawal(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.error_outline_rounded,
                            color: Colors.red[700], size: 18),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Quick Action Test Buttons
          Row(
            children: [
              Expanded(
                child: _QuickTestButton(
                  title: 'تجربة ١٠ ثوانٍ',
                  icon: Icons.timer_10_rounded,
                  onTap: () => _startLiveTest(
                    seconds: 10,
                    label: 'اختبار سريع (١٠ ثوانٍ)',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickTestButton(
                  title: 'تجربة ٦٠ ثانية',
                  icon: Icons.timer_outlined,
                  onTap: () => _startLiveTest(
                    seconds: 60,
                    label: 'اختبار دقيقة واحدة (٦٠ ثانية)',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickTestButton(
                  title: 'توقيت مخصص',
                  icon: Icons.more_time_rounded,
                  onTap: _pickCustomMinutesTest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _CountdownUnit({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 9.5,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ColonSeparator extends StatelessWidget {
  final Color color;

  const _ColonSeparator({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      child: Text(
        ':',
        style: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _QuickTestButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickTestButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF182622),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(height: 3),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
