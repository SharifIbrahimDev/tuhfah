import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/hadith_model.dart';
import '../../data/providers/hadith_provider.dart';

enum QuizMode {
  multipleChoice,
  fillInTheBlank,
}

enum QuizScope {
  all,
  part1,
  part2,
}

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  // Setup State
  QuizMode _selectedMode = QuizMode.multipleChoice;
  QuizScope _selectedScope = QuizScope.all;
  int _questionCount = 10;
  bool _isQuizActive = false;
  bool _isFinished = false;

  // Active Quiz State
  List<_QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;
  final List<_QuizResultItem> _resultSummary = [];

  void _startQuiz(List<HadithModel> allHadiths) {
    List<HadithModel> pool = allHadiths;
    if (_selectedScope == QuizScope.part1) {
      pool = allHadiths.where((h) => h.id <= 40).toList();
    } else if (_selectedScope == QuizScope.part2) {
      pool = allHadiths.where((h) => h.id > 40).toList();
    }

    if (pool.isEmpty) return;

    final random = Random();
    final shuffledPool = List<HadithModel>.from(pool)..shuffle(random);
    final count = min(_questionCount, shuffledPool.length);
    final selectedHadiths = shuffledPool.take(count).toList();

    _questions = selectedHadiths.map((hadith) {
      if (_selectedMode == QuizMode.fillInTheBlank) {
        return _generateBlankQuestion(hadith, pool, random);
      } else {
        return _generateMultipleChoiceQuestion(hadith, pool, random);
      }
    }).toList();

    setState(() {
      _currentIndex = 0;
      _score = 0;
      _streak = 0;
      _maxStreak = 0;
      _selectedAnswerIndex = null;
      _hasAnswered = false;
      _resultSummary.clear();
      _isQuizActive = true;
      _isFinished = false;
    });
  }

  _QuizQuestion _generateMultipleChoiceQuestion(
    HadithModel hadith,
    List<HadithModel> pool,
    Random random,
  ) {
    // Choose question type: 0 = Narrator, 1 = Source, 2 = Title to Text
    final type = random.nextInt(3);

    if (type == 0 && hadith.narrator.isNotEmpty) {
      // Narrator question
      final correctAnswer = hadith.narrator.trim();
      final otherNarrators = pool
          .where((h) => h.id != hadith.id && h.narrator.isNotEmpty)
          .map((h) => h.narrator.trim())
          .toSet()
          .toList()
        ..shuffle(random);

      final options = [correctAnswer, ...otherNarrators.take(3)]..shuffle(random);
      return _QuizQuestion(
        hadith: hadith,
        prompt: 'مَنْ راوي الحديث الشريف التالي؟',
        hadithSnippet: hadith.text,
        options: options,
        correctIndex: options.indexOf(correctAnswer),
      );
    } else if (type == 1 && hadith.source.isNotEmpty) {
      // Source question
      final correctAnswer = hadith.source.trim();
      final allSources = ['متفق عليه', 'رواه البخاري', 'رواه مسلم', 'رواه أبو داود', 'رواه الترمذي', 'رواه النسائي', 'رواه ابن ماجه'];
      final distractors = allSources.where((s) => s != correctAnswer).toList()..shuffle(random);
      final options = [correctAnswer, ...distractors.take(3)]..shuffle(random);

      return _QuizQuestion(
        hadith: hadith,
        prompt: 'ما هو مَخْرَج / مصدر الحديث الشريف الآتي؟',
        hadithSnippet: hadith.text,
        options: options,
        correctIndex: options.indexOf(correctAnswer),
      );
    } else {
      // Complete hadith text or match title
      final correctAnswer = hadith.title.trim();
      final otherTitles = pool
          .where((h) => h.id != hadith.id)
          .map((h) => h.title.trim())
          .toSet()
          .toList()
        ..shuffle(random);

      final options = [correctAnswer, ...otherTitles.take(3)]..shuffle(random);
      return _QuizQuestion(
        hadith: hadith,
        prompt: 'ما هو عنوان الحديث الذي نصه:',
        hadithSnippet: hadith.text,
        options: options,
        correctIndex: options.indexOf(correctAnswer),
      );
    }
  }

  _QuizQuestion _generateBlankQuestion(
    HadithModel hadith,
    List<HadithModel> pool,
    Random random,
  ) {
    final cleanWords = hadith.text
        .replaceAll('«', '')
        .replaceAll('»', '')
        .replaceAll('،', '')
        .replaceAll('.', '')
        .replaceAll(':', '')
        .replaceAll('؟', '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 4)
        .toList();

    String targetWord = 'الْقُرْآنَ';
    if (cleanWords.isNotEmpty) {
      targetWord = cleanWords[random.nextInt(cleanWords.length)];
    }

    // Replace the word in the hadith with blank
    final blankSnippet = hadith.text.replaceFirst(targetWord, ' [ .......... ] ');

    // Collect distractors from pool
    final poolWords = <String>{};
    for (final h in pool) {
      final words = h.text
          .replaceAll('«', '')
          .replaceAll('»', '')
          .replaceAll('،', '')
          .replaceAll('.', '')
          .split(RegExp(r'\s+'))
          .where((w) => w.length >= 4 && w != targetWord);
      poolWords.addAll(words);
    }

    final shuffledWords = poolWords.toList()..shuffle(random);
    final options = [targetWord, ...shuffledWords.take(3)]..shuffle(random);

    return _QuizQuestion(
      hadith: hadith,
      prompt: 'اختر الكلمة النبوية الصحيحة لملء الفراغ:',
      hadithSnippet: blankSnippet,
      options: options,
      correctIndex: options.indexOf(targetWord),
    );
  }

  void _submitAnswer(int index) {
    if (_hasAnswered) return;

    final currentQ = _questions[_currentIndex];
    final isCorrect = index == currentQ.correctIndex;

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
      if (isCorrect) {
        _score++;
        _streak++;
        if (_streak > _maxStreak) _maxStreak = _streak;
      } else {
        _streak = 0;
      }

      _resultSummary.add(
        _QuizResultItem(
          question: currentQ,
          userSelectedOption: currentQ.options[index],
          isCorrect: isCorrect,
        ),
      );
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hadithsAsync = ref.watch(hadithListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختبر حفظك ومعلوماتك',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: hadithsAsync.when(
        data: (allHadiths) {
          if (!_isQuizActive) {
            return _buildSetupView(allHadiths, theme);
          } else if (_isFinished) {
            return _buildResultsView(theme);
          } else {
            return _buildActiveQuizView(theme);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ في تحميل البيانات: $err')),
      ),
    );
  }

  // 1. Setup Screen
  Widget _buildSetupView(List<HadithModel> allHadiths, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [const Color(0xFF143324), const Color(0xFF0D2117)]
                    : [const Color(0xFF065A35), const Color(0xFF044227)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  'مركز اختبار الحفظ والمراجعة',
                  style: GoogleFonts.tajawal(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ثبّت حفظك لأحاديث النبي ﷺ عن القرآن الكريم عبر اختبارات تفاعلية وممتعة',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFC5A059).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'من كتاب تحفة الولدان • تأليف: إبراهيم شريف أبوبكر',
                    style: GoogleFonts.tajawal(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFDE68A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quiz Mode Section
          Text(
            'نوع الاختبار',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildChoiceCard(
                  title: 'أكمل الفراغ',
                  subtitle: 'تثبيت الألفاظ النبوية',
                  icon: Icons.edit_note_rounded,
                  isSelected: _selectedMode == QuizMode.fillInTheBlank,
                  onTap: () => setState(() => _selectedMode = QuizMode.fillInTheBlank),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceCard(
                  title: 'اختيار من متعدد',
                  subtitle: 'الرواة والمصادر والعناوين',
                  icon: Icons.quiz_rounded,
                  isSelected: _selectedMode == QuizMode.multipleChoice,
                  onTap: () => setState(() => _selectedMode = QuizMode.multipleChoice),
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Scope Section
          Text(
            'نطاق الأحاديث',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPillOption(
                  title: 'الكتاب كاملاً (٨٠)',
                  isSelected: _selectedScope == QuizScope.all,
                  onTap: () => setState(() => _selectedScope = QuizScope.all),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillOption(
                  title: 'الجزء ٢ (٤١—٨٠)',
                  isSelected: _selectedScope == QuizScope.part2,
                  onTap: () => setState(() => _selectedScope = QuizScope.part2),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillOption(
                  title: 'الجزء ١ (١—٤٠)',
                  isSelected: _selectedScope == QuizScope.part1,
                  onTap: () => setState(() => _selectedScope = QuizScope.part1),
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Question Count Section
          Text(
            'عدد الأسئلة',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [5, 10, 15, 20].map((count) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildPillOption(
                    title: '$count أسئلة',
                    isSelected: _questionCount == count,
                    onTap: () => setState(() => _questionCount = count),
                    theme: theme,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Start Quiz Button
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 3,
              ),
              onPressed: () => _startQuiz(allHadiths),
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: Text(
                'ابدأ الاختبار الآن',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Active Quiz Screen
  Widget _buildActiveQuizView(ThemeData theme) {
    final currentQ = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
          minHeight: 4,
        ),

        // Live Header Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFE6AF2E), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'النقاط: $_score',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Streak Chip
              if (_streak > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        'متتالي: $_streak',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),

              // Question progress indicator
              Text(
                'سؤال ${_currentIndex + 1} من ${_questions.length}',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Prompt text
                Text(
                  currentQ.prompt,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Hadith snippet card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF13221C) : const Color(0xFFF9F7F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.18),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    currentQ.hadithSnippet,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      height: 1.8,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E2522),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Options list
                ...List.generate(currentQ.options.length, (optIndex) {
                  final optionText = currentQ.options[optIndex];
                  final isSelected = _selectedAnswerIndex == optIndex;
                  final isCorrect = optIndex == currentQ.correctIndex;

                  Color optionBg = isDark ? const Color(0xFF192C23) : Colors.white;
                  Color borderColor = isDark ? const Color(0xFF224234) : const Color(0xFFE2DCD1);
                  Color textColor = isDark ? Colors.white : const Color(0xFF1E2522);
                  Widget? statusIcon;

                  if (_hasAnswered) {
                    if (isCorrect) {
                      optionBg = const Color(0xFF065A35).withValues(alpha: 0.18);
                      borderColor = const Color(0xFF065A35);
                      textColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065A35);
                      statusIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF065A35), size: 20);
                    } else if (isSelected) {
                      optionBg = Colors.red.withValues(alpha: 0.15);
                      borderColor = Colors.red;
                      textColor = Colors.red[700]!;
                      statusIcon = const Icon(Icons.cancel_rounded, color: Colors.red, size: 20);
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: optionBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _hasAnswered ? null : () => _submitAnswer(optIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            if (statusIcon != null) ...[
                              statusIcon,
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: Text(
                                optionText,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: GoogleFonts.tajawal(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Context & Feedback note when answered
                if (_hasAnswered) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '📖 ${currentQ.hadith.title}',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'المصدر: ${currentQ.hadith.source} (${currentQ.hadith.hadithNumber})',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Bottom Action Button
        if (_hasAnswered)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: Text(
                  _currentIndex < _questions.length - 1 ? 'السؤال التالي' : 'عرض النتيجة',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 3. Results Screen
  Widget _buildResultsView(ThemeData theme) {
    final percentage = ((_score / _questions.length) * 100).round();
    final isDark = theme.brightness == Brightness.dark;

    String gradeTitle;
    String gradeSubtitle;
    Color gradeColor;

    if (percentage >= 90) {
      gradeTitle = 'ما شاء الله! ممتاز جداً 🌟';
      gradeSubtitle = 'حفظ متقن ومعرفة راسخة بأحاديث القرآن';
      gradeColor = const Color(0xFF065A35);
    } else if (percentage >= 75) {
      gradeTitle = 'أحسنت! أداء رائع 👏';
      gradeSubtitle = 'لديك إلمام قوي بالأحاديث الشريفة';
      gradeColor = const Color(0xFF00897B);
    } else if (percentage >= 50) {
      gradeTitle = 'جيد، استمر في المراجعة 📖';
      gradeSubtitle = 'قارب على الإتقان، نوصيك بإعادة التكرار';
      gradeColor = const Color(0xFFE6AF2E);
    } else {
      gradeTitle = 'حاول ثانية، لا تيأس 💪';
      gradeSubtitle = 'التكرار أساس الحفظ والرسوخ';
      gradeColor = Colors.red[700]!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [const Color(0xFF143324), const Color(0xFF0D2117)]
                    : [const Color(0xFF065A35), const Color(0xFF044227)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: gradeColor.withValues(alpha: 0.6), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  gradeTitle,
                  style: GoogleFonts.tajawal(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  gradeSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildResultStat('الدرجة', '$percentage%'),
                    Container(height: 36, width: 1, color: Colors.white24),
                    _buildResultStat('الإجابات الصحيحة', '$_score / ${_questions.length}'),
                    Container(height: 36, width: 1, color: Colors.white24),
                    _buildResultStat('أطول تتابع', '$_maxStreak 🔥'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    setState(() {
                      _isQuizActive = false;
                      _isFinished = false;
                    });
                  },
                  icon: const Icon(Icons.settings_backup_restore_rounded),
                  label: Text('تغيير الإعدادات', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final hadiths = ref.read(hadithListProvider).value ?? [];
                    _startQuiz(hadiths);
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: Text('إعادة الاختبار', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question Review Summary
          Text(
            'مراجعة الأسئلة والإجابات',
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ..._resultSummary.map((item) {
            final correct = item.isCorrect;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF15261F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: correct
                      ? const Color(0xFF065A35).withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: correct ? const Color(0xFF065A35) : Colors.red,
                        size: 20,
                      ),
                      Text(
                        item.question.hadith.title,
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الإجابة الصحيحة: ${item.question.options[item.question.correctIndex]}',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: const Color(0xFF065A35),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!correct) ...[
                    const SizedBox(height: 2),
                    Text(
                      'إجابتك: ${item.userSelectedOption}',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? const Color(0xFF14241D) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.25),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? theme.colorScheme.primary : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final HadithModel hadith;
  final String prompt;
  final String hadithSnippet;
  final List<String> options;
  final int correctIndex;

  _QuizQuestion({
    required this.hadith,
    required this.prompt,
    required this.hadithSnippet,
    required this.options,
    required this.correctIndex,
  });
}

class _QuizResultItem {
  final _QuizQuestion question;
  final String userSelectedOption;
  final bool isCorrect;

  _QuizResultItem({
    required this.question,
    required this.userSelectedOption,
    required this.isCorrect,
  });
}
