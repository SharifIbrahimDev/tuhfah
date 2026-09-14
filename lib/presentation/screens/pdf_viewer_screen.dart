import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfx/pdfx.dart';
import '../../core/pdf_service.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfControllerPinch _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/data/book.pdf'),
    );
    _pdfController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (mounted) {
      setState(() {
        _currentPage = _pdfController.page;
      });
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
          'كتاب تُحْفَةُ الوِلْدَانِ',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
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
          // Download / Save button
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'تنزيل وحفظ الكتاب PDF',
            onPressed: () => PdfService.showDownloadModal(context),
          ),
          // Share button
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'مشاركة ملف PDF',
            onPressed: () => PdfService.sharePdf(context),
          ),
        ],
      ),
      body: PdfViewPinch(
        controller: _pdfController,
        onDocumentLoaded: (doc) {
          if (mounted) {
            setState(() {
              _totalPages = doc.pagesCount;
              _isLoading = false;
            });
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
}
