import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfx/pdfx.dart';
import '../../core/pdf_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final int initialPart; // 1 = Book 1, 2 = Book 2, 0 = All

  const PdfViewerScreen({
    super.key,
    this.initialPart = 1,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfControllerPinch _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  late int _activePart;

  @override
  void initState() {
    super.initState();
    _activePart = widget.initialPart;
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/data/book.pdf'),
    );
    _pdfController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (mounted) {
      setState(() {
        _currentPage = _pdfController.page;
        if (_totalPages > 0) {
          final midPoint = (_totalPages / 2).ceil();
          if (_currentPage >= midPoint) {
            _activePart = 2;
          } else {
            _activePart = 1;
          }
        }
      });
    }
  }

  void _jumpToPart(int part) {
    setState(() => _activePart = part);
    if (_totalPages == 0) return;

    if (part == 1) {
      _pdfController.jumpToPage(1);
    } else if (part == 2) {
      final midPoint = (_totalPages / 2).ceil();
      _pdfController.jumpToPage(midPoint > 1 ? midPoint : 1);
    }
  }

  @override
  void dispose() {
    _pdfController.removeListener(_onPageChanged);
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final green = const Color(0xFF006B3F);
    final gold = const Color(0xFFC5A880);
    final bgColor = isDark ? const Color(0xFF0F1E15) : const Color(0xFFFAF7F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          _activePart == 1
              ? 'الكتاب الأول: الجزء الأول'
              : (_activePart == 2
                  ? 'الكتاب الثاني: الجزء الثاني'
                  : 'كتاب تُحْفَةُ الوِلْدَانِ'),
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: false,
        actions: [
          // Page counter
          if (!_isLoading)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: gold,
                  ),
                ),
              ),
            ),
          // Download / Save button for active part
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'تنزيل وحفظ الكتاب PDF',
            onPressed: () => PdfService.showDownloadModal(context, initialPart: _activePart),
          ),
          // Share button for active part
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'مشاركة ملف PDF',
            onPressed: () => PdfService.sharePdf(context, part: _activePart),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildPartTab(
                    title: 'الجزء الأول (١/١ — ٤٠/١)',
                    partNumber: 1,
                    isSelected: _activePart == 1,
                    activeColor: green,
                    onTap: () => _jumpToPart(1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPartTab(
                    title: 'الجزء الثاني (١/٢ — ٤٠/٢)',
                    partNumber: 2,
                    isSelected: _activePart == 2,
                    activeColor: gold,
                    onTap: () => _jumpToPart(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PdfViewPinch(
        controller: _pdfController,
        onDocumentLoaded: (doc) {
          if (mounted) {
            setState(() {
              _totalPages = doc.pagesCount;
              _isLoading = false;
            });
            if (widget.initialPart == 2) {
              final midPoint = (doc.pagesCount / 2).ceil();
              _pdfController.jumpToPage(midPoint > 1 ? midPoint : 1);
            }
          }
        },
        onPageChanged: (page) {
          if (mounted) setState(() => _currentPage = page);
        },
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(green),
            ),
          ),
          pageLoaderBuilder: (_) => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(gold),
            ),
          ),
          errorBuilder: (_, error) => Center(
            child: Text(
              'خطأ في تحميل الكتاب:\n$error',
              style: GoogleFonts.tajawal(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      // Navigation buttons
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              color: isDark ? const Color(0xFF1A2E1F) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.navigate_next, color: green),
                    tooltip: 'الصفحة السابقة',
                    onPressed: _currentPage > 1
                        ? () => _pdfController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                  Text(
                    'صفحة $_currentPage من $_totalPages',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: isDark ? const Color(0xFFECE6D9) : const Color(0xFF555555),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.navigate_before, color: green),
                    tooltip: 'الصفحة التالية',
                    onPressed: _currentPage < _totalPages
                        ? () => _pdfController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPartTab({
    required String title,
    required int partNumber,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? activeColor
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? activeColor : Colors.grey[700],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
